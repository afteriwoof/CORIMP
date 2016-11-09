; Created	2013-01-23	from rm_prev_stack.pro but to call in the saved rm_date_yyyymmdd.sav files to remove relevant rois.

;Last edited	2013-03-21	to fix the region_grow portion of the code.


function rm_prev_date_gail, det_stack_fl, in_dir, out_check, debug=debug

;if keyword_set(debug) then begin
	print, '***'
	print, 'rm_prev_date.pro'
	print, '***'
;	pause
;endif

out_check = 0
;in_dir = strmid(file_basename(det_stack_fl),10,8)
;in_dir = '20110112-14' ;for this test case

;prev_det_info_str = file_Search(in_dir+'/det_info_str*sav')

date = strmid(file_basename(det_stack_fl),10,8)
date = date[0]
yy = strmid(date,0,4)
mm = strmid(date,4,2)
dd = strmid(date,6,2)
date = yy+'/'+mm+'/'+dd
secs = anytim(date,/sec)
; Determine the previous days to remove
dir = strmid(in_dir,0,strlen(in_dir)-11)
prev_dates = file_search(in_dir+'/rm_date*sav')
if keyword_set(debug) then print, 'prev_dates: ', prev_dates
if strlen(prev_dates[0]) eq 0 then begin
	if keyword_set(debug) then print, 'Setting out_check=1 and goto, jump_end'
	out_check = 1
	if keyword_set(debug) then print, 'goto, jump_end'
	goto, jump_end
endif

for k=0,n_elements(prev_dates)-1 do begin
	restore, prev_dates[k] ;restores rm_date
	if keyword_set(debug) then begin
		print, 'rm_date ', rm_date
		print, file_search(dir+'/'+rm_date+'/det_info_str*.sav')
	endif
	if k eq 0 then prev_det_info_structures = file_search(dir+'/'+rm_date+'/det_info_str*.sav') else $
		prev_det_info_structures = [prev_det_info_structures, file_search(dir+'/'+rm_date+'/det_info_str*.sav')]
endfor

if keyword_set(debug) then begin
	help, prev_det_info_structures
	print, 'prev_det_info_structures: '
	print, prev_det_info_structures
	pause
endif

if n_elements(prev_det_info_structures) eq 1 && strlen(prev_det_info_structures) eq 0 then begin
	out_check=1
	goto, jump_end
endif

restore, det_stack_fl
; So now both the det_stack and preceding day's det_info_str have been restored.
pa_total = det_stack.stack
clean_pa_total_gail, pa_total, pa_mask, debug=debug
pa_total *= pa_mask
separate_pa_total, pa_total, det_info, final_pa_total, debug=debug

if keyword_set(debug) then begin
	print, 'prev_det_info_structures ', prev_det_info_structures
	print, 'date ', date
endif

