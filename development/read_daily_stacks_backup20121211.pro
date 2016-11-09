; Created	2012-09-19	to read in intervals of 1 day and output detection stack info, but account for overlaps that need adjoining days padding.


; NOTES to be done on this code:
; 1)	Loop for more than just a second day
; 2)	DONE: Remove the detections that cross into a second day from the next run of that day
; 3)	Back-adjust the angular widths for changes to them on the proceeding days.

; INPUT		stack_fls -		the det_stack*.sav files.
;		in_dir -	the in_dir from automated_kins.pro 'years' path.


pro read_daily_stacks, stack_fls, in_dir, show=show


if keyword_set(show) then begin
	loadct, 39
	set_line_color
	!p.multi = [0,3,2]
	!p.charsize=2
endif

for i=0,n_elements(stack_fls)-2 do begin

	if keyword_set(show) then begin
		window
		!p.multi=[0,3,2]
	endif
	print, 'i ', i

	; Generate the path to the out_dir
	dir = strmid(in_dir,0,strlen(in_dir)-5)
	date = strmid(file_basename(stack_fls[i]),10,8)
	yy = strmid(date,0,4)
	mm = strmid(date,4,2)
	dd = strmid(date,6,2)
	date = yy+'/'+mm+'/'+dd

	out_dir = dir+'/'+date
	print, 'out_dir: ', out_dir
	stack_fls_day = strmid(file_basename(stack_fls[i]),10,8)
        print, 'Day: ', stack_fls_day

        restore, stack_fls[i]
        print, 'Restoring '+stack_fls[i]
	
	datetimes = det_stack.date_obs
	base_datetime = datetimes[0]
	print, 'base_datetime: ', base_datetime
	;*****
	; Call code to inspect the output det_info_str.sav from preceding day and remove parts of current day's detection stack that correspond to CMEs from the preceding day.
	if i gt 0 then begin
		pa_total = rm_prev_stack(stack_fls[i], in_dir, out_check)
		if out_check eq 1 then pa_total = det_stack.stack
	endif else begin
		pa_total = det_stack.stack
	endelse
	;*****

	clean_pa_total, pa_total, pa_mask
	pa_total *= pa_mask

	; flag if the detections are going off the top edge	
	sz = size(pa_total,/dim)
	flag = pa_total[*,sz[1]-1]
	if (where(flag ne 0)) ne [-1] then print, 'Goes off top edge!'

	separate_pa_total, pa_total, det_info
	; if any of the top-y entries of det_info are at the top of the image then the detection goes off the edge!
	edge_test = sz[1]-1 - det_info[3,*]
	;** So now first save out the det_info that doesn't go off the edge.
	inds = where(edge_test eq 0)
	print, 'CME detection no. go off edge: ',inds
	if keyword_set(show) then plot_image, pa_total, tit=stack_fls[i]
	if inds ne [-1] then begin
		start_datetime = strarr(n_elements(inds))
		end_datetime = strarr(n_elements(inds))
		pa1 = fltarr(n_elements(inds))
		pa2 = fltarr(n_elements(inds))
		im1 = fltarr(n_elements(inds))
		im2 = fltarr(n_elements(inds))
                widths_check = intarr(2,n_elements(inds))
                image_no_check = intarr(2,n_elements(inds))
		for j=0,n_elements(inds)-1 do begin
			print, 'first j ', j
			start_datetime[j] = datetimes[det_info[2,inds[j]]]
			end_datetime[j] = datetimes[det_info[3,inds[j]]]
			pa1[j] = det_info[0,inds[j]]
			pa2[j] = det_info[1,inds[j]]
			im1[j] = det_info[2,inds[j]]
			im2[j] = det_info[3,inds[j]]
			if keyword_set(show) then begin
			        plots,[det_info[0,inds[j]],det_info[0,inds[j]]],[det_info[2,inds[j]],det_info[3,inds[j]]],line=0,color=3, /data
                                plots,[det_info[1,inds[j]],det_info[1,inds[j]]],[det_info[2,inds[j]],det_info[3,inds[j]]],line=0,color=3, /data
                                plots,[det_info[0,inds[j]],det_info[1,inds[j]]],[det_info[2,inds[j]],det_info[2,inds[j]]],line=0,color=3, /data
                                plots,[det_info[0,inds[j]],det_info[1,inds[j]]],[det_info[3,inds[j]],det_info[3,inds[j]]],line=0,color=3, /data
                        endif
			; should check that the regions don't lie within the same interval so it's not done more than once unnecessarily.
                        widths_check[0,j] = det_info[0,inds[j]]
                        widths_check[1,j] = det_info[1,inds[j]]
                        image_no_check[0,j] = det_info[2,inds[j]]
                        image_no_check[1,j] = det_info[3,inds[j]]
		endfor
		;**
		;if keyword_set(show) then plot_image, pa_total	
		; The position angle interval to check for the next day is given by these CME detections off the edge.
		restore, stack_fls[i+1]
		print, 'Restoring the next day '+stack_fls[i+1]
		datetimes2 = det_stack.date_obs
		pa_total2 = det_stack.stack
		clean_pa_total, pa_total2, pa_mask2
		pa_total2 *= pa_mask2
	;	restore,'temp.sav'
		separate_pa_total, pa_total2, det_info2, final_pa_total2
		;if keyword_set(show) then plot_image, pa_total2, tit=stack_fls[i+1]
		for j=0,n_elements(inds)-1 do begin
			print, 'second j ', j
			; Sum across the angular range being checked from previous day's detection
			test_slice = total(final_pa_total2[(180+widths_check[0,j]):(180+widths_check[1,j]),*],1)
			; check there the summing stops, to indicate where the detection ends (if it ends on this day at all)
			test_slice_zero = (where(test_slice[1:*] eq 0))[0]
			;******
			next_day_flag = 0
			if test_slice_zero eq [-1] then begin
				print, 'GO TO NEXT FOLLOWING DAY'
				count = 1
				next_day_flag = 1
			endif
			while next_day_flag eq 1 do begin
				print, 'Loop into next following day'
				restore, stack_fls[i+1+count]
				print, 'Restoring the next following day '+stack_fls[i+1+count]
				datetimes3 = det_stack.date_obs
				pa_total3 = det_stack.stack
				clean_pa_total, pa_total3, pa_mask3
				pa_total3 *= pa_mask3
				separate_pa_total, pa_total3, det_info3, final_pa_total3
				;if keyword_set(show) then plot_image, pa_total3, tit=stack_fls[i+1+count] & pause
				next_test_slice = total(final_pa_total3[(180+widths_check[0,j]):(180+widths_check[1,j]),*],1)
				next_test_slice_zero = (where(next_test_slice eq 0))[0]
				if next_test_slice_zero ne [-1] then begin
					test_slice_zero = next_test_slice_zero
					datetimes2 = datetimes3
					final_pa_total2 = final_pa_total3
					next_day_flag = 0
				endif
			endwhile
			;******

			;if j eq 0 then plot,test_slice else oplot, test_slice, color=j
			print, 'datetimes2[test_slice_zero]', datetimes2[test_slice_zero]
			end_datetime[j] = datetimes2[test_slice_zero]
			image_no_check[1,j] += test_slice_zero
			if keyword_set(show) then begin
                        	plot_image, final_pa_total2[180:539,*], tit='Hor.red '+datetimes2[test_slice_zero]
			        verline, widths_check[0,j], color=3
                                verline, widths_check[1,j], color=3
                        	print, 'widths_check ', widths_check[0,j], widths_check[1,j]
				horline, test_slice_zero, color=3
			endif
			; Do a region grow to see if the angular width increased on this day's detection.
