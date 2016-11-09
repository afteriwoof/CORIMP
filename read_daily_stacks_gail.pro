; Created	2012-09-19	to read in intervals of 1 day and output detection stack info, but account for overlaps that need adjoining days padding.

; Last edited:	2012-12-11	to add keyword single_file and its conditions.
;		2012-12-12	add debug keyword.
;		2012-12-28	to fix the issues with overlapping days.
;		2012-12-28	to include count_days for knowing how many days worth of files need to be considered in automated_kins.pro

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
;		no_save		to prevent saving out info, for example in running automated_kins_original_images.pro where I don't want to overwrite the already saved info (though it should be the exact same it's unnecessary).

pro read_daily_stacks_gail, stack_fls, in_dir, new_det_info, new_pa_total, count_days, single_file=single_file, debug=debug, show=show, no_save=no_save

if keyword_set(debug) then begin
	print, '***'
	print, 'read_daily_stacks.pro'
	print, '***'
	pause
endif

if keyword_set(single_file) then loop_end=1 else loop_end=2

count = 1

for i=0,n_elements(stack_fls)-loop_end do begin

	if keyword_set(show) OR keyword_set(debug) then begin
		loadct, 39
		window, xs=2000, ys=1000
		!p.multi=[0,3,3]
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
	; OLD--> pa_total = rm_prev_stack(stack_fls[i], in_dir, out_check, debug=debug)
	pa_total = rm_prev_date_gail(stack_fls[i], in_dir, out_check, debug=debug)
	if keyword_set(debug) then begin
	;	plot_image, pa_total, tit='pa_total after rm_prev_date applied in read_daily_stacks'
		print, 'out_check ', out_check
		pause
	endif
	if out_check eq 1 then pa_total = det_stack.stack
	;*****

	clean_pa_total_gail, pa_total, pa_mask, debug=debug
	pa_total *= pa_mask

	; flag if the detections are going off the top edge	
	sz = size(pa_total,/dim)
	flag = pa_total[*,sz[1]-1]
	if (where(flag ne 0)) ne [-1] && keyword_set(debug) then print, 'Goes off top edge!'

	separate_pa_total, pa_total, det_info, debug=debug
	
	if keyword_set(debug) then print, 'det_info here ', det_info

	; needs this print statement here for some reason or sometimes it crashes and I can't figure out why!!!!!!!!	
	print, 'det_info: ', det_info
	;pause
	
	; if any of the top-y entries of det_info are at the top of the image then the detection goes off the edge!
	if n_elements(det_info) gt 1 then edge_test = sz[1]-1 - det_info[3,*] else edge_test = 1
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
				set_line_color
			        plots,[det_info[0,inds[j]],det_info[0,inds[j]]],[det_info[2,inds[j]],det_info[3,inds[j]]],line=0,color=3, /data
                                plots,[det_info[1,inds[j]],det_info[1,inds[j]]],[det_info[2,inds[j]],det_info[3,inds[j]]],line=0,color=3, /data
                                plots,[det_info[0,inds[j]],det_info[1,inds[j]]],[det_info[2,inds[j]],det_info[2,inds[j]]],line=0,color=3, /data
                                plots,[det_info[0,inds[j]],det_info[1,inds[j]]],[det_info[3,inds[j]],det_info[3,inds[j]]],line=0,color=3, /data
        			pause
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
				if n_elements(size(det_stack.stack,/dim)) eq 1 then goto, jump1
				if keyword_set(debug) then print, 'Removing prev from the next restored day'
				temp_in_dir = strmid(in_dir,0,strlen(in_dir)-10)+next_yy+'/'+next_mm+'/'+next_dd
				temp = rm_prev_date_gail(next_stack_fl, temp_in_dir, temp_out_check, debug=debug)
				count = 1
			endif else begin
				goto, jump1
			endelse
		endif else begin
			restore, stack_fls[i+1]
			; not doing rm_prev_date here because single_file is set so doesn't matter!
			count = 1
			if keyword_set(debug) then print, 'Restoring the next day '+stack_fls[i+1]
		endelse
		datetimes2 = det_stack.date_obs
		; update altogether
		datetimes = [datetimes, datetimes2]
		if n_elements(temp) gt 1 then begin
			if keyword_set(debug) then print, 'pa_total2 = temp'
			help, temp
			pa_total2 = temp 
			endif else begin
			if keyword_set(debug) then print, 'pa_total2 = det_stack.stack'
			help, det_stack.stack
			pa_total2 = det_stack.stack
		endelse
		clean_pa_total_gail, pa_total2, pa_mask2
		pa_total2 *= pa_mask2
		if keyword_set(debug) then begin
			plot_image, pa_total2, tit='pa_total2 - from the next day'
			pause
			if n_elements(temp) gt 1 then plot_image, temp, tit='pa_total2 with prev removed'
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

		; Need to detect the ROIs in the two_day_pa_total, and then discard the ones that didn't begin in the first day.
		separate_pa_total, two_day_pa_total, det_info_two_day, final_two_day_pa_total, debug=debug
		if keyword_set(debug) then begin
			print, 'where(det_info_two_day[2,*] lt sz_pa_total) ', where(det_info_two_day[2,*] lt sz_pa_total)
			print, 'where(det_info_two_day[3,*] gt sz_pa_total) ', where(det_info_two_day[3,*] gt sz_pa_total)
		endif
		if where(det_info_two_day[2,*] lt sz_pa_total AND det_info_two_day[3,*] gt sz_pa_total) eq [-1] then begin
			if keyword_set(debug) then print, 'goto, jump1'
			goto, jump1
		endif
		det_info_overlap = det_info_two_day[*,where(det_info_two_day[2,*] lt sz_pa_total AND det_info_two_day[3,*] gt sz_pa_total)]
		if keyword_set(debug) then begin
                        print, '1) sz_pa_total ', sz_pa_total
                        print, '2) det_info_two_day: ' & print, det_info_two_day
                        print, '3) det_info_overlap: ' & print, det_info_overlap
                	pause
		endif
		; If any of the regions that overlap from the first day hit the end of the second day, add the next following day.
		next_day_flag = 0
		if where(det_info_overlap[3,*] eq (size(two_day_pa_total,/dim))[1]-1) ne [-1] then begin
			print, 'GO TO NEXT FOLLOWING DAY'
			count += 1
			next_day_flag = 1
		endif
		while next_day_flag eq 1 do begin
			if keyword_set(debug) then print, 'Loop into next following day'
			if keyword_set(single_file) then begin
				next_date = anytim(secs+(86400*(count)),/date_only,/ecs)
				next_yy = strmid(next_date,0,4)
				next_mm = strmid(next_date,5,2)
				next_dd = strmid(next_date,8,2)
				next_date = next_yy+next_mm+next_dd
				next_stack_fl = strmid(stack_fls[i],0,strlen(stack_fls[i])-33)+'/'+next_yy+'/'+next_mm+'/'+next_dd+'/det_stack_'+next_date+'.sav'
				if file_exist(next_stack_fl) eq 0 then goto, jump1
				if keyword_set(debug) then print, 'Restoring the next following day '+next_stack_fl
				restore, next_stack_fl
				temp_in_dir = strmid(in_dir,0,strlen(in_dir)-10)+next_yy+'/'+next_mm+'/'+next_dd
                                temp = rm_prev_date_gail(next_stack_fl, temp_in_dir, temp_out_check, debug=debug)
			endif else begin
				restore, stack_fls[i+count]
				if keyword_set(debug) then print, 'Restoring the next following day '+stack_fls[i+count]
			endelse
			datetimes3 = det_stack.date_obs
			prev_datetimes = datetimes
			datetimes = [datetimes, datetimes3]
			
			if n_elements(temp) gt 1 then pa_total3 = temp else pa_total3 = det_stack.stack
			if n_elements(size(pa_total3,/dim)) eq 1 then pa_total3 = reform(pa_total3,[360,1])
			clean_pa_total_gail, pa_total3, pa_mask3
			if n_elements(size(pa_mask3,/dim)) eq 1 then pa_mask3 = reform(pa_mask3,[360,1])
			pa_total3 *= pa_mask3
			if n_elements(size(pa_total3,/dim)) eq 1 then pa_total3 = reform(pa_total3,[360,1])
			if keyword_set(debug) then begin
				plot_image, pa_total3, tit='pa_total3 - from the next following day'
				pause
				if temp ne 0 then plot_image, temp, tit='pa_total3 - removing prev'
				pause
			endif
			sz_two_day_pa_total = (size(two_day_pa_total,/dim))[1]
			sz_pa_total3 = (size(pa_total3, /dim))[1]
			if ~exist(many_day_pa_total) then begin
				prev_pa_total = two_day_pa_total
				sz_many_day_pa_total = sz_two_day_pa_total
				many_day_pa_total = dblarr(360,sz_two_day_pa_total+sz_pa_total3)
				many_day_pa_total[*,0:sz_two_day_pa_total-1] = two_day_pa_total
				many_day_pa_total[*,sz_two_day_pa_total:*] = pa_total3
			endif else begin
                                prev_pa_total = many_day_pa_total
				sz_many_day_pa_total = (size(many_day_pa_total,/dim))[1]
                                new_many_day_pa_total = dblarr(360,sz_many_day_pa_total+sz_pa_total3)
                                new_many_day_pa_total[*,0:sz_many_day_pa_total-1] = many_day_pa_total
                                new_many_day_pa_total[*,sz_many_day_pa_total:*] = pa_total3
				many_day_pa_total = new_many_day_pa_total
                                delvarx, new_many_day_pa_total
                        endelse
                        if keyword_set(debug) then begin
                                plot_image, many_day_pa_total, tit='many_day_pa_total'
                                pause
                        endif
                        ;separate_pa_total, pa_total3, det_info3, final_pa_total3, debug=debug
                        separate_pa_total, many_day_pa_total, det_info3, final_pa_total3, debug=debug
                        ;if keyword_set(show) then plot_image, pa_total3, tit=stack_fls[i+count] & pause
                        if keyword_set(debug) then begin
				print, 'sz_pa_total ', sz_pa_total
				print, 'sz_pa_total2 ', sz_pa_total2
				print, 'sz_two_day_pa_total ', sz_two_day_pa_total
				print, 'sz_pa_total3 ', sz_pa_total3
				print, 'det_info3'
				print, det_info3
			endif
			; finding where the detections that started within the first pa_total end in the recent many_pa_total
			; if they aren't, due to separate CMEs occurring at the start and end of the combined days, then skip
			if (where(det_info3[2,*] lt sz_pa_total AND det_info3[3,*] ge sz_two_day_pa_total)) ne [-1] then begin
				det_info_overlap = det_info3[*,where(det_info3[2,*] lt sz_pa_total AND det_info3[3,*] ge sz_two_day_pa_total)]
				if where(det_info_overlap[3,*] lt (size(many_day_pa_total,/dim))[1]-1) ne [-1] then begin
					datetimes2 = datetimes3
					final_pa_total2 = final_pa_total3
					next_day_flag = 0
				endif
			endif else begin
				many_day_pa_total = prev_pa_total
				datetimes = prev_datetimes
				separate_pa_total, many_day_pa_total, det_info, final_pa_total3, debug=debug
				next_day_flag = 0
				help, many_day_pa_total, datetimes
				count -= 1
			endelse
			count += 1
		endwhile

		if ~exist(many_day_pa_total) then new_pa_total = two_day_pa_total else new_pa_total = many_day_pa_total
		sz_overlap = size(det_info_overlap,/dim)
		if keyword_set(debug) then begin
			print, 'sz_overlap ', sz_overlap
			print, 'sz_pa_total ', sz_pa_total
			print, 'sz_pa_total2 ', sz_pa_total2
			plot_image, new_pa_total, tit='new_pa_total'
			print, 'det_info ' & print, det_info
			print, 'det_info_overlap ' & print, det_info_overlap
			for k=0,n_elements(det_info_overlap[0,*])-1 do begin
                                plots, [det_info_overlap[0,k],det_info_overlap[0,k]], [det_info_overlap[2,k],det_info_overlap[3,k]]
                                plots, [det_info_overlap[1,k],det_info_overlap[1,k]], [det_info_overlap[2,k],det_info_overlap[3,k]]
                                plots, [det_info_overlap[0,k],det_info_overlap[1,k]], [det_info_overlap[2,k],det_info_overlap[2,k]]
                                plots, [det_info_overlap[0,k],det_info_overlap[1,k]], [det_info_overlap[3,k],det_info_overlap[3,k]]
                        endfor
		endif
		if n_elements(sz_overlap) gt 1 then begin
			; taking the overlapping region out, by seeing where it starts at the right time and ends at the top of the relevant pa_total
			overlap_ind = where(det_info[2,*] eq det_info_overlap[2,0] AND (det_info[3,*] eq sz_pa_total-1 OR det_info[3,*] eq sz_pa_total2-1))
			;if keyword_set(debug) then print, 'where(det_info[2,*] eq det_info_overlap[2,0]) ', where(det_info[2,*] eq det_info_overlap[2,0])
			for k=1,sz_overlap[1]-1 do begin
				overlap_ind = [overlap_ind, where(det_info[2,*] eq det_info_overlap[2,k] AND (det_info[3,*] eq sz_pa_total-1 OR det_info[3,*] eq sz_pa_total2-1))]
				;if keyword_set(debug) then begin
				;	print, 'k ', k
				;	print, 'where(det_info[2,*] eq det_info_overlap[2,k]) ', where(det_info[2,*] eq det_info_overlap[2,k])
				;	print, 'overlap_ind ', overlap_ind
				;endif					
			endfor
			; remove duplicates
			overlap_ind = overlap_ind[uniq(overlap_ind,sort(overlap_ind))]
		endif else begin
			overlap_ind = where(det_info[2,*] eq det_info_overlap[2,0] AND (det_info[3,*] eq sz_pa_total-1 OR det_info[3,*] eq sz_pa_total2-1))
			overlap_ind = overlap_ind[uniq(overlap_ind,sort(overlap_ind))]
		endelse
		if keyword_set(debug) then begin
			print, 'overlap_ind ', overlap_ind
			print, 'where(overlap_ind ne -1) ', where(overlap_ind ne -1)
			print, 'overlap_ind[where(overlap_ind ne -1)] ', overlap_ind[where(overlap_ind ne -1)]
		endif
		if where(overlap_ind ne -1) eq [-1] then goto, jump1
		overlap_ind = overlap_ind[where(overlap_ind ne -1)]
		; remove duplicates in overlap_ind
		
		;if keyword_set(debug) then begin
		;	print, 'det_info ' & print, det_info
		;	print, 'det_info_overlap ' & print, det_info_overlap
		;	print, 'overlap_ind ' & print, overlap_ind
		;	print, 'n_elements(overlap_ind) ', n_elements(overlap_ind)
		;	print, 'det_info_overlap[*,overlap_ind] ' & print, det_info_overlap[*,overlap_ind]
		;	print, 'det_info[*,overlap_ind] ' & print, det_info[*,overlap_ind]
		;	plot_image, new_pa_total, tit='new_pa_total'
		;endif
		new_det_info = det_info
		if keyword_set(debug) then print, 'det_info_overlap ', det_info_overlap
		; just don't worry about all the overlaps if they don't match, i.e. if n_elements(overlap_ind) ne size of det_info_overlap. Some error probably that they aren't important!
		if n_elements(det_info_overlap) gt 4 then begin
			if n_elements(overlap_ind)-1 gt (size(det_info_overlap,/dim))[1]-1 then temp=(size(det_info_overlap,/dim))[1]-1 else temp=n_elements(overlap_ind)-1
		endif else begin
			temp=0
		endelse
		for k=0,temp do new_det_info[*,overlap_ind[k]] = det_info_overlap[*,k]
		if keyword_set(debug) then begin
			for k=0,n_elements(det_info[0,*])-1 do begin
				plots, [new_det_info[0,k],new_det_info[0,k]], [new_det_info[2,k],new_det_info[3,k]]
				plots, [new_det_info[1,k],new_det_info[1,k]], [new_det_info[2,k],new_det_info[3,k]]
				plots, [new_det_info[0,k],new_det_info[1,k]], [new_det_info[2,k],new_det_info[2,k]]
				plots, [new_det_info[0,k],new_det_info[1,k]], [new_det_info[3,k],new_det_info[3,k]]
			endfor
			pause
		endif	

		jump1:

		if ~exist(new_pa_total) then new_pa_total = pa_total
		if ~exist(new_det_info) then new_det_info = det_info

		new_start_datetime = datetimes[new_det_info[2,*]]
		new_end_datetime = datetimes[new_det_info[3,*]]
		new_pa1 = new_det_info[0,*]
		new_pa2 = new_det_info[1,*]
		new_im1 = new_det_info[2,*]
		new_im2 = new_det_info[3,*]

		det_info_str = {base_time:base_datetime, start_times:new_start_datetime, end_times:new_end_datetime, pos_ang1:new_pa1, pos_ang2:new_pa2, image_no1:new_im1, image_no2:new_im2}
		if keyword_set(debug) then help, det_info_str, /str
		if ~keyword_set(no_save) then save, det_info_str, f=out_dir+'/det_info_str_'+stack_fls_day+'.sav'
		if keyword_set(debug) then print, 'Saving ', out_dir+'/det_info_str_'+stack_fls_day+'.sav'

		rm_date = date
		; Save out info on what days need calling to this day for roi removal.
		if where(strmid(new_end_datetime,0,10) ne strmid(date,0,10)) ne [-1] then begin
			save_paths = (new_end_datetime[where(strmid(new_end_datetime,0,10) ne strmid(date,0,10))])[0]
			enddateis = strmid(save_paths,0,10)
			temp = (anytim(enddateis) - anytim(date))/86400.
			temp_outdates = strarr(temp)
			if keyword_set(debug) then begin
				print, 'save_paths ', save_paths
				print, 'enddateis ', enddateis
				print, 'temp ', temp
				print, 'temp_outdate ', temp_outdates
			endif
			for k=0,temp-1 do begin
				secs = anytim(date,/sec)
	                        temp_outdates[k] = anytim(secs+(86400*(k+1)),/date_only,/ecs)
				if keyword_set(debug) then print, 'temp_outdates ', temp_outdates
			endfor
			save_paths = temp_outdates
			save_path_dir = strmid(out_dir,0,strlen(out_dir)-10)
			for k=0,n_elements(save_paths)-1 do begin
				if ~keyword_set(no_save) then save, rm_date, f=save_path_dir+save_paths[k]+'/rm_date_'+strjoin(strsplit(rm_date,'/',/extract))+'.sav'
				if keyword_set(debug) && ~keyword_set(no_save) then print, 'Saving ', save_path_dir+save_paths[k]+'/rm_date_'+strjoin(strsplit(rm_date,'/',/extract))+'.sav'
			endfor
		endif
	endif else begin
		new_det_info = det_info
		new_pa_total = pa_total
	endelse

endfor

count_days = count

end
