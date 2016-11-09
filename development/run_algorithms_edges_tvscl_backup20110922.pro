; Created 04-03-11 from run_algorithms_edges.pro to use tvscl instead of plot_image.
;
; Last edited: 	17-03-11	to include reflect keyword
;		19-03-11	to include gail keyword
;		22-03-11	changed reflect keyword to no_reflect
;		27-05-11	to include input for str_count when filename length changes.
;		29-07-11	to include keyword dynamic for calling cme_detection_mask_corimp_dynamic_thr.pro with test_contour_thresholds.pro.

;INPUTS:	fls 	- list of fits.
;		out_dir	- directory to save pngs to.

;OUTPUTS:	pa_total	- the position angle total detections image

pro run_algorithms_edges_tvscl, fls, pa_total, out_dir, saves0=saves0, show=show, pauses=pauses, no_png=no_png, no_reflect=no_reflect, gail=gail, dynamic=dynamic, model=model

;*** Cant delete these if not using model
if keyword_set(model) then begin
	C2_thr_outer = 5.7
	C3_thr_outer = 16.
	;print, 'Currently have C2_thr_outer set to 5.7 rather than 5.95 because of the cme model'
	;print, 'Currently have C3_thr_outer set to 16 rather than 19.5 because of the cme model'
	str_count = 28
	print, 'Currently have str_count set to 28 rather than 25 because of the cme model'
endif else begin
	C2_thr_outer = 5.95
	C3_thr_outer = 19.5
	str_count = 25
endelse
;***


if ~keyword_set(gail) then begin
	!p.multi=0
	window, xs=1024, ys=1024
endif

;Sorting files in order of timestamps.
if n_elements(fls) gt 1 then fls = sort_fls(fls, str_count)

count = 0
list_total = intarr(4,n_elements(fls)) ; 4 because that's how many scales I'm currently including from e.g. modgrad[*,*,3:6]
pa_total = fltarr(360,n_elements(fls))

