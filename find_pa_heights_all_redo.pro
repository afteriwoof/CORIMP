; Created	2012-07-26	from find_pa_heights_all_redo_model.pro but in place of find_pa_heights_all_redo_backup20120726.pro

; Last Edited	2012-12-05	adding keyword old_data, for the new format of data that's read in.
;		2012-12-12	to include keyword debug.
;		2013-07-16	to work for stereo data, adding keywords.

;INPUT:		fls		- list of fits files
;		pa_total	- the detection stage image (360, *), having already been cleaned with clean_pa_total
;		det_info	- the output of separate_pa_total
;		det_fls		- list of dets*sav fls
;		stack_fls	- from saved file det_stack_yyyymmdd.sav

; KEYWORDS	old_data	- for the old format of data naming convention.
;		debug		- debugging

pro find_pa_heights_all_redo, fls_in, pa_total, det_info, det_fls, stack_fls, out_dir, plot_prof=plot_prof, loud=loud, pauses=pauses, old_data=old_data, debug=debug, stereo=stereo

if keyword_set(debug) then begin
	print, '***'
	print, 'find_pa_heights_all_redo.pro'
	print, '***'
endif

if ~keyword_set(old_data) then str_count = 23 else str_count = 9

if n_elements(fls_in) ne n_elements(det_fls) then begin
	if keyword_set(debug) then print, 'Number of files do not match det_fls'
	if keyword_set(pauses) then pause
	in_times = strmid(file_basename(fls_in), str_count, 15)
	det_times = strmid(file_basename(det_fls), 5, 15)
	fls_loc = where(in_times eq det_times[0])
	if keyword_set(debug) then begin
		help, in_times
		print, in_times[0]
		help, det_times
		print, det_times[0]
		pause
	endif
	for i=1,n_elements(det_times)-1 do fls_loc = [fls_loc, where(in_times eq det_times[i])]
	fls = fls_in[fls_loc]
endif else begin
	fls = fls_in
endelse

mreadfits_corimp, fls_in, all_hdrs
mreadfits_corimp, fls, hdrs

if keyword_set(plot_prof) then !p.multi=[0,1,2] else !p.multi=0

sz = size(det_info, /dim)

if keyword_set(debug) then print, 'n_elements(stack_fls) ', n_elements(stack_fls), stack_fls
if n_elements(stack_fls) gt 1 then begin
	for j=0,n_elements(stack_fls)-1 do begin & $
		restore, stack_fls[j] & $
		; Combining the det_stack.list arrays while making sure that any skips in them are maintained across the combination.
		if j eq 0 then begin & $
			;filenames = det_stack.filenames & $
			;date_obs = det_stack.date_obs & $
			plots_list = det_stack.list & $
			list_gap = n_elements(det_stack.filenames) - max(det_stack.list) & $
		endif else begin & $
			;filenames = [filenames, det_stack.filenames] & $
			;date_obs = [date_obs, det_stack.date_obs] & $
			plots_list = [plots_list, det_stack.list+max(plots_list)+list_gap] & $
			list_gap = n_elements(det_stack.filenames) - max(det_stack.list) & $
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
	if i lt 10 then  file_out = out_dir+'/'+anytim(all_hdrs[det_info[2,i]].date_obs,/ccsds,/date_only)+'_0'+int2str(i)+'.txt' $
		else file_out = out_dir+'/'+anytim(all_hdrs[det_info[2,i]].date_obs,/ccsds,/date_only)+'_'+int2str(i)+'.txt'
	if keyword_set(debug) then print, 'file_out ', file_out
	openw, lun, /get_lun, file_out, error=err, width=500
	printf, lun, '# DATE & TIME, HEIGHT (arcsecs), ANGLE (degrees)'
	printf, lun, '#'
	free_lun, lun

	; Scale down from height of new data, which goes out to 25 R_Sun.
	cme_prof = intarr((det_info[3,i]-det_info[2,i]+1),250)

	if det_info[0,i] gt det_info[1,i] then loop_inds = [indgen(360-det_info[0,i])+det_info[0,i], indgen(det_info[1,i])] $
		else loop_inds = indgen(det_info[1,i]-det_info[0,i])+det_info[0,i]
	;check loop_inds doesn't wrap to inds less than 0
	temp = where(loop_inds lt 0, tempcnt)
	if tempcnt ne 0 then loop_inds[temp] += 360
	delvarx, temp, tempcnt
	if keyword_set(debug) then begin
		print, 'det_info[0,i] ', det_info[0,i]
		print, 'det_info[1,i] ', det_info[1,i]
		print, 'loop_inds ', loop_inds
	pause
	endif
	for k_loop=0,n_elements(loop_inds)-1 do begin
