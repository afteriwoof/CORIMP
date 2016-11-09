; Created	2012-07-23	from find_pa_heights_all_redo.pro but for the model input of multicme_model_cluster


;INPUT:		fls		- list of fits files
;		pa_total	- the detection stage image (360, *), having already been cleaned with clean_pa_total
;		det_info	- the output of separate_pa_total
;		det_fls		- list of dets*sav fls
;		stack_fls	- from saved file det_stack_yyyymmdd.sav

pro find_pa_heights_all_redo_model, fls_in, pa_total, det_info, det_fls, stack_fls, out_dir, plot_prof=plot_prof, loud=loud, pauses=pauses

if n_elements(fls_in) ne n_elements(det_fls) then begin
	print, 'Number of files do not match det_fls'
	if keyword_set(pauses) then pause
	in_times = strmid(file_basename(fls_in), 28, 15)
	det_times = strmid(file_basename(det_fls), 5, 15)
	fls_loc = where(in_times eq det_times[0])
	for i=1,n_elements(det_times)-1 do begin
		fls_loc = [fls_loc, where(in_times eq det_times[i])]
	endfor
	fls = fls_in[fls_loc]
endif

mreadfits_corimp, fls_in, all_hdrs
mreadfits_corimp, fls, hdrs

if keyword_set(plot_prof) then !p.multi=[0,1,2] else !p.multi=0

sz = size(det_info, /dim)

if n_elements(stack_fls) gt 1 then begin
	for j=0,n_elements(stack_fls)-1 do begin & $
		restore, stack_fls[j] & $
		; Combining the det_stack.list arrays while making sure that any skips in them are maintained across the combination.
		if j eq 0 then begin & $
			;filenames = det_stack.filenames & $
			;date_obs = det_stack.date_obs & $
			plots_list = det_stack.list & $
			pmm, plots_list & $
			list_gap = n_elements(det_stack.filenames) - max(det_stack.list) & $
			print, list_gap & $
		endif else begin & $
			;filenames = [filenames, det_stack.filenames] & $
			;date_obs = [date_obs, det_stack.date_obs] & $
			plots_list = [plots_list, det_stack.list+max(plots_list)+list_gap] & $
			pmm, plots_list & $
			list_gap = n_elements(det_stack.filenames) - max(det_stack.list) & $
			print, list_gap & $
		endelse & $
	endfor
endif else begin
	restore, stack_fls
	plots_list = det_stack.list
endelse

if size(sz,/dim) eq 1 then loop_end=0 else loop_end=sz[1]-1

