; Created	2012-07-230	from run_automated.pro but for inputting multicme_model fits.


;INPUTS:	



;OUTPUTS:	


pro run_automated_model, fls, out_dir, pa_total, gail=gail


; Assuming no model is input (case of running code on gail)

if ~keyword_set(stereo) then begin
	C2_thr_inner = 2.3d
	C2_thr_outer = 5.7d
	C3_thr_inner = 5.95d
	C3_thr_outer = 16d
	;if keyword_set(gail) then str_count = 9 else str_count=9
	str_count = 28
endif else begin
	C2_thr_inner = 3d
	C2_thr_outer = 11d
	;if keyword_set(gail) then str_count = 9 else str_count=9
	str_count = 26
endelse

if ~keyword_set(gail) then begin
	!p.multi = 0
	window, xs=1024, ys=1024
endif

; Sorting file in order of timestamps
;if n_elements(fls) gt 1 then fls=sort_fls(fls, str_count)

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

	;Assign file date+time
	if keyword_set(gail) then in.filename = strmid(file_basename(fls[count]), str_count, 12) $
		else in.filename = strmid(file_basename(fls[count]), str_count, 12)
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

	if tag_exist(in, 'crpix1') eq 0 then begin
		in = add_tag(in, in.xcen, 'crpix1')
		in = add_tag(in, in.ycen, 'crpix2')
	endif
	if in.xcen le 0 then in.xcen = in.crpix1
	if in.ycen le 0 then in.ycen = in.crpix2

	; Reflect data in and out of occulted field-of-view.
	if ~keyword_set(no_reflect) then begin
		if ~keyword_set(stereo) then begin
			da=reflect_inner_outer_cme_model(in,da)
		endif else begin
			if keyword_set(behind) then da=reflect_inner_outer(in,da,/stereo,/behind) $
				else da=reflect_inner_outer(in,da,/stereo)
		endelse
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

	if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then begin
		if ~keyword_set(gail) then print, 'LASCO/C2'
		thr_inner = replicate(C2_thr_inner, 4)
		thr_outer = replicate(C2_thr_outer, 4)
	endif
	if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then begin
		if ~keyword_set(gail) then print, 'LASCO/C3'
		thr_inner = replicate(C3_thr_inner, 4)
		thr_outer = replicate(C3_thr_outer, 4)
	endif
	
	if ~keyword_set(gail) then print, 'Removing inner/outer occulters'
	for k=0,3 do begin
		modgrad[*,*,k+3]=rm_inner_corimp(modgrad[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
                alpgrad[*,*,k+3]=rm_inner_corimp(alpgrad[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
                modgrad[*,*,k+3]=rm_outer_corimp(modgrad[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
                alpgrad[*,*,k+3]=rm_outer_corimp(alpgrad[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
                rows[*,*,k+3] = rm_inner_corimp(rows[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
                rows[*,*,k+3] = rm_outer_corimp(rows[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
                columns[*,*,k+3]=rm_inner_corimp(columns[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
                columns[*,*,k+3]=rm_outer_corimp(columns[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
	endfor

	; Not removing pylon because of cases when SOHO is in keyhole!

	if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then begin
		da = rm_inner_corimp(da, in, dr_px, thr=C2_thr_inner)
		da = rm_outer_corimp(da, in, dr_px, thr=C2_thr_outer)
	endif
	if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then begin
		da = rm_inner_corimp(da, in, dr_px, thr=C3_thr_inner)
		da = rm_outer_corimp(da, in, dr_px, thr=C3_thr_outer)
	endif

	;Non-maxima suppression
	edges = wtmm(modgrad[*,*,3:6], rows[*,*,3:6], columns[*,*,3:6])

	if ~keyword_set(non_dynamic) then begin
		if ~keyword_set(gail) then print, 'Running cme_detection_mask_corimp_dynamic_thr.pro'
		cme_detection_mask_corimp_dynamic_thr, in, da, modgrad[*,*,3:6], alpgrad[*,*,3:6], cme_mask
	endif

	if ~keyword_set(gail) then print, 'Multiplying the modgrads 3 to 6 together: multmods'
	multmods = modgrad[*,*,3]*modgrad[*,*,4]*modgrad[*,*,5]*modgrad[*,*,6]

	;Save the detection mask
	if ~keyword_set(no_png) then begin
		if ~keyword_set(gail) then begin
			print, 'Saving CME mask (before removing lower scoring regions).'
			if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then save, cme_mask, f=out_dir+'/CME_mask_'+in.filename+'_C2.sav'
			if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then save, cme_mask, f=out_dir+'/CME_mask_'+in.filename+'_C3.sav'
			if in.i4_instr eq 'COR2' || in.i4_instr eq 'cor2' then save, cme_mask, f=out_dir+'/CME_mask_'+in.filename+'_COR2.sav'
		endif
	endif

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
				if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/CME_front_edges_'+in.filename+'_C2.png'
				if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/CME_front_edges_'+in.filename+'_C3.png'
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

	; Running run_automated2.pro
	if ~keyword_set(gail) then print, 'Running run_automated2.pro with cme_mask_thr'
	if ~keyword_set(gail) then $
		run_automated2, fls[count], in, da, multmods, cme_mask_thr, edges, out_dir, pa, heights, fail $
		else $
		run_automated2, fls[count], in, da, multmods, cme_mask_thr, edges, out_dir, pa, heights, fail, /gail

	if fail eq 0 then begin
		; Need to enter the maximum height along each angle since there can be many heights when angles are rounded
		if n_elements(pa) gt 1 then begin
			for pa_i=0,n_elements(pa)-1 do begin
				pa_check = (round(pa))[pa_i]
				pa_ind = where(round(pa) eq pa_check)
				if pa_ind ne [-1] then pa_total[(pa_check mod 360), count] = max(heights[where(round(pa) eq pa_check)])
			endfor
		endif else begin
			pa_total[round(pa), count] = heights
		endelse
		if n_elements(plots_list) eq 0 then plots_list = count else plots_list = [plots_list, count]
	endif else begin
		if ~keyword_set(gail) then legend, 'No CME detection', charsize=2
	endelse

	if ~keyword_set(no_png) && ~keyword_set(gail) then begin
		if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/CME_front_edges_'+in.filename+'_C2.png'
		if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/CME_front_edges_'+in.filename+'_C3.png'
		if in.i4_instr eq 'COR2' || in.i4_instr eq 'cor2' then x2png, out_dir+'/CME_front_edges_'+in.filename+'_COR2.png'
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