;	for k_count = det_info[0,i],det_info[1,i] do begin
	;looping over the relevant angles in the detection
		k_count = loop_inds[k_loop]
;		k = k_count
;		if k gt 359 then k-=360
;		if k lt 0 then k+=360

		if keyword_set(loud) OR keyword_set(debug) then begin
			print, 'k_loop ', k_loop
                        print, 'k_count ', k_count
                        print, 'Position angle is ', (k_count mod 360)
			plot_image, pa_total, xtit='Position Angle', ytit='Image No. (time)'
			set_line_color
			print, 'det_info[*,i]'
			print, det_info[*,i]
			plots, [det_info[0,i],det_info[0,i]], [det_info[2,i],det_info[3,i]], color=5
                	plots, [det_info[1,i],det_info[1,i]], [det_info[2,i],det_info[3,i]], color=5
                	plots, [det_info[0,i],det_info[1,i]], [det_info[2,i],det_info[2,i]], color=5
                	plots, [det_info[0,i],det_info[1,i]], [det_info[3,i],det_info[3,i]], color=5
			plots, [k_count,k_count],[det_info[2,i],det_info[3,i]]
			help, all_hdrs
	                print, 'det_info ', det_info
	                print, 'det_info[2,i] ', det_info[2,i]
	                print, 'det_info[3,i] ', det_info[3,i]
			if keyword_set(pauses) then pause
		endif

		; The headers corresponding to this region of CME detection
		if keyword_set(debug) then begin
			help, all_hdrs
			print, 'det_info[2,i]&[3,i]: ', det_info[2,i], det_info[3,i]
		endif
		if det_info[3,i] lt n_elements(all_hdrs) then begin
			cme_hdrs = all_hdrs[det_info[2,i]:det_info[3,i]]
			if i lt 10 then save, cme_hdrs, f=out_dir+'/cme_hdrs_0'+int2str(i)+'.sav' else save, cme_hdrs, f=out_dir+'/cme_hdrs_'+int2str(i)+'.sav'
		endif

		prof = pa_total[k_count,det_info[2,i]:det_info[3,i]]
		
		if keyword_set(stereo) then y_range=[0,1.6e4] else y_range=[0,2.e4]
		if keyword_set(plot_prof) then plot, prof, psym=2, yr=y_range, /ys, xtit='Image No. (time)', ytit='Height (arcsec)'
		if keyword_set(pauses) then pause

		plots_list_count = 0

		green_counter = 0

		for j=det_info[2,i], det_info[3,i] do begin
		;looping over the detections at this angle

			if where(plots_list ge det_info[2,i] and plots_list le det_info[3,i]) eq [-1] then goto, jump $
				else plots_list_j = plots_list[where(plots_list ge det_info[2,i] and plots_list le det_info[3,i])]

			offset = where(plots_list eq plots_list_j[0])

			if keyword_set(loud) OR keyword_set(debug) then begin
				print, 'k_count ', k_count
				;print, 'plots_list ', plots_list
				print, 'j ', j
				print, 'det_info[2,i], det_info[3,i] ', det_info[2,i], det_info[3,i]
				;print, 'plots_list_j ', plots_list_j
				print, 'offset ', offset
				set_line_color
				if keyword_set(plot_prof) then plots, j-det_info[2,i], 0, psym=1, color=2 else plots, k_count, j, psym=1, color=2
			endif

			if j gt det_info[3,i] then goto, jump

			if where(plots_list_j eq j) eq [-1] then begin
				if keyword_set(loud) OR keyword_set(debug) then print, 'no cme?'
				if keyword_set(pauses) then pause
				goto, jump
			endif

			if keyword_set(loud) OR keyword_set(debug) then begin	
				if keyword_set(plot_prof) then plots, j-det_info[2,i], 0, psym=2, color=4 else plots, k_count, j, psym=2, color=4
			endif

			if green_counter eq 0 then green_counter+=offset

			if keyword_set(loud) OR keyword_set(debug) then begin
				print, 'green_counter ', green_counter
				print, 'hdrs[green_counter].date_obs ', hdrs[green_counter].date_obs
				print, 'restore ', det_fls[green_counter]
			endif
			restore, det_fls[green_counter]

			in = hdrs[green_counter]
			if in.xcen le 0 then in.xcen=in.crpix1
			if in.ycen le 0 then in.ycen=in.crpix2

			green_counter += 1

		
			; Find associated height at this angle for this detection(timestep).
			; shift the angle due to how recpol is offset from solar north
			;k_shift = (k+270) mod 360
			k_shift = (k_count+90) mod 360
			if keyword_set(loud) OR keyword_set(debug) then print, 'k_shift ', k_shift

			recpol, dets.edges[0,*]-in.xcen, dets.edges[1,*]-in.ycen, res_r, res_theta, /deg
			recpol, dets.front[0,*]-in.xcen, dets.front[1,*]-in.ycen, r_out, a_out, /deg
	
			ind = where(round(res_theta) eq k_shift,cnt)
			ind2 = where(round(a_out) eq k_shift,cnt2)

			if cnt ne 0 then begin
				h = res_r[ind]*in.pix_size
				if keyword_set(loud) OR keyword_set(debug) then begin
					if keyword_set(plot_prof) then plots, replicate(j-det_info[2,i],n_elements(h)), h, psym=2, color=5
				endif
				cme_prof[j-det_info[2,i],round(h/100.)] += 1
			endif
			if cnt2 ne 0 then begin
				hf = r_out[ind2]*in.pix_size
				if keyword_set(loud) OR keyword_set(debug) then begin
					if keyword_set(plot_prof) then plots, j-det_info[2,i], hf, psym=2, color=6
				endif
				cme_prof[j-det_info[2,i],round(hf/100.)] += 1
				; Save out the height info to a text file
				tempdate = strmid(in.date_obs,0,10)
				temptime = strmid(in.date_obs,11,8)
				datetime = tempdate+'T'+temptime
	                        openu, lun, file_out, /append
				;k_countmod = k_count mod 360
				;k_countmod = (k_count+180) mod 360
	                        if keyword_set(loud) OR keyword_set(debug) then print, 'The height being saved in text file is in yellow ', hf[0]
				if keyword_set(plot_prof) then plots, replicate(j-det_info[2,i],n_elements(h)), hf[0], psym=6, color=2
				;printf, lun, datetime, hf[0], k_countmod
       	                	printf, lun, datetime, hf[0], k_count
				free_lun, lun
			endif

			jump:

			;if keyword_set(pauses) then pause
		
		endfor

		if keyword_set(pauses) then pause
	
	endfor

	if loop_end ge 100 then print, 'ALERT: Naming of cme_prof_NN.sav files will be wrong because loop_end is ge 100'
	if i lt 10 then begin
		save, cme_prof, f=out_dir+'/cme_prof_0'+int2str(i)+'.sav'
		if keyword_set(debug) then print, 'save, cme_prof ', out_dir+'/cme_prof_0'+int2str(i)+'.sav'
	endif else begin
		save, cme_prof, f=out_dir+'/cme_prof_'+int2str(i)+'.sav'
		if keyword_set(debug) then print, 'save, cme_prof ', out_dir+'/cme_prof_'+int2str(i)+'.sav'
	endelse

	if keyword_set(pauses) OR keyword_set(debug) then pause

