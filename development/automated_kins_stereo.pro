; Created	2013-03-27	from automated_kins.pro


pro automated_kins_stereo, debug=debug, old_data=old_data, behind=behind

help, _extra, /str
if keyword_set(debug) then print, '*** automated_kins_stereo.pro ***'

;For latest processing use this path:
if ~keyword_set(old_data) then begin
	;path = '~/Postdoc/Automation/work_on_gail/volumes/store/processed_data/stereo/secchi/separated/b/cor2/fits/'
	path = '~/Postdoc_largefiles/secchi_cor2_b/'
	years = file_search('~/Postdoc_largefiles/detections_dublin/b/cor2/2010')
	;years = file_search('~/Postdoc/Automation/work_on_gail/volumes/store/processed_data/stereo/secchi/detections/b/cor2/2010')
	;years = file_search(path+'detections_dublin/b/cor2/2011')
	;years = file_search('~/Sites/CORIMP/2012')
	;fits_fls = '/original/*fits*'
	fits_fls = '/*dynamics*fits*'
	dets_path = '/cme_dets/dets*'
endif else begin
	;For older processing use this path:
	path = '~/Postdoc_largefiles/separated_old/fits/'
	years = file_search('~/Postdoc_largefiles/separated_old/detections_old/2006')
	fits_fls = '/original*fits*'
	dets_path = '/dets*'
endelse

goto, jump1

for i_years=0,0 do begin
	months = file_search(years[i_years]+'/*')
        for i_months = 0,n_elements(months)-1 do begin
                days = file_search(months[i_months]+'/*')
                for i_days=0,n_elements(days)-1 do begin
			dir = days[i_days]
			if i_years eq 0 && i_months eq 0 && i_days eq 0 then stack_fls = file_Search(dir+'/det_stack*') $
				else stack_fls = [stack_fls, file_Search(dir+'/det_stack*')]
		endfor
	endfor
endfor
print, stack_fls

; Save out the det_info_str_YYYYMMDD.sav into the relevant folders.
read_daily_stacks, stack_fls, years

jump1:
; Now gather the det_inf_str_*.sav

for i_years=0,n_elements(years)-1 do begin
	months = file_search(years[i_years]+'/*')
        ;for i_months = 0,n_elements(months)-1 do begin
        for i_months = 0,0 do begin
                days = file_search(months[i_months]+'/*')
                for i_days = 0,n_elements(days)-1 do begin
                ;for i_days = 19,n_elements(days)-1 do begin
			dir = days[i_days]
			print, '********'
			print, dir
			print, '********'
			current_year = strmid(dir,strlen(dir)-10,4)
			current_month = strmid(dir,strlen(dir)-5,2)
			current_day = strmid(dir,strlen(dir)-2,2)
			fls = file_search(path+current_year+'/'+current_month+'/'+current_day+fits_fls)
			png_fls = file_search(dir+'/cme_pngs/*png')
			stack_fl = file_search(dir+'/det_stack*')
			restore, stack_fl
			pa_total = det_stack.stack
			clean_pa_total, pa_total, pa_mask, debug=debug
			if keyword_set(debug) then begin
				print, 'dir ', dir
				print, 'current_year ', current_year
				print, 'current_month ', current_month
				print, 'current_day ', current_day
				print, 'fls[0] ', fls[0]
				print, 'stack_fl ', stack_fl
				help, det_stack, /str
				loadct, 39
				window, xs=1000, ys=1000
				!p.multi=[0,1,3]
				!p.charthick=1
				!p.charsize=2
				plot_image, pa_total, tit='pa_total initially'
				pause
				plot_image, pa_mask, tit='pa_mask'
				pause
				plot_image, pa_total*pa_mask, tit='pa_total cleaned'
				pause
			endif
			pa_total *= pa_mask
			pa_total_eps = pa_total
			separate_pa_total, pa_total, det_info, debug=debug
			if n_elements(det_info) eq 1 then begin
				if det_info eq 0 then goto, jump4
			endif
			if keyword_set(debug) then begin
				print, 'size(pa_total,/dim) ', size(pa_total,/dim)
				print, 'det_info ', det_info
				pause
			endif
			; if detection stack has ROIs that cross to next day, include those.
			if where(det_info[3,*] eq n_elements(fls)-1) ne [-1] then begin
				read_daily_stacks, stack_fl, dir, new_det_info, new_pa_total, count_days, /single_file, debug=debug
				if keyword_set(debug) then print, '(where(det_info[3,*] eq n_elements(fls)-1) ne [-1])'
				; combine the new_det_info with the current day's det_info