;for i=0,0 do begin
for i=0,loop_end do begin
;looping over the separate CME detections
		

	;Open new file for saving info
	help, det_info, hdrs
	print, det_info[2,i]
	print, all_hdrs[det_info[2,i]].date_obs
	file_out = out_dir+'/'+anytim(all_hdrs[det_info[2,i]].date_obs,/ccsds,/date_only)+'_'+int2str(i)+'.txt'
	print, 'file_out ', file_out
	openw, lun, /get_lun, file_out, error=err, width=500
	printf, lun, '# DATE & TIME, HEIGHT, ANGLE'
	printf, lun, '#'
	free_lun, lun

	cme_prof = intarr((det_info[3,i]-det_info[2,i]+1),200) ;scaled down from height 2e4

	for k_count=det_info[0,i],det_info[1,i] do begin
	;looping over the relevant angles in the detection
		if keyword_set(loud) then print, 'Position angle is ', (k_count mod 360)

		k = k_count
		if k gt 359 then k-=360
		if k lt 0 then k+=360

		if keyword_set(loud) then begin
			plot_image, pa_total, xtit='Position Angle', ytit='Image No. (time)'
			plots, [det_info[0,i],det_info[0,i]], [det_info[2,i],det_info[3,i]], line=1
                	plots, [det_info[1,i],det_info[1,i]], [det_info[2,i],det_info[3,i]], line=1
                	plots, [det_info[0,i],det_info[1,i]], [det_info[2,i],det_info[2,i]], line=1
                	plots, [det_info[0,i],det_info[1,i]], [det_info[3,i],det_info[3,i]], line=1
			plots, [k,k],[det_info[2,i],det_info[3,i]]
			if keyword_set(pauses) then pause
		endif

		; The headers corresponding to this region of CME detection
		cme_hdrs = all_hdrs[det_info[2,i]:det_info[3,i]]
		save, cme_hdrs, f=out_dir+'/cme_hdrs_'+int2str(i)+'.sav'	

		prof = pa_total[k,det_info[2,i]:det_info[3,i]]
		
		if keyword_set(plot_prof) then plot, prof, psym=2, yr=[0,20000], /ys, xtit='Image No. (time)', ytit='Height (arcsec)'
		if keyword_set(pauses) then pause

		plots_list_count = 0

		green_counter = 0

		for j=det_info[2,i], det_info[3,i] do begin
		;looping over the detections at this angle
	
			if where(plots_list ge det_info[2,i] and plots_list le det_info[3,i]) eq [-1] then goto, jump $
				else plots_list_j = plots_list[where(plots_list ge det_info[2,i] and plots_list le det_info[3,i])]

			offset = where(plots_list eq plots_list_j[0])

			if keyword_set(loud) then begin
				print, 'k ', k
				;print, 'plots_list ', plots_list
				print, 'j ', j
				print, 'det_info[2,i], det_info[3,i] ', det_info[2,i], det_info[3,i]
				;print, 'plots_list_j ', plots_list_j
				print, 'offset ', offset
				set_line_color
				if keyword_set(plot_prof) then plots, j-det_info[2,i], 0, psym=1, color=2 else plots, k, j, psym=1, color=2
			endif

			if j gt det_info[3,i] then goto, jump

			if where(plots_list_j eq j) eq [-1] then begin
				if keyword_set(loud) then print, 'no cme?'
				if keyword_set(pauses) then pause
				goto, jump
			endif

			if keyword_set(loud) then begin	
				if keyword_set(plot_prof) then plots, j-det_info[2,i], 0, psym=2, color=4 else plots, k, j, psym=2, color=4
			endif

			if green_counter eq 0 then green_counter+=offset

			if keyword_set(loud) then print, 'green_counter ', green_counter & print, 'hdrs[green_counter].date_obs ', hdrs[green_counter].date_obs

			if keyword_set(loud) then print, 'restore ', det_fls[green_counter]
			restore, det_fls[green_counter]

			in = hdrs[green_counter]
			if in.xcen le 0 then in.xcen=in.crpix1
			if in.ycen le 0 then in.ycen=in.crpix2

			green_counter += 1

		
			; Find associated height at this angle for this detection(timestep).
			; shift the angle due to how recpol is offset from solar north
			k_shift = (k+90) mod 360
			if keyword_set(loud) then print, 'k_shift ', k_shift

			recpol, dets.edges[0,*]-in.xcen, dets.edges[1,*]-in.ycen, res_r, res_theta, /deg
			recpol, dets.front[0,*]-in.xcen, dets.front[1,*]-in.ycen, r_out, a_out, /deg
	
			ind = where(round(res_theta) eq k_shift,cnt)
			ind2 = where(round(a_out) eq k_shift,cnt2)

			if cnt ne 0 then begin
				h = res_r[ind]*in.pix_size
				print, 'h ', h
				if keyword_set(loud) then begin
					if keyword_set(plot_prof) then plots, replicate(j-det_info[2,i],n_elements(h)), h, psym=2, color=5
				endif
				cme_prof[j-det_info[2,i],round(h/100.)] += 1
			endif
			if cnt2 ne 0 then begin
				hf = r_out[ind2]*in.pix_size
				print, 'hf ', hf
				if keyword_set(loud) then begin
					if keyword_set(plot_prof) then plots, j-det_info[2,i], hf, psym=2, color=6
				endif
				cme_prof[j-det_info[2,i],round(hf/100.)] += 1
				; Save out the height info to a text file
				tempdate = strmid(in.date_obs,0,10)
				temptime = strmid(in.date_obs,11,8)
				datetime = tempdate+'T'+temptime
	                        openu, lun, file_out, /append
				k_countmod = k_count mod 360
				help, datetime, hf, k_countmod
	                        printf, lun, datetime, hf[0], k_countmod
       	                	free_lun, lun
			endif

			jump:

			if keyword_set(pauses) then pause
		
		endfor

		if keyword_set(pauses) then pause
	
	endfor

	save, cme_prof, f=out_dir+'/cme_prof_'+int2str(i)+'.sav'
	print, 'save, cme_prof ', out_dir+'/cme_prof_'+int2str(i)+'.sav'
	if keyword_set(pauses) then pause

endfor



end