while count lt n_elements(fls) do begin & $

	if keyword_set(saves0) then goto, save_jump

	if ~keyword_set(gail) then begin
		print, '*****************************************************'
		print, '%' & print, 'Reading file ',count,' of ',n_elements(fls)-1
		print, '%' & print, fls[count]
	endif
	mreadfits_corimp, fls[count], in, da & $

	;Case of lasco_2011 files highlighting when in.filename is wrong
	;print, 'Files need to be from ~/postdoc/aut...'
	in.filename = strmid(fls[count],strpos(fls[count],'/')+80,12)
	print, 'in.filename ', in.filename


	if tag_exist(in,'crpix1') eq 0 then begin
		in = add_tag(in,in.xcen,'crpix1')
		in = add_tag(in,in.ycen,'crpix2')
	endif
	if in.xcen le 0 then in.xcen = in.crpix1
	if in.ycen le 0 then in.ycen = in.crpix2
	
	if ~keyword_set(no_reflect) then begin
		if keyword_set(model) then da=reflect_inner_outer(in, da, /model) else da=reflect_inner_outer(in,da)
	endif
	
	canny_atrous2d, da, modgrad, alpgrad, rows=rows, columns=columns
	
	if ~keyword_set(no_reflect) then begin
		da = da[96:1119,96:1119]
		modgrad = modgrad[96:1119,96:1119,*]
		alpgrad = alpgrad[96:1119,96:1119,*]
		rows = rows[96:1119,96:1119,*]
		columns = columns[96:1119,96:1119,*]
	endif
	
	sz = size(da, /dim)
	
	if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then begin
		if ~keyword_set(gail) then print,'LASCO/C2'
		if keyword_set(no_reflect) then begin
			thr_inner = [2.65,2.55,2.45,2.4] 
			thr_outer = [5.60,5.70,5.80,5.85]
		endif else begin
			thr_inner = replicate(2.35,4)
			thr_outer = replicate(C2_thr_outer,4)
		endelse
	endif
	if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then begin
		if ~keyword_set(gail) then print, 'LASCO/C3'
		if keyword_set(no_reflect) then begin
			thr_inner = [8,7,6.5,6.25]
			thr_outer = [18,19,19.5,19.75]
		endif else begin
			thr_inner = replicate(5.95,4)
			thr_outer = replicate(C3_thr_outer,4)
		endelse
	endif
	
	;if ~keyword_set(gail) then print, '-----------------------------------------------------'
	
	if ~keyword_set(gail) then print, 'Removing inner/outer occulters'
	for k=0,3 do begin & $
		modgrad[*,*,k+3]=rm_inner_corimp(modgrad[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
		alpgrad[*,*,k+3]=rm_inner_corimp(alpgrad[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
		modgrad[*,*,k+3]=rm_outer_corimp(modgrad[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
		alpgrad[*,*,k+3]=rm_outer_corimp(alpgrad[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
		rows[*,*,k+3] = rm_inner_corimp(rows[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
		rows[*,*,k+3] = rm_outer_corimp(rows[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
		columns[*,*,k+3]=rm_inner_corimp(columns[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
		columns[*,*,k+3]=rm_outer_corimp(columns[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
	endfor

	if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then begin
		if keyword_set(gail) then begin
			print, 'Removing the C3 pylon region of the modgrad and alpgrad images'
			restore, 'c3pylonmask.sav'		
		endif else begin
			restore,'~/idl_codes/c3pylonmask.sav'
		endelse
		for k=0,3 do begin & $
			modgrad[*,*,k+3] *= c3pylonmask & $
			alpgrad[*,*,k+3] *= c3pylonmask & $
			rows[*,*,k+3] *= c3pylonmask & $
			columns[*,*,k+3] *= c3pylonmask & $
		endfor
	endif

	if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then begin
		da = rm_inner_corimp(da, in, dr_px, thr=2.35)
		da = rm_outer_corimp(da, in, dr_px, thr=C2_thr_outer)
	endif
	if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then begin
		da = rm_inner_corimp(da, in, dr_px, thr=5.95)
		da = rm_outer_corimp(da, in, dr_px, thr=C3_thr_outer)
		da *= c3pylonmask
		delvarx, c3pylonmask
	endif

	; Non-maxima suppression
        edges = wtmm(modgrad[*,*,3:6], rows[*,*,3:6], columns[*,*,3:6])	

	if keyword_set(show) then begin
                tvscl,edges[*,*,0]
                if keyword_set(pauses) then pause
                tvscl,edges[*,*,1]
                if keyword_set(pauses) then pause
                tvscl,edges[*,*,2]
                if keyword_set(pauses) then pause
                tvscl,edges[*,*,3]
                if keyword_set(pauses) then pause
        endif

	; Saving programming time: delete later!
	;print, 'Saving saves0.sav'
	;save, in, da, modgrad, alpgrad, edges, sz, f='saves0.sav'
	save_jump:
	if keyword_set(saves0) then restore, 'saves0.sav', /ver

	if keyword_set(show) then begin
		if keyword_set(dynamic) then begin
			print, 'Running cme_detection_mask_corimp_dynamic_thr, /show'
			cme_detection_mask_corimp_dynamic_thr, in, da, modgrad[*,*,3:6], alpgrad[*,*,3:6], cme_mask, list, /show, /no_wait, /loud
		endif else begin
			print, 'Running cme_detection_mask_corimp, /show'
			cme_detection_mask_corimp, in, da, modgrad[*,*,3:6], alpgrad[*,*,3:6], cme_mask, list, /show, /no_wait, /loud;, circ_pol, cme_detect, cme_detection_frames, /show, /no_wait, /loud
		endelse
		;list_total[*,count] = list
	endif else begin
		if keyword_set(dynamic) then begin
			print, 'Running cme_detection_mask_corimp_dynamic_thr'
			cme_detection_mask_corimp_dynamic_thr, in, da, modgrad[*,*,3:6], alpgrad[*,*,3:6], cme_mask, list
		endif else begin
			print, 'Running cme_detection_mask_corimp'
			cme_detection_mask_corimp, in, da, modgrad[*,*,3:6], alpgrad[*,*,3:6], cme_mask, list
		endelse
		;list_total[*,count] = list
	endelse

	if ~keyword_set(gail) then print, 'Multiplying the modgrads 3 to 6 together'
	multmods = modgrad[*,*,3]*modgrad[*,*,4]*modgrad[*,*,5]*modgrad[*,*,6] & $

	;save the detection mask
	save, cme_mask, f='cme_mask.sav'	
	
	; Thresholding what level of masks to include
	;cme_mask_thr = cme_mask & $
	;cme_mask_thr[where(cme_mask_thr le max(cme_mask)/3.)] = 0 & $
	print, '***** Thresholding max_cme_mask = 3 for both C2 and C3 *****'
	if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then max_cme_mask = 3 ; Note these have to change for xyouts line in run_algorithms2_edges_tvscl.pro
	if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then max_cme_mask = 3
	
	if max(cme_mask) gt max_cme_mask then begin
		cme_mask_thr = intarr(sz[0],sz[1])
		cme_mask_thr[where(cme_mask gt max_cme_mask)] = cme_mask[where(cme_mask gt max_cme_mask)]
	endif else begin
		if ~keyword_set(gail) then begin
			loadct, 0
			tvscl, da
			legend, 'No CME detected', charsize=2
		        draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size, /device
		        xyouts, 395, 990, in.date_obs, charsize=2, /device
			;;;xyouts, 20, 50, 'max_cme_mask', charsize=2
		        ;;;xyouts, 20, 25, 'thr: C2>3 C3>1', charsize=2
			if ~keyword_set(no_png) then if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/CME_front_edges_'+strmid(in.filename,0)+'_C3.png'
			;if ~keyword_set(no_png) then if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/CME_front_edges_'+strmid(in.filename,str_count,12)+'_C3.png'
		       	if ~keyword_set(no_png) then if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/CME_front_edges_'+strmid(in.filename,0)+'_C2.png'
		       	;if ~keyword_set(no_png) then if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/CME_front_edges_'+strmid(in.filename,str_count,12)+'_C2.png'
			if keyword_set(pauses) then pause
		endif
		goto, jump2
	endelse
	
	; If contours on cme_mask_thr split then more than one CME detection is possibly occuring.
	; First have to dilate by smaller amount to be sure the regions contour together as they are.
	cme_mask_dil = dilate(cme_mask_thr,replicate(1,11,11))
	;if keyword_set(show) then begin
	;	tvscl, cme_mask_dil & print, 'cme_mask_dil'
	;	set_line_color
	;	contour,cme_mask_dil,lev=1,/over,color=3, /device
	;	if keyword_set(pauses) then pause
	;endif
	contour, cme_mask_dil, lev=1, path_xy=xy, path_info=info, /path_data_coords
	cme_count = n_elements(info)
	;;;;;;;;;;;;;;;;;;
	; Commenting out all the dilation info and just going on the cme_count as being the number of ROIs for now.
	;;;;;;;;;;;;;;;;;
	;region_check = intarr(sz[0],sz[1])
	;region_check_unique = intarr(sz[0],sz[1])
	;cme_count = 1 ;how many CMEs are detected in the image - starts at one.
	;flag_count = 0
	;
	;; Loop over all contoured regions of interest
	;for contour_count=0,n_elements(info)-1 do begin
	;
	;	if contour_count ne 0 then region_check[where(region_check gt 0)]=1 ; set all previous regions to same value of 1 (so 1+1 means overlap).
	;	
	;	region_x = xy[0,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
	;	region_y = xy[1,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
	;	region_ind = polyfillv(region_x, region_y, sz[0], sz[1])
	;	region_check[region_ind] += 1
	;	region_check_unique[*,*] = 0
	;	region_check_unique[region_ind] = 1
	;	
	;	if keyword_set(show) then begin
	;		tvscl, region_check
	;		print, 'tvscl, region_check'
	;		if keyword_set(pauses) then pause
	;		tvscl, region_check_unique
	;		print, 'tvscl, region_check_unique'
	;		if keyword_set(pauses) then pause
	;	endif
	;	
	;	; if it's the first case of CME detection then no need to check dilation overlap so jump to end at jump1
	;	if max(region_check) gt 1 || contour_count eq 0 then goto, jump1
	;	
	;	if keyword_set(show) then contour, region_check, lev=1, /over, color=3
	;	contour, region_check, lev=1, path_info=info_before,/path_data_coords
	;	print, 'n_elements(info_before): ', n_elements(info_before)
	;
	;	region_check_dilated = dilate(region_check, replicate(1,51,51))
	;	if keyword_set(show) then begin
	;		tvscl, region_check_dilated
	;		print, 'tvscl, region_check_dilated'
	;		if keyword_set(pauses) then pause
	;	endif
	;	; Can't morph_close the region_check_dilated because it joins close regions together!
	;	region_check_unique_dil = dilate(region_check_unique,replicate(1,51,51))
	;	region_check_unique_dil = morph_close(region_check_unique_dil, replicate(1,41,41))
	;	region_check_unique_dil_ind = where(region_check_unique_dil gt 0)
	;	if region_check_unique_dil_ind ne [-1] then region_check_dilated[region_check_unique_dil_ind] = 1 else goto, jump1
	;	delvarx, region_check_unique_dil_ind
	;	if keyword_set(show) then begin
	;		tvscl, region_check_dilated
	;		print, 'tvscl, morph_close(region_check_dilated)'
	;		if keyword_set(pauses) then pause
	;		contour, region_check_dilated, lev=1, /over, color=3
	;	endif
	;	
	;	contour, region_check_dilated, lev=1, path_info=info_after,/path_data_coords
	;	print, 'before: ', n_elements(info_before), '	after: ', n_elements(info_after)
	;	print, 'cme_count before: ', cme_count
	;	if keyword_set(pauses) then pause
	;	if n_elements(info_after) ne cme_count then begin
	;		print, '------------------------------'
	;		print, '--- Multiple CMEs detected ---'
	;		print, '------------------------------'
	;		cme_count = n_elements(info_after)
	;		print, 'cme_count after: ', cme_count
	;	endif else begin
	;		print, '----------------------------'
	;		print, '--- Part of the same CME ---'
	;		print, '----------------------------'
	;		if flag_count eq 0 then flag_multiples = contour_count else flag_multiples = [flag_multiples, contour_count]
	;		flag_count += 1
	;	endelse
	;
	;	jump1:
	;	
	;endfor
	;
	;
	;***********
	;
	;print, '-------------------------------------'
	;print, 'Number of CMEs detected: ', cme_count
	;print, '-------------------------------------'
	;
	;region_check_unique = intarr(sz[0],sz[1])
	;
	;final_cme_count = 0 ;initialise count of actual CMEs detected (not just potentials).
	;
	;if cme_count gt 1 then begin
	;
	;	print, 'cme_count is greater than 1'
	;
	;	for contour_count=0,n_elements(info)-1 do begin  ; info being from the contouring of cme_mask_dil above.
	;
	;		region_x = xy[0,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
	;	        region_y = xy[1,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
	;	        region_ind = polyfillv(region_x, region_y, sz[0], sz[1])
	;		region_check_unique[*,*] = 0
	;	        region_check_unique[region_ind] = 1
	;		cme_mask_thr_unique = cme_mask_thr * region_check_unique
	;
	;		if keyword_set(show) then begin
	;			tvscl, sigrange(cme_mask_thr_unique,/use_all)
	;			if keyword_set(pauses) then pause
	;		endif
	;
	;		region_check_unique_dil = dilate(region_check_unique, replicate(1,51,51))
	;
	;		if keyword_set(show) then begin
	;			tvscl, region_check_unique
	;			print, 'tvscl, region_check_unique'	
	;			if keyword_set(pauses) then pause
	;			tvscl, region_check_unique_dil
	;			print, 'region_check_unique_dil'
	;			if keyword_set(pauses) then pause
	;		endif
	;
	;		; Check if any of the flag_multiples contours overlaps this one so they can be grouped:
	;		for i=0,n_elements(flag_multiples)-1 do begin
	;			print, 'contour_count: ', contour_count & print, 'flag_multiples[i]: ', flag_multiples[i]
	;			help, info
	;			; Jumping down to avoid the case where the region being tested is compared with itself!
	;			if flag_multiples[i] eq contour_count then begin
	;				cme_mask_group = cme_mask_thr_unique
	;				goto, jump3
	;			endif
	;			test_region = intarr(sz[0],sz[1])
	;			test_region_x = xy[0,info[flag_multiples[i]].offset:(info[flag_multiples[i]].offset+info[flag_multiples[i]].n-1)]
	;			test_region_y = xy[1,info[flag_multiples[i]].offset:(info[flag_multiples[i]].offset+info[flag_multiples[i]].n-1)]
	;			test_region_ind = polyfillv(test_region_x, test_region_y, sz[0], sz[1])
	;			test_region[test_region_ind] = 1
	;			test_region_dil = dilate(test_region, replicate(1,51,51))
	;			if keyword_set(show) then begin
	;				tvscl, test_region
	;				print, 'tvscl, test_region'
	;				if keyword_set(pauses) then pause
	;				tvscl, test_region_dil
	;				print, 'tvscl, test_region_dil'
	;				if keyword_set(pauses) then pause
	;				tvscl, test_region_dil + region_check_unique_dil
	;				print, 'tvscl, test_region_dil + region_check_unique_dil'
	;				if keyword_set(pauses) then pause
	;			endif
	;			if max(test_region_dil + region_check_unique_dil) gt 1 then begin
	;				cme_mask_group = cme_mask_thr_unique + (test_region * cme_mask_thr)
	;				if keyword_set(show) then begin
	;					tvscl, cme_mask_group
	;					print, 'tvscl, cme_mask_group (cme_mask_thr_unique + test_region*cme_mask_thr)'
	;					if keyword_set(pauses) then pause
	;				endif
	;			endif else begin
	;				cme_mask_group = cme_mask_thr_unique
	;			endelse
	;			jump3:
	;		endfor
	;		;save, in, da, count, multmods, cme_mask_group, f='temp.sav'
	;		
	;		if n_elements(flag_multiples) eq 0 then cme_mask_group = cme_mask_thr_unique
	;
	;		delvarx, flag_multiples
	;
	;		; RUN_ALGORITHMS2.pro
	;
	;		if ~keyword_set(gail) then print, 'Running run_algorithms2_edges_tvscl.pro with cme_mask_group'
	;		cme_mask_group = cme_mask_thr ;since all the rest commented out above.
	;		if ~keyword_set(show) then begin
	;			run_algorithms2_edges_tvscl, in, da, count, multmods, cme_mask_group, edges, contour_count, out_dir, pa, heights, fail, /gail
	;		endif
	;		if keyword_set(show) && keyword_set(pauses) then $
	;			run_algorithms2_edges_tvscl, in, da, count, multmods, cme_mask_group, edges, contour_count, out_dir, pa, heights, fail, /show, /pauses
	;		if keyword_set(show) && ~keyword_set(pauses) then $
	;			run_algorithms2_edges_tvscl,in,da,count,multmods,cme_mask_group, edges, contour_count, out_dir, pa, heights, fail, /show
	;
	;		if ~keyword_set(gail) && ~keyword_set(show) then $
	;			run_algorithms2_edges_tvscl,in,da,count,multmods,cme_mask_group,edges,contour_count,out_dir,pa,heights,fail,/final_show	
	;		
	;		if fail eq 0 then begin
	;			pa_total[pa,count] = heights
	;			final_cme_count += 1
	;		endif
	;
	;		if ~keyword_set(gail) then begin
	;			;;;if contour_count eq n_elements(info)-1 then legend, 'CMEs detected: '+int2str(floor(final_cme_count))+'	of possible '+int2str(floor(cme_count)), /bottom, /right, charsize=2
	;			;;;if contour_count eq n_elements(info)-1 then legend, 'CMEs detected: '+int2str(floor(final_cme_count)), /bottom, /right, charsize=2
	;			;;;legend, 'CMEs detected: '+int2str(floor(final_cme_count)), /bottom, /right, charsize=2
	;			draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size, /device
	;			xyouts, 395, 990, in.date_obs, charsize=2, /device
	;			if keyword_set(pauses) then pause
	;		endif
	;
;	;		if count lt 10 then count_label='0'+int2str(count) else count_label=int2str(count)
;	;		if count_unique lt 10 then count_unique_label='0'+int2str(count_unique) else count_unique_label=int2str(count_unique)
;	;				
;	;		if ~keyword_set(no_png) && contour_count eq cme_count-1 then $
;	;			if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/CME_front_ell_'+count_label+'_'+count_unique_label+'_C3_tvscl.png'
;	;		if ~keyword_set(no_png) && contour_count eq cme_count-1 then $
;	;			if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/CME_front_ell_'+count_label+'_'+count_unique_label+'_C2_tvscl.png'
	;
	;		if ~keyword_set(no_png) && contour_count eq cme_count-1 then begin
	;			if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/CME_front_edges_'+strmid(in.filename,str_count,12)+'_C2.png'
	;			if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/CME_front_edges_'+strmid(in.filename,str_count,12)+'_C3.png'
	;		endif
	;
	;		;count_unique += 1
	;	
	;	endfor
	;
	;endif else begin
	
		contour_count = 0
	
		;if keyword_set(show) then begin
		;	loadct,0
		;	tvscl, cme_mask_thr & print, 'tvscl, cme_mask_thr'
		;	if keyword_set(pauses) then pause	
		;endif
		if ~keyword_set(gail) then print, 'Running run_algorithms2_edges_tvscl.pro with cme_mask_thr'
	
		if keyword_set(gail) then run_algorithms2_edges_tvscl,in,da,count,multmods,cme_mask_thr, edges, contour_count, out_dir, pa, heights, fail, /gail
		if ~keyword_set(show) then run_algorithms2_edges_tvscl,in,da,count,multmods,cme_mask_thr, edges, contour_count, out_dir, pa, heights, fail
		if keyword_set(show) && keyword_set(pauses) then run_algorithms2_edges_tvscl, in, da, count, multmods, cme_mask_thr, edges, contour_count, out_dir, pa, heights, fail, /show, /pauses
		if keyword_set(show) && ~keyword_set(pauses) then run_algorithms2_edges_tvscl,in,da,count,multmods,cme_mask_thr, edges, contour_count, out_dir, pa, heights, fail, /show
	
		if ~keyword_set(gail) && ~keyword_set(show) then run_algorithms2_edges_tvscl,in,da,count,multmods,cme_mask_thr,edges,contour_count,out_dir,pa,heights,fail,/final_show	
	
		if fail eq 0 then begin
			pa_total[pa,count] = heights
	;		final_cme_count += 1
		endif
	
		;;;legend, 'CMEs detected: '+int2str(floor(final_cme_count))+'	of possible: '+int2str(floor(cme_count)), /bottom, /right, charsize=2
		;;;legend, 'CMEs detected: '+int2str(floor(final_cme_count)), /bottom, /right, charsize=2
		if ~keyword_set(gail) then begin
			draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size, /device
			xyouts, 395, 990, in.date_obs, charsize=2, /device
		endif

;		if count lt 10 then count_label='0'+int2str(count) else count_label=int2str(count)
		
;		if ~keyword_set(no_png) then if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/CME_front_ell_'+count_label+'_C3_tvscl.png'
;		if ~keyword_set(no_png) then if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/CME_front_ell_'+count_label+'_C2_tvscl.png'

		if ~keyword_set(no_png) && ~keyword_set(gail) then begin
			;if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/CME_front_edges_'+strmid(in.filename,str_count,12)+'_C2.png'	
			if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then x2png, out_dir+'/CME_front_edges_'+strmid(in.filename,0)+'_C2.png'	
			;if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/CME_front_edges_'+strmid(in.filename,str_count,12)+'_C3.png'	
			if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/CME_front_edges_'+strmid(in.filename,0)+'_C3.png'	
		endif
	
	;endelse
	
	jump2:
	
	;save, in, da, f=out_dir+'/in_da_'+strmid(in.filename,str_count,16)+'.sav'
	
	count += 1

endwhile
	
;save, list_total, f='list_total.sav'

;shifting pa_total so it starts at solar north
temp = pa_total
temp[0:89,*] = pa_total[270:359,*]
temp[90:359,*] = pa_total[0:269,*]
pa_total = temp
delvarx,temp

if ~keyword_set(gail) then print, 'saving pa_total'
save, pa_total, f=out_dir+'/pa_total_'+strmid(in.filename,str_count,8)+'.sav'

	
end