;*** DONT KNOW WHY THIS ISNT WORKING????!?!?!?!
			;pa_portion = final_pa_total2[180:539,*]
			;help, pa_portion
			;pmm, pa_portion
			;plot_image, pa_portion
			;temp_pa_portion = pa_portion
			; Clause for widths wrapping above 360
			;if widths_check[1,j] gt 360 then begin
		;		temp_pa_portion[
			;temp_pa_portion[0:widths_check[0,j],*] = 0	
			;temp_pa_portion[widths_check[1,j]:*,*] = 0	
			;width_inds = where(temp_pa_portion[*,0] eq 0)
			;help, width_inds
			;roi = region_grow(pa_portion, width_inds)
			;help, roi
			;if roi ne [-1] then pa_portion[roi] = 2
			;plot_image, pa_portion
;************************
		endfor

		;if ~exist(start_datetime) then new_start_datetime=det_info_str.start_times else new_start_datetime = start_datetime
		new_start_datetime = start_datetime
		new_end_datetime = end_datetime
		new_pa1 = transpose(widths_check[0,*])
		new_pa2 = transpose(widths_check[1,*])
		new_im1 = transpose(image_no_check[0,*])
		new_im2 = transpose(image_no_check[1,*])
		
		det_info_str = {base_time:base_datetime, start_times:new_start_datetime, end_times:new_end_datetime, pos_ang1:new_pa1, pos_ang2:new_pa2, image_no1:new_im1, image_no2:new_im2}
		help, det_info_str, /str
		save, det_info_str, f=out_dir+'/det_info_str_'+stack_fls_day+'.sav'
		print, 'Saving ', out_dir+'/det_info_str_'+stack_fls_day+'.sav'
		print, det_info_str
		pause
	endif

endfor



end
