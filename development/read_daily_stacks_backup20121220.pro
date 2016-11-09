; Created	2012-09-19	to read in intervals of 1 day and output detection stack info, but account for overlaps that need adjoining days padding.

; Last edited:	2012-12-11	to add keyword single_file and its conditions.
;		2012-12-12	add debug keyword.


; NOTES to be done on this code:
; 1)	Loop for more than just a second day
; 2)	DONE: Remove the detections that cross into a second day from the next run of that day
; 3)	Back-adjust the angular widths for changes to them on the proceeding days.

; INPUT		stack_fls -		the det_stack*.sav files.
;		in_dir -	the in_dir from automated_kins.pro 'years' path.

; OUTPUT	new_det_info 	to output the new det_info for the ROI that spans more than one day.

; KEYWORDS	single_file -	to take in only a single stack_fls file (i.e. on a per-day basis).
;		show 		to plot the outputs.
;		debug		to plot and print everything for debugging.

pro read_daily_stacks, stack_fls, in_dir, new_det_info, new_pa_total, single_file=single_file, debug=debug, show=show

if keyword_set(debug) then begin
	print, '***'
	print, 'read_daily_stacks.pro'
	print, '***'
	pause
endif

if keyword_set(single_file) then loop_end=1 else loop_end=2

for i=0,n_elements(stack_fls)-loop_end do begin

	if keyword_set(show) OR keyword_set(debug) then begin
		loadct, 39
		window, xs=1000, ys=1000
		!p.multi=[0,2,3]
		!p.charsize=2
		!p.charthick=1
		print, 'i ', i
	endif

	; Generate the path to the out_dir
	date = strmid(file_basename(stack_fls[i]),10,8)
	yy = strmid(date,0,4)
	mm = strmid(date,4,2)
	dd = strmid(date,6,2)
	date = yy+'/'+mm+'/'+dd
	if ~keyword_set(single_file) then begin
		dir = strmid(in_dir,0,strlen(in_dir)-5)
		out_dir = dir+'/'+date
	endif else begin
		out_dir = in_dir
	endelse
	restore, stack_fls[i]
	stack_fls_day = strmid(file_basename(stack_fls[i]),10,8)
	datetimes = det_stack.date_obs
	base_datetime = datetimes[0]
	if keyword_set(debug) then begin
                print, 'out_dir: ', out_dir
                print, 'Restoring '+stack_fls[i]
                print, 'Day: ', stack_fls_day
		print, 'base_datetime: ', base_datetime
        endif	
	;*****
	; Call code to inspect the output det_info_str.sav from preceding day and remove parts of current day's detection stack that correspond to CMEs from the preceding day.
	pa_total = rm_prev_stack(stack_fls[i], in_dir, out_check, debug=debug)
	if keyword_set(debug) then print, 'out_check ', out_check
	if out_check eq 1 then pa_total = det_stack.stack
	;*****

	clean_pa_total, pa_total, pa_mask, debug=debug
	pa_total *= pa_mask

	; flag if the detections are going off the top edge	
	sz = size(pa_total,/dim)
	flag = pa_total[*,sz[1]-1]
	if (where(flag ne 0)) ne [-1] && keyword_set(debug) then print, 'Goes off top edge!'

	separate_pa_total, pa_total, det_info, debug=debug
	; if any of the top-y entries of det_info are at the top of the image then the detection goes off the edge!
	edge_test = sz[1]-1 - det_info[3,*]
	;** So now first save out the det_info that doesn't go off the edge.
	inds = where(edge_test eq 0)
	if keyword_set(show) OR keyword_set(debug) then begin
		print, 'CME detection no. go off edge: ',inds
		plot_image, pa_total, tit=stack_fls[i]
		pause
	endif
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
			if keyword_set(debug) then print, 'first j ', j
			start_datetime[j] = datetimes[det_info[2,inds[j]]]
			end_datetime[j] = datetimes[det_info[3,inds[j]]]
			pa1[j] = det_info[0,inds[j]]
			pa2[j] = det_info[1,inds[j]]
			im1[j] = det_info[2,inds[j]]
			im2[j] = det_info[3,inds[j]]
			if keyword_set(show) OR keyword_set(debug) then begin
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
		if keyword_set(single_file) then begin
			secs = anytim(date,/sec)
			next_date = anytim(secs+86400,/date_only,/ecs)
			next_yy = strmid(next_date,0,4)
			next_mm = strmid(next_date,5,2)
			next_dd = strmid(next_date,8,2)
			;next_date = strjoin(strsplit(next_date,'/',/extract))
			next_date = next_yy+next_mm+next_dd
			; 33 is the length of 'yyyy/mm/dd/det_stack_yyyymmdd.sav'
			next_stack_fl = strmid(stack_fls[i],0,strlen(stack_fls[i])-33)+next_yy+'/'+next_mm+'/'+next_dd+'/det_stack_'+next_date+'.sav'
			test = file_search(next_stack_fl)
			if strlen(test) ne 0 then begin
				if keyword_set(debug) then print, 'Restoring the next day '+next_stack_fl
				restore, next_stack_fl
			endif else begin
				goto, jump1
			endelse
		endif else begin
			restore, stack_fls[i+1]
			if keyword_set(debug) then print, 'Restoring the next day '+stack_fls[i+1]
		endelse
		datetimes2 = det_stack.date_obs
		pa_total2 = det_stack.stack
		clean_pa_total, pa_total2, pa_mask2
		pa_total2 *= pa_mask2
		if keyword_set(debug) then begin
			plot_image, pa_total2, tit='pa_total2 - from the next day'
			pause
		endif
	;	restore,'temp.sav'
		separate_pa_total, pa_total2, det_info2, final_pa_total2, debug=debug
		sz_pa_total = (size(pa_total, /dim))[1]
		sz_pa_total2 = (size(pa_total2, /dim))[1]
		two_day_pa_total = dblarr(360,sz_pa_total+sz_pa_total2)
		two_day_pa_total[*,0:sz_pa_total-1] = pa_total
		two_day_pa_total[*,sz_pa_total:*] = pa_total2
		if keyword_set(debug) then begin
			plot_image, two_day_pa_total, tit='two_day_pa_total'
			pause
		endif
		;***
		; Need to loop through the possible next day overlap regions and take the one that proceeds the furthest in time
		test_slice_zeroes = intarr(n_elements(inds))
		for j=0,n_elements(inds)-1 do begin
			if widths_check[0,j] lt widths_check[1,j] then test_slice = total(final_pa_total2[(180+widths_check[0,j]):(180+widths_check[1,j]),*],1) $
				else test_slice = total(final_pa_total2[(180+widths_check[0,j]):(540-widths_check[1,j]),*],1)
			test_slice_zeroes[j] = (where(test_slice[1:*] eq 0))[0]
		endfor
		if keyword_set(debug) then begin
			print, 'test_slice_zeroes ', test_slice_zeroes
			print, 'max(test_slice_zeroes) ', max(test_slice_zeroes)
			print, 'where(test_slice_zeroes eq max(test_slice_zeroes)) ', where(test_slice_zeroes eq max(test_slice_zeroes))
			print, det_info[*,where(test_slice_zeroes eq max(test_slice_zeroes))]
		endif
		j = where(test_slice_zeroes eq max(test_slice_zeroes))
		if n_elements(j) gt 1 then j=j[0]
		;***
		;if keyword_set(show) then plot_image, pa_total2, tit=stack_fls[i+1]
		;for j=0,n_elements(inds)-1 do begin
			if keyword_set(debug) then print, 'second j ', j
			; Sum across the angular range being checked from previous day's detection
			if widths_check[0,j] lt widths_check[1,j] then test_slice = total(final_pa_total2[(180+widths_check[0,j]):(180+widths_check[1,j]),*],1) $
				else test_slice = total(final_pa_total2[(180+widths_check[0,j]):(540-widths_check[1,j]),*],1)
			; check there the summing stops, to indicate where the detection ends (if it ends on this day at all)
			test_slice_zero = (where(test_slice[1:*] eq 0))[0]
			if keyword_set(debug) then print, 'test_slice_zero ', test_slice_zero
			;******
			;two_day_pa_total = dblarr(360,sz_pa_total+test_slice_zero)
			;two_day_pa_total[*,0:sz_pa_total-1] = pa_total
			;two_day_pa_total[*,sz_pa_total:*] = pa_total2[*,0:test_slice_zero-1]
			two_day_pa_total[*,(sz_pa_total+test_slice_zero):*] = 0
			if keyword_set(debug) then print, 'widths_check[*,j]', widths_check[*,j]
			if widths_check[0,j] lt widths_check[1,j] then begin
				two_day_pa_total[0:widths_check[0,j],(sz_pa_total+test_slice_zero):*] = 0
				two_day_pa_total[widths_check[1,j]:*,(sz_pa_total+test_slice_zero):*] = 0
			endif else begin
				two_day_pa_total[widths_check[1,j]:widths_check[0,j],(sz_pa_total+test_slice_zero):*] = 0
			endelse
			if keyword_set(debug) then begin
				plot_image, two_day_pa_total, tit='two_day_pa_total with the irrelevant bits blacked out'
				print, 'test_slice_zero ', test_slice_zero, ' plus sz_pa_total ', sz_pa_total, ' = ', $
					test_slice_zero+sz_pa_total
                                horline, test_slice_zero+sz_pa_total
				print, 'horline, test_slice_zero+sz_pa_total'
				pause
                        endif
			next_day_flag = 0
			if test_slice_zero eq [-1] then begin
				if keyword_set(debug) then print, 'GO TO NEXT FOLLOWING DAY'
				count = 1
				next_day_flag = 1
			endif
			while next_day_flag eq 1 do begin
				if keyword_set(debug) then print, 'Loop into next following day'
				if keyword_set(single_file) then begin
					next_date = anytim(secs+(86400*(1+count)),/date_only,/ecs)
					next_yy = strmid(next_date,0,4)
		                        next_mm = strmid(next_date,5,2)
	        	                next_dd = strmid(next_date,8,2)
					next_date = next_yy+next_mm+next_dd
					next_stack_fl = strmid(stack_fls[i],0,strlen(stack_fls[i])-33)+'/'+next_yy+'/'+next_mm+'/'+next_dd+'/det_stack_'+next_date+'.sav'
		                        if keyword_set(debug) then print, 'Restoring the next following day '+next_stack_fl
                 			restore, next_stack_fl
				endif else begin
					restore, stack_fls[i+1+count]
					if keyword_set(debug) then print, 'Restoring the next following day '+stack_fls[i+1+count]
				endelse
				datetimes3 = det_stack.date_obs
				pa_total3 = det_stack.stack
				clean_pa_total, pa_total3, pa_mask3
				pa_total3 *= pa_mask3
				if keyword_set(debug) then begin
					plot_image, pa_total3, tit='pa_total3 - from the next following day'
					pause
				endif
				sz_two_day_pa_total = (size(two_day_pa_total,/dim))[1]
				sz_pa_total3 = (size(pa_total3, /dim))[1]
				if ~exist(many_day_pa_total) then begin
					sz_many_day_pa_total = sz_two_day_pa_total
					many_day_pa_total = dblarr(360,sz_two_day_pa_total+sz_pa_total3)
					many_day_pa_total[*,0:sz_two_day_pa_total-1] = two_day_pa_total
					many_day_pa_total[*,sz_two_day_pa_total:*] = pa_total3
				endif else begin
					sz_many_day_pa_total = (size(many_day_pa_total,/dim))[1]
					new_many_day_pa_total = dblarr(360,sz_many_day_pa_total+sz_pa_total3)
					new_many_day_pa_total[*,0:sz_many_day_pa_total-1] = many_day_pa_total
					new_many_day_pa_total[*,sz_many_day_pa_total:*] = pa_total3
					many_day_pa_total = new_many_day_pa_total
					delvar, new_many_day_pa_total
				endelse
				if keyword_set(debug) then begin
					plot_image, many_day_pa_total, tit='many_day_pa_total'
					pause
				endif
				;separate_pa_total, pa_total3, det_info3, final_pa_total3, debug=debug
				separate_pa_total, many_day_pa_total, det_info3, final_pa_total3, debug=debug
				;if keyword_set(show) then plot_image, pa_total3, tit=stack_fls[i+1+count] & pause
				next_test_slice = total(final_pa_total3[(180+widths_check[0,j]):(180+widths_check[1,j]),*],1)
				next_test_slice_zero = (where(next_test_slice eq 0))[0]
				if keyword_set(debug) then begin
					print, 'next_test_slice_zero ', next_test_slice_zero, ' plus sz_many_day_pa_total ', sz_many_day_pa_total, ' = ', $
						next_test_slice_zero+sz_many_day_pa_total
					horline, next_test_slice_zero+sz_many_day_pa_total
					pause
				endif
				if next_test_slice_zero ne [-1] then begin
					test_slice_zero = next_test_slice_zero
					datetimes2 = datetimes3
					final_pa_total2 = final_pa_total3
					next_day_flag = 0
				endif
			endwhile
			;******
			if ~exist(many_day_pa_total) then new_pa_total = two_day_pa_total else new_pa_total = many_day_pa_total

			;if j eq 0 then plot,test_slice else oplot, test_slice, color=j
			if keyword_set(debug) then print, 'datetimes2[test_slice_zero] ', datetimes2[test_slice_zero]
			end_datetime[j] = datetimes2[test_slice_zero]
			for k=0,n_elements(test_slice_zeroes)-1 do image_no_check[1,k] += test_slice_zeroes[k]
			;image_no_check[1,j] += test_slice_zero
			if keyword_set(show) OR keyword_set(debug) then begin
                        	plot_image, final_pa_total2[180:539,*], tit='Hor.red '+datetimes2[test_slice_zero]
			        set_line_color
				verline, widths_check[0,j], color=3
                                verline, widths_check[1,j], color=3
                        	print, 'widths_check ', widths_check[0,j], widths_check[1,j]
				horline, test_slice_zero, color=3
				pause
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
		;endfor

		jump1:
		;if ~exist(start_datetime) then new_start_datetime=det_info_str.start_times else new_start_datetime = start_datetime
		new_start_datetime = start_datetime
		new_end_datetime = end_datetime
		new_pa1 = transpose(widths_check[0,*])
		new_pa2 = transpose(widths_check[1,*])
		new_im1 = transpose(image_no_check[0,*])
		new_im2 = transpose(image_no_check[1,*])
	
		new_det_info = intarr(4,n_elements(new_pa1))
		new_det_info[0, *] = new_pa1
		new_det_info[1, *] = new_pa2
		new_det_info[2, *] = new_im1
		new_det_info[3, *] = new_im2

		if keyword_set(debug) then begin
			plot_image, new_pa_total, tit='new_pa_total'
			for i=0,n_elements(new_pa1)-1 do begin
				plots, [new_det_info[0,i],new_det_info[0,i]], [new_det_info[2,i],new_det_info[3,i]]
			        plots, [new_det_info[1,i],new_det_info[1,i]], [new_det_info[2,i],new_det_info[3,i]]
			        plots, [new_det_info[0,i],new_det_info[1,i]], [new_det_info[2,i],new_det_info[2,i]]
			        plots, [new_det_info[0,i],new_det_info[1,i]], [new_det_info[3,i],new_det_info[3,i]]
			endfor
			pause
		endif


		det_info_str = {base_time:base_datetime, start_times:new_start_datetime, end_times:new_end_datetime, pos_ang1:new_pa1, pos_ang2:new_pa2, image_no1:new_im1, image_no2:new_im2}
		if keyword_set(debug) then begin
			help, det_info_str, /str
			print, det_info_str
			pause
		endif
		save, det_info_str, f=out_dir+'/det_info_str_'+stack_fls_day+'.sav'
		print, 'Saving ', out_dir+'/det_info_str_'+stack_fls_day+'.sav'
	endif

endfor



end
