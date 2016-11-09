; Created	2012-09-20	code to call in the det_info_str_YYYYMMDD.sav of the preceding day and remove any portions of the current day's detection stack that correspond to yesterday's CMEs.

;Last edited	2012-12-12	to include the keyword debug.


function rm_prev_stack, det_stack_fl, in_dir, out_check, debug=debug

if keyword_set(debug) then begin
	print, '***'
	print, 'rm_prev_stack.pro'
	print, '***'
	pause
endif

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
; Calculate the previous day
prev_date = anytim(secs-3600,/date_only,/ecs)
prev_yy = strmid(prev_date,0,4)
prev_mm = strmid(prev_date,5,2)
prev_dd = strmid(prev_date,8,2)
prev_date_read = prev_yy+prev_mm+prev_dd

dir = strmid(in_dir,0,strlen(in_dir)-11)
prev_det_info_str = file_search(dir+'/'+prev_yy+'/'+prev_mm+'/'+prev_dd+'/det_info_str*.sav')
if keyword_set(debug) then begin
	print, 'date ', date
	print, 'prev_date_read ', prev_date_read
	print, 'dir ', dir
	print, 'prev ', dir+'/'+prev_yy+'/'+prev_mm+'/'+prev_dd+'/det_info_str*.sav'
	help, prev_det_info_str
	print, 'prev_det_info_str ', prev_det_info_str
	pause
endif
if strlen(prev_det_info_str) eq 0 then begin
	out_check = 1
	if keyword_set(debug) then print, 'goto, jump_end'
	goto, jump_end
endif

test = where(strmid(file_basename(prev_det_info_str),13,8) eq prev_date_read)
if test ne [-1] then begin
	if keyword_set(debug) then print, 'Restoring ', prev_det_info_str[test]
	restore, prev_det_info_str[test]
endif

restore, det_stack_fl
; So now both the det_stack and preceding day's det_info_str have been restored.
pa_total = det_stack.stack
clean_pa_total, pa_total, pa_mask, debug=debug
pa_total *= pa_mask
separate_pa_total, pa_total, det_info, final_pa_total, debug=debug

; Check where end_times on det_info_str are in current day
; If not, adjust the structure info to just go to the end of the current day (not worry about overlap to following day).
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

count = 0
for i=0,n_elements(endtimes)-1 do begin
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
		pause
	endif

	if pa1 gt pa2 then pa2 += 360
	; So remove the part of the det_stack.stack that most fills these angular widths up to the end_im_no (corresponding to endtimes[i]).
	pa_portion=final_pa_total[pa1+180:pa2+180,0:end_im_no]
	if n_elements(size(pa_portion,/dim)) lt 2 then begin
		ind = where(pa_portion gt 0)
		if ind eq [-1] then goto, jump2
		temp_pa_portion = pa_portion
		temp_pa_portion[ind] = 2
	endif else begin		
		if n_elements(size(pa_portion,/dim)) eq 2 then begin
			ind = where(pa_portion[*,1] gt 0)
			if ind eq [-1] then goto, jump2
			temp_pa_portion = pa_portion
			temp_pa_portion[ind,1] = 2
		endif else begin
			ind = where(pa_portion[*,2] gt 0)
			if ind eq [-1] then goto, jump2
			temp_pa_portion = pa_portion
			temp_pa_portion[ind,2] = 2
		endelse
	endelse
	roi = where(temp_pa_portion eq 2)
	;print, roi
	inds = region_grow(pa_portion, roi)
	;help, inds
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
	if count gt 0 && count ne n_elements(pa1_in) then goto, jump1
endfor

new_stack_mask = final_pa_total[180:539,*]
pa_total *= new_stack_mask

jump2:

return, pa_total

if keyword_set(debug) then begin
	plot_image, pa_total, tit='pa_total at the end of rm_prev_stack.pro'
	pause
endif

jump_end:

end
