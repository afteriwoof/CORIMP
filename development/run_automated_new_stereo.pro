; Created	20130327	from run_automated_new.pro to just edit it for stereo data newly processed.

; Created	20120210	from run_algorithms_edges_tvscl.pro

; Created	20120320	from run_automated.pro  with new threshold in run_automated2_new.pro


;INPUTS:	



;OUTPUTS:	

;KEYWORDS:	-	old_data	if the data is the old format of dynamics_20100227_000603_c2_soho.fits.gz
;					(as opposed to newest format of c2_lasco_soho_dynamics_20110101_001141.fits.gz).



pro run_automated_new_stereo, fls, out_dir, pa_total, gail=gail, stereo=stereo, behind=behind, old_data=old_data

; Assuming no model is input (case of running code on gail)

if ~keyword_set(stereo) then begin
	C2_thr_inner = 2.2d
	C2_thr_outer = 6.d
	C3_thr_inner = 5.7d
	C3_thr_outer = 25.d
	str_count = 23
	if keyword_set(old_data) then begin
		C2_thr_inner = 2.2d
		C2_thr_outer = 5.95d
		C3_thr_inner = 5.95d
		C3_thr_outer = 19.5d
		str_count = 9 
	endif
endif else begin
	if keyword_set(behind) then C2_thr_inner = 4.1 else C2_thr_inner = 3d
	if keyword_set(behind) then C2_thr_outer = 14d else C2_thr_outer = 14d
	str_count = 23
endelse


if ~keyword_set(gail) then begin
	!p.multi = 0
	window, xs=1024, ys=1024
endif

; Sorting file in order of timestamps (not always needed)
;if ~keyword_set(old_data) then if n_elements(fls) gt 1 then fls=sort_fls(fls)

;Initialise
count = 0
gather_count = 0
pa_total = dblarr(360,n_elements(fls))