endfor


; Add in segment that renames the yyyy-mm-dd_##.txt to yyyymmdd_hhmmss.txt for ease of html creation later.
extn_count = 0 ;initialise the variable that checks if more than one CME detection has the same start time.
cme_prof_fls = file_search(out_dir+'/*txt')
for i=0,n_elements(cme_prof_fls)-1 do begin
	readcol, cme_prof_fls[i], datetimes, heights, angs, f='(A,D,I)', nlines=nlines
	if nlines lt 3 then goto, jump2 ; if the txt file is empty skip reading it.
	clean_heights, datetimes, heights, angs
	t = (datetimes[where(anytim(datetimes) eq min(anytim(datetimes)))])[0]
        t = strmid(t,0,4)+strmid(t,5,2)+strmid(t,8,2)+'_'+strmid(t,11,2)+strmid(t,14,2)+strmid(t,17,2)
        if file_exist(out_dir+'/'+t+'.txt') eq 1 then begin
		extn_count = n_elements(file_search(out_dir+'/'+t+'*.txt'))
		extn = '_'+int2str(extn_count)
	endif else begin
		extn = ''
	endelse
	print, 'spawn, cp '+cme_prof_fls[i]+' '+out_dir+'/'+t+extn+'.txt'
        spawn, 'cp '+cme_prof_fls[i]+' '+out_dir+'/'+t+extn+'.txt'
	spawn, 'mkdir -p '+out_dir+'/yyyy-mm-dd_NN'
	spawn, 'mv '+cme_prof_fls[i]+' '+out_dir+'/yyyy-mm-dd_NN/'
	jump2:
endfor
;other_fls = file_search(out_dir+'/*sav')
;for i=0,n_elements(other_fls)-1 do spawn, 'mv '+other_fls[i]+' '+out_dir+'/org/'



end