;				if n_elements(new_det_info) eq 0 then goto, jump3
				sz_det = size(new_det_info,/dim)
				if keyword_set(debug) then begin
					print, 'det_info goes off top of image'
					help, new_det_info
					print, 'sz_det ', sz_det
					print, 'count_days ', count_days
					pause
				endif
;				if n_elements(sz_det) gt 1 then loop_end=sz_det[1] else loop_end=1
;				for i=0,loop_end-1 do begin
;					temp_det_info = intarr(4)
;					temp_det_info[*] = new_det_info[*,i]
;					ind_1 = where(det_info eq temp_det_info[0])
;					if keyword_set(debug) then begin
 ;                                               help, new_det_info
  ;                                              print, 'new_det_info[*,i] ', new_det_info[*,i]
   ;                                             print, 'temp_det_info ', temp_det_info
;						print, 'ind_1 ', ind_1
;						pause
 ;                                       endif
;					if n_elements(ind_1) gt 1 then begin
;						ind_2 = where(det_info eq temp_det_info[1])
;						print, 'ind_2 ', ind_2
;						if n_elements(ind_2) gt 1 then begin
;							ind_3 = where(det_info eq temp_det_info[2])
;							print, 'ind_3 ', ind_3
;							if n_elements(ind_3) gt 1 then ind_2 =ind_2[0] else correct_ind_1 = ind_3 - 2
;						endif
;						if ~exist(correct_ind_1) then correct_ind_1 = ind_2 - 1
;					endif
;					if ~exist(correct_ind_1) then correct_ind_1 = ind_1
;					if keyword_set(debug) then print, 'correct_ind_1 ', correct_ind_1
;					if correct_ind_1+3 gt n_elements(det_info) then goto, jump3
;					det_info[correct_ind_1:correct_ind_1+3] = temp_det_info
;					delvarx, correct_ind_1
;				endfor
				i = 1
				while i le count_days do begin
					next_date = anytim(anytim(current_year+'/'+current_month+'/'+current_day, /sec)+(86400.*i),/date_only,/ecs)
					next_dir = strmid(dir, 0, strlen(dir)-10) + next_date
					if strlen(file_search(next_dir)) eq 0 then begin
						det_fls = file_Search(dir+dets_path)
                                		stack_fls = file_search(dir+'/det_stack*')
					endif else begin
						if n_elements(file_search(path+next_date+fits_fls)) gt 1 then begin
							fls = [fls, file_search(path+next_date+fits_fls)]
						endif else begin
							if strlen(file_search(path+next_date+fits_fls)) ne 0 then fls = [fls, file_search(path+next_date+fits_fls)]
						endelse
						if i eq 1 then det_fls = [file_search(dir+dets_path), file_search(next_dir+dets_path)] $
							else det_fls = [det_fls, file_search(next_dir+dets_path)]
						if i eq 1 then stack_fls = [stack_fl, file_search(next_dir+'/det_stack*')] else $
							stack_fls = [stack_fls, file_search(next_dir+'/det_stack*')]
						png_fls = [png_fls, file_search(next_dir+'/cme_pngs/*png')]
					endelse
					i += 1
				endwhile
				if exist(new_det_info) then det_info = new_det_info				
				if exist(new_pa_total) then pa_total = new_pa_total
				delvarx, new_det_info, new_pa_total
				if keyword_set(debug) then begin
					plot_image, pa_total, tit='pa_total as it now appears in automated_kins.pro'
					help, fls
					print, 'fls[0] ', fls[0]
					print, 'fls[n_elements(fls)-1] ', fls[n_elements(fls)-1]
					print, 'fls[max(det_info[3,*])] ', fls[max(det_info[3,*])]
					help, det_fls
					print, 'det_fls[0] ', det_fls[0]
					print, 'det_fls[n_elements(det_fls)-1] ', det_fls[n_elements(det_fls)-1]
					help, png_fls
					print, 'png_fls[0] ', png_fls[0]
					print, 'png_fls[n_elements(png_fls)-1]', png_fls[n_elements(png_fls)-1]
					sz = size(det_info,/dim)
					if n_elements(sz) gt 1 then i_end=sz[1]-1 else i_end=0
					for i=0,i_end do begin
						plots, [det_info[0,i],det_info[0,i]], [det_info[2,i],det_info[3,i]]
					        plots, [det_info[1,i],det_info[1,i]], [det_info[2,i],det_info[3,i]]
					        plots, [det_info[0,i],det_info[1,i]], [det_info[2,i],det_info[2,i]]
					        plots, [det_info[0,i],det_info[1,i]], [det_info[3,i],det_info[3,i]]
					endfor
					print, 'det_info'
					print, det_info
					pause
				endif
			endif else begin
				jump3:
				if keyword_set(debug) then print, '(where(det_info[3,*] eq n_elements(fls)-1) eq [-1])'
				temp = rm_prev_date(stack_fl, dir, debug=debug)
				if n_elements(size(temp,/dim)) eq 2 then pa_total = temp
				if keyword_set(debug) then plot_image, pa_total, tit='pa_total with prev removed but not overlap to next day'
				separate_pa_total, pa_total, det_info, debug=debug
				det_fls = file_Search(dir+dets_path)
				stack_fls = file_search(dir+'/det_stack*')
			endelse
			if n_elements(det_info) eq 1 then begin
                                if det_info eq 0 then goto, jump4
                        endif
			mreadfits_corimp, fls, in, /quiet
                        r_sun = ave(in.rsun)
                        make_pa_total_plot, pa_total_eps, dir+'/pa_total.eps', det_info, r_sun
                        ; can also do it so it's the full detections only: make_pa_total_plot, pa_total, dir+'/pa_total.eps', det_info, r_sun
			delvarx, pa_total_eps
			if ~dir_exist(dir+'/cme_profs') then spawn, 'mkdir -p '+dir+'/cme_profs'
			find_pa_heights_all_redo, fls, pa_total, det_info, det_fls, stack_fls, dir+'/cme_profs', debug=debug, old_data=old_data
			cme_prof_fls=file_Search(dir+'/cme_profs/cme_prof_*sav')
			if ~dir_exist(dir+'/cme_profs/cme_kin_profs') then spawn, 'mkdir -p '+dir+'/cme_profs/cme_kin_profs'
			; commented out these lines to avoid over-exaiminig with /debug set.
			;if keyword_set(debug) then find_pa_heights_masked, fls, pa_total, det_info, det_fls, stack_fls, cme_prof_fls, dir+'/cme_profs/cme_kin_profs' $
			;	else find_pa_heights_masked, fls, pa_total, det_info, det_fls, stack_fls, cme_prof_fls, dir+'/cme_profs/cme_kin_profs',/no_plots
			find_pa_heights_masked, fls, pa_total, det_info, det_fls, stack_fls, cme_prof_fls, dir+'/cme_profs/cme_kin_profs',/no_plots
			if ~dir_exist(dir+'/cme_kins_plots') then spawn, 'mkdir -p '+dir+'/cme_kins_plots'
			kin_fls = file_search(dir+'/cme_profs/*txt')
			for i=0,n_elements(kin_fls)-1 do begin 
				readcol, kin_fls[i], datetimes, heights, angs, f='A, D, F'
				if keyword_set(debug) then print, 'readcol ', kin_fls[i]
				if n_elements(datetimes) eq 0 then goto, jump2
				if keyword_set(debug) then begin
					print, 'datetimes[uniq(datetimes,sort(datetimes))]', datetimes[uniq(datetimes,sort(datetimes))]
					print, 'n_elements(datetimes[uniq(datetimes,sort(datetimes))]) ', n_elements(datetimes[uniq(datetimes,sort(datetimes))])
				endif
				if n_elements(datetimes[uniq(datetimes,sort(datetimes))]) ge 3 then begin
					angs_init = angs
					clean_heights, datetimes, heights, angs
					test = n_elements(datetimes[uniq(datetimes,sort(datetimes))])
					if test lt 4 then goto, jump2
					plot_kins_quartiles, datetimes, heights, angs, dir+'/cme_kins_plots', /linear, /plot_quartiles, /tog, debug=debug, old_data=old_data, /stereo, behind=behind
					plot_kins_quartiles, datetimes, heights, angs, dir+'/cme_kins_plots', /quadratic, /plot_quartiles, /tog, debug=debug, old_data=old_data, /stereo, behind=behind
					plot_kins_quartiles, datetimes, heights, angs, dir+'/cme_kins_plots', /sav_gol, /plot_quartiles, /tog, debug=debug, old_data=old_data, /stereo, behind=behind
					; Group the pngs per event kinematics.
					datetimes_in = strmid(datetimes,0,4)+strmid(datetimes,5,2)+strmid(datetimes,8,2)+'_'$
						+strmid(datetimes,11,2)+strmid(datetimes,14,2)+strmid(datetimes,17,2)
					spawn, 'mkdir -p '+dir+'/cme_pngs_'+min(datetimes_in)
					;fls_gather = file_search('~/Postdoc_largefiles/'+current_year+'/'+current_month+'/'+current_day+'/*original*fits*')