;Loop over all files
while count lt n_elements(fls) do begin

	if ~keyword_set(gail) then begin
		print, '---------------------------------------------------'
		print, '% ' & print, 'Reading file ', count, ' of ', n_elements(fls)-1
		print, '% ' & print, fls[count]
	endif

	; Read files
	mreadfits_corimp, fls[count], in, da

	da_orig = da

	;if in.instrume eq 'SWAP' then begin
	;	print, 'Proba-2 / SWAP'
	;        C2_thr_inner = 1.
	;        C2_thr_outer = 1.7
	;endif

	;Assign file date+time
	in.filename = strmid(file_basename(fls[count]), str_count, 15)
	if ~keyword_set(gail) then print, 'in.filename ', in.filename
	if gather_count eq 0 then begin
		gather_filenames = file_basename(fls[count])
		gather_date_obs = in.date_obs
		gather_count = 1
	endif else begin
		gather_filenames = [gather_filenames, file_basename(fls[count])]
		gather_date_obs = [gather_date_obs, in.date_obs]
	endelse

	; Correct for structure mistakes
	if keyword_set(stereo) AND tag_exist(in,'instrume') eq 0 then begin
		in = add_tag(in, in.telescop, 'instrume')
		in.instrume = 'SECCHI'
	endif
	;if in.instrume eq 'SWAP' then begin
	;	in = add_tag(in, 'C2', 'i3_instr')
	;	in = add_tag(in, in.instrume, 'i4_instr')
	;	in = add_tag(in, in.cdelt1, 'pix_size')
	;	in = add_tag(in, in.rsun_arc, 'rsun')
	;endif

	if tag_exist(in, 'xcen') eq 0 then begin
		in = add_tag(in, in.crpix1, 'xcen')
		in = add_tag(in, in.crpix2, 'ycen')
	endif

	if tag_exist(in, 'crpix1') eq 0 then begin
		in = add_tag(in, in.xcen, 'crpix1')
		in = add_tag(in, in.ycen, 'crpix2')
	endif
	if in.xcen le 0 then in.xcen = in.crpix1
	if in.ycen le 0 then in.ycen = in.crpix2

	if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then begin
		thr_inner = c2_thr_inner
		thr_outer = c2_thr_outer
	endif
	if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then begin
		thr_inner = c3_thr_inner
		thr_outer = c3_thr_outer
	endif
	if in.i4_instr eq 'COR2' || in.i4_instr eq 'cor2' then begin
		thr_inner = c2_thr_inner
		thr_outer = c2_thr_outer
	endif
	; Reflect data in and out of occulted field-of-view.
	if ~keyword_set(no_reflect) then begin
		if ~keyword_set(gail) then print, 'Reflecting data in/out of field-of-view.'
		da=reflect_inner_outer(in,da,thr_inner,thr_outer)
	endif
	
	;Multiscale decomposition
	canny_atrous2d, da, modgrad, alpgrad, rows=rows, columns=columns

	if ~keyword_set(no_reflect) then begin
		da = da[96:1119, 96:1119]
		modgrad = modgrad[96:1119, 96:1119, *]
		alpgrad = alpgrad[96:1119, 96:1119, *]
		rows = rows[96:1119, 96:1119, *]
		columns = columns[96:1119, 96:1119, *]
	endif

	sz = size(da, /dim)

	if ~keyword_set(gail) then print, 'Using scales 3, 4, 5, and 6 of decomposition.'

	if ~keyword_set(gail) then print, 'Removing inner/outer occulters'
	for k=0,3 do begin & $
		modgrad[*,*,k+3]=rm_inner_corimp(modgrad[*,*,k+3],in,thr=thr_inner) & $
                alpgrad[*,*,k+3]=rm_inner_corimp(alpgrad[*,*,k+3],in,thr=thr_inner) & $
                modgrad[*,*,k+3]=rm_outer_corimp(modgrad[*,*,k+3],in,thr=thr_outer) & $
                alpgrad[*,*,k+3]=rm_outer_corimp(alpgrad[*,*,k+3],in,thr=thr_outer) & $
                rows[*,*,k+3] = rm_inner_corimp(rows[*,*,k+3],in,thr=thr_inner) & $
                rows[*,*,k+3] = rm_outer_corimp(rows[*,*,k+3],in,thr=thr_outer) & $
                columns[*,*,k+3]=rm_inner_corimp(columns[*,*,k+3],in,thr=thr_inner) & $
                columns[*,*,k+3]=rm_outer_corimp(columns[*,*,k+3],in,thr=thr_outer) & $
	endfor

	; Not removing pylon because of cases when SOHO is in keyhole!

	da = rm_inner_corimp(da, in, thr=thr_inner)
	da = rm_outer_corimp(da, in, thr=thr_outer)

	;if in.instrume eq 'SWAP' then da = da_orig

	;Non-maxima suppression
	edges = wtmm(modgrad[*,*,3:6], rows[*,*,3:6], columns[*,*,3:6])

	if ~keyword_set(non_dynamic) then begin
		if ~keyword_set(gail) then print, 'Running cme_detection_mask_corimp_dynamic_thr.pro'
		cme_detection_mask_corimp_dynamic_thr, in, da, modgrad[*,*,3:6], alpgrad[*,*,3:6], cme_mask
	endif

	if ~keyword_set(gail) then print, 'Multiplying the modgrads 3 to 6 together: multmods'
	multmods = modgrad[*,*,3]*modgrad[*,*,4]*modgrad[*,*,5]*modgrad[*,*,6]

	;Save the detection mask
	;if ~keyword_set(no_png) then begin
	;	if ~keyword_set(gail) then begin
			print, 'Saving CME mask (before removing lower scoring regions).'
			if ~dir_exist('cme_masks') then spawn, 'mkdir -p '+out_dir+'/cme_masks'
			; only save out the index arrays of the non-zeros in the cme_mask
			cme_mask_str = cme_mask_inds(cme_mask)
			if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then save, cme_mask_str, f=out_dir+'/cme_masks/CME_mask_str_C2_'+in.filename+'.sav'
			if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then save, cme_mask_str, f=out_dir+'/cme_masks/CME_mask_str_C3_'+in.filename+'.sav'
			if in.i4_instr eq 'COR2' || in.i4_instr eq 'cor2' then save, cme_mask_str, f=out_dir+'/cme_masks/CME_mask_str_COR2_'+in.filename+'.sav'
	;	endif
	;endif

	; Thresholding what level of mask to include.
	if ~keyword_set(gail) then print, '---- Thresholding max_cme_mask = 3 for C2, C3, and COR2 ----'
	max_cme_mask = 3
	
	if max(cme_mask) gt max_cme_mask then begin
		cme_mask_thr = intarr(sz[0], sz[1])
		cme_mask_thr[where(cme_mask gt max_cme_mask)] = cme_mask[where(cme_mask gt max_cme_mask)]
	endif else begin
		if ~keyword_set(gail) then begin
			loadct, 0
			tvscl, da
			legend, 'No CME detected', charsize=2
			draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size, /device
			xyouts, 395, 990, in.date_obs, charsize=2, /device
			if ~keyword_set(no_png) then begin
				if ~dir_exist('cme_pngs') then spawn, 'mkdir -p '+out_dir+'/cme_pngs'
				if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/cme_pngs/CME_front_edges_C2_'+in.filename+'.png'
				if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/cme_pngs/CME_front_edges_C3_'+in.filename+'.png'
			endif
		endif
		goto, jump2
	endelse

	if ~keyword_set(gail) then begin
                loadct, 0
                tvscl, da
                draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size, /device
                xyouts, 395, 990, in.date_obs, charsize=2, /device
        endif

	; Running run_automated2_new.pro
	if ~keyword_set(gail) then print, 'Running run_automated2_new.pro with cme_mask_thr'
	run_automated2_new, fls[count], in, da, multmods, cme_mask_thr, edges, out_dir, pa, heights, fail, gail=gail

	if fail eq 0 then begin
		; Need to enter the maximum height along each angle since there can be many heights when angles are rounded
		for pa_i=0,n_elements(pa)-1 do begin & $
			pa_check = (round(pa))[pa_i] mod 360 & $
			pa_total[pa_check, count] = max(heights[where(round(pa) eq pa_check)]) & $
		endfor
		;pa_total[round(pa), count] = heights
		if n_elements(plots_list) eq 0 then plots_list = count else plots_list = [plots_list, count]
	endif else begin
		if ~keyword_set(gail) then legend, 'No CME detected', charsize=2
	endelse

	if ~keyword_set(no_png) && ~keyword_set(gail) then begin
		if ~dir_exist('cme_pngs') then spawn, 'mkdir -p '+out_dir+'/cme_pngs'
		if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/cme_pngs/CME_front_edges_C2_'+in.filename+'.png'
		if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/cme_pngs/CME_front_edges_C3_'+in.filename+'.png'
		if in.i4_instr eq 'COR2' || in.i4_instr eq 'cor2' then x2png, out_dir+'/cme_pngs/CME_front_edges_COR2_'+in.filename+'.png'
	endif

	jump2:

	count += 1

	delvarx, alpgrad, cme_mask, cme_mask_thr, columns, da, dr_px, edges, fail, heights
	delvarx, k, max_cme_mask, modgrad, multmods, pa, rows, sz, thr_inner, thr_outer
		
endwhile

;Shifting pa_total so that it starts at solar north.
if ~keyword_set(gail) then print, 'Shifting pa_total so that it starts at solar north.'
temp = pa_total
temp[0:269,*] = pa_total[90:359,*]
temp[270:359,*] = pa_total[0:89,*]
pa_total = temp
delvarx, temp

det_stack = {filenames:gather_filenames,date_obs:gather_date_obs,stack:pa_total,list:plots_list}

if ~keyword_set(gail) then print, 'Saving det_stack'
save, det_stack, f=out_dir+'/det_stack_'+strmid(in.filename,0,8)+'.sav'

;if ~keyword_set(gail) then print, 'Saving plots_list'
;save, plots_list, f=out_dir+'/plots_list_'+strmid(in.filename,0,8)+'.sav'



end