for k=0,n_elements(prev_det_info_structures)-1 do begin

	prev_det_info_str = prev_det_info_structures[k]

	if file_exist(prev_det_info_str) then restore, prev_det_info_str else goto, jump2

	; Check where end_times on det_info_str are in current day
	; If not, adjust the structure info to just go to the end of the current day (not worry about overlap to following day).
	if keyword_set(debug) then print, 'det_info_str.end_times ', det_info_str.end_times
	if where(date eq strmid(det_info_str.end_times,0,10)) eq [-1] then begin
		temp_endtime = det_stack.date_obs[n_elements(det_stack.date_obs)-1]
		if keyword_set(debug) then begin
			print, 'temp_endtime ', temp_endtime
			print, 'det_info_str.end_times ', det_info_str.end_times
		endif
		if where(anytim(det_info_str.end_times) gt anytim(temp_endtime)) ne [-1] then begin
			det_info_str.end_times[where(anytim(det_info_str.end_times) gt anytim(temp_endtime))] = temp_endtime
			endtimes = det_info_str.end_times[where(date eq strmid(det_info_str.end_times,0,10))]
		endif else begin
			if keyword_set(debug) then print, 'setting out_check=1 and goto, jump_end - second'
			out_check = 1
			goto, jump_end
		endelse
	endif else begin
		endtimes = det_info_str.end_times[where(date eq strmid(det_info_str.end_times,0,10))]
	; Note that some of the endtimes might be the same!
	endelse
	
	if keyword_set(debug) then begin
		print, 'endtimes: ', endtimes
		pause
	endif
	
	for i=0,n_elements(endtimes)-1 do begin
		count = 0
		if keyword_set(debug) then print, 'count ', count, ' and n_elements(pa1_in) ', n_elements(pa1_in)
		pa1 = det_info_str.pos_ang1[where(endtimes[i] eq det_info_str.end_times)]
		pa2 = det_info_str.pos_ang2[where(endtimes[i] eq det_info_str.end_times)]
		; In case some endtimes are the same, and more than one pa1 and pa2 exist, loop through them:
		if n_elements(pa1) gt 1 then begin
			pa1_in = pa1
			pa2_in = pa2
			jump1:
			pa1 = pa1_in[count]
			pa2 = pa2_in[count]
			count += 1
		endif
		end_im_no = where(endtimes[i] eq det_stack.date_obs)
		if keyword_set(debug) then begin
			print, 'count ', count
			print, 'end_im_no ', end_im_no
			print, 'pa1 ', pa1
			print, 'pa2 ', pa2
			horline, end_im_no
			verline, pa1+180
			verline, pa2+180
			pause
		endif
		if end_im_no lt 2 then goto, jump3 ;since the region_grow and label_region have trouble with small arrays.
	
		if pa1 gt pa2 then pa2 += 360
		; So remove the part of the det_stack.stack that most fills these angular widths up to the end_im_no (corresponding to endtimes[i]).
		pa_portion=final_pa_total[pa1+180:pa2+180,0:end_im_no]
		if keyword_set(debug) then begin
			plot_image, pa_portion, tit='pa_portion pre region_grow'
			pause
			print, 'n_elements(size(pa_portion,/dim)) ', n_elements(size(pa_portion,/dim))
		endif
		save, pa_portion, f='temp.sav'
		if n_elements(size(pa_portion,/dim)) lt 2 then begin
			ind = where(pa_portion gt 0)
			help, ind
			if ind eq [-1] then goto, jump2
			temp_pa_portion = pa_portion
			temp_pa_portion[ind] = 2
			; and add in below that part
                        temp_ind = where(pa_portion[*,0] gt 0)
		endif else begin		
			ind = where(pa_portion[*,1] gt 0)
			help, ind
			if ind eq [-1] then goto, jump2
			temp_pa_portion = pa_portion
			temp_pa_portion[ind,1] = 2
			; and add in below that part
			temp_ind = where(pa_portion[*,0] gt 0)
		endelse
		if keyword_set(debug) then plot_image, temp_pa_portion, tit='temp_pa_portion'
		roi = where(temp_pa_portion eq 2)
		inds = region_grow(pa_portion, roi)
		if temp_ind ne [-1] then inds = [temp_ind, inds]
		if keyword_set(debug) then pause
		if keyword_set(debug) then help, roi, pa_portion, inds
		;need to test the roi for its angular width to feed back
		if inds ne [-1] then begin
			arr_inds = array_indices(temp_pa_portion,inds)
			new_pa1 = pa1 + min(arr_inds[0,*])
			new_pa2 = pa1 + max(arr_inds[0,*])
			if new_pa1 lt pa1 OR new_pa2 gt pa2 then print, '*** ANGULAR WIDTH INCREASES ***'
			pa_portion[inds] = 0
			final_pa_total[pa1+180:pa2+180,0:end_im_no] = pa_portion
			if keyword_set(debug) then begin
				plot_image, final_pa_total, tit='final_pa_total[pa1+180:pa2+180,0:end_im_no] = pa_portion'
				pause
			endif
		endif
		if count gt 0 && count ne n_elements(pa1_in) then begin
			if keyword_set(debug) then print, 'goto, jump1' & goto, jump1
		endif
		jump3:
	endfor

	; re-wrap the regions back to original size.
	temp_portion = intarr(360,(size(final_pa_total,/dim))[1])
	
	temp_portion[0:179,*] = final_pa_total[540:*,*]
	temp_portion[180:*,*] = final_pa_total[0:179,*]
	temp_inds = where(temp_portion eq 1)
	delvarx, temp_portion
	new_stack_mask = final_pa_total[180:539,*]
	if temp_inds ne [-1] then new_stack_mask[temp_inds] = 1
	delvarx, temp_inds
	pa_total *= new_stack_mask
	
	jump2:

endfor

if keyword_set(debug) then begin
	plot_image, pa_total, tit='pa_total at the end of rm_prev_date.pro'
	pause
endif

return, pa_total

jump_end:

end