save, fls, det_fls, datetimes_in, angs_init, dir, f='temp.sav'					
					gather_detections_cor2, fls, det_fls, datetimes_in, angs_init, dir+'/cme_pngs_'+min(datetimes_in), old_data=old_data, debug=debug, behind=behind
					;toggle, /color, /landscape, f=dir+'/pa_total_'+min(datetimes_in)+'.eps'
					;!p.background=255
					;!p.charsize=2
					;loadct, 39
					;plot_image, pa_total, xtit='Position angle (deg.)', ytit='Time (image no.)'
					;toggle
					;png_fls = sort_fls(png_fls)
					;png_dates = strmid(file_basename(png_fls),19,15)
					;fls_dates = strmid(file_basename(fls),23,15)
					;fls_event = fls[where(fls_dates eq png_dates)]
					;dets_event = 
					;png_start = min(datetimes)
					;png_start = strmid(png_start,0,4)+strmid(png_start,5,2)+strmid(png_start,8,2)+'_'+strmid(png_start,11,2)+strmid(png_start,14,2)+strmid(png_start,17,2)
					;png_end = max(datetimes)
					;png_end = strmid(png_end,0,4)+strmid(png_end,5,2)+strmid(png_end,8,2)+'_'+strmid(png_end,11,2)+strmid(png_end,14,2)+strmid(png_end,17,2)
					;png_start_ind = min(where(png_dates eq png_start))
					;png_end_ind = max(where(png_dates eq png_end))
					;png_event = png_fls[png_start_ind:png_end_ind]
					;stop
					;spawn, 'mkdir -p '+dir+'/cme_pngs_'+png_start
					;for j=0,n_elements(png_event)-1 do spawn, 'cp '+png_event[j]+' '+dir+'/cme_pngs_'+png_start
					;if keyword_set(debug) then begin
					;	print, 'png_start ', png_start
					;	print, 'png_end ', png_end
					;	print, 'png_start_ind ', png_start_ind
					;	print, 'png_end_ind ', png_end_ind
					;	print, 'png_event ', png_event
					;	pause
					;endif
				endif
				delvarx, datetimes, heights, angs, pa_total, det_info
				jump2:
			endfor 
			jump4:
                endfor ;end days
        endfor ; end months
endfor ;end years


end
