; Created	2014-06-06	from automated_kins_gail.pro to add the masses, but quickly without redoing all the images (they take longest).

; Last edited:	


pro automated_kins_gail_add_masses, startdate, enddate, debug=debug, originals=originals

if keyword_set(debug) then print, '*** automated_kins_gail.pro ***'

path = '/volumes/store/processed_data/soho/lasco/detections'
fits_dir = '/volumes/store/processed_data/soho/lasco/separated/fits/'

dates=anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11)
days=anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11,/da)

indir = fits_dir+days
outdir = path+'/'+days

index=where(dir_exist(indir),cntdir)

if cntdir eq 0 then begin
  print,'No directories (automated_gail)!!!'
  return
endif
index_many_arrays,index,dates,days,indir,outdir

fits_fls = '/*dynamics*fits*'
dets_path = '/cme_dets/dets*'
mass_path = '/volumes/store/processed_data/soho/lasco/cme_mass'

ans = ' '
read, 'Delete previous kinematic runs before proceeding? (y/n)', ans
if ans eq 'y' then begin
        print, 'Deleting any previous automated_kins.pro outputs in the file structure under ', outdir
        pause
	for ii=0,n_elements(outdir)-1 do begin
	        spawn, 'rm -f '+outdir[ii]+'/det_info_str*sav'
	        spawn, 'rm -f '+outdir[ii]+'/pa_total*.eps'
	        spawn, 'rm -f '+outdir[ii]+'/rm_date*sav'
	        spawn, 'rm -f '+outdir[ii]+'/*html'
	        spawn, 'rm -rf '+outdir[ii]+'/cme_kins*'
	        spawn, 'rm -rf '+outdir[ii]+'/cme_ims*'
	        spawn, 'rm -rf '+outdir[ii]+'/cme_profs'
	        spawn, 'rm -rf '+outdir[ii]+'/cme_masses'
	endfor
endif

for i_days=0,cntdir-1 do begin

	fls = file_search(indir[i_days]+'/c[23]_lasco_soho_dynamics_*.fits.gz',count=cntfls)
	if cntfls eq 0 then begin
		print, 'No files ', indir[i_days]
		continue
	endif

	out_dir = outdir[i_days]
	current_year = strmid(out_dir,strlen(out_dir)-10,4)
	current_month = strmid(out_dir,strlen(out_dir)-5,2)
	current_day = strmid(out_dir,strlen(out_dir)-2,2)
	make_directories, out_dir
	make_directories, out_dir+'/cme_dets'
	make_directories, out_dir+'/cme_masks'
	
	fls = sort_fls(fls)
	stack_fl = file_search(out_dir+'/det_stack*')
	if strlen(stack_fl) eq 0 then goto, jump4
	restore, stack_fl
	; condition that if there was only one image in the detection stack, skip it!
	if n_elements(size(det_stack.stack,/dim)) eq 1 then goto, jump4
	pa_total = det_stack.stack
	clean_pa_total_gail, pa_total, pa_mask, debug=debug
	if keyword_set(debug) then begin
		print, 'out_dir ', out_dir
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
	if (where(det_info[3,*] eq n_elements(fls)-1) ne [-1]) then begin
		read_daily_stacks_gail, stack_fl, out_dir, new_det_info, new_pa_total, count_days, /single_file, debug=debug
		if keyword_set(debug) then print, '(where(det_info[3,*] eq n_elements(fls)-1) ne [-1])'
		; combine the new_det_info with the current day's det_info
			if n_elements(new_det_info) eq 0 then goto, jump3
		sz_det = size(new_det_info,/dim)
		if keyword_set(debug) then begin
			print, 'det_info goes off top of image'
			help, new_det_info
			print, 'sz_det ', sz_det
			print, 'count_days ', count_days
			pause
		endif
		i = 1
		while i le count_days do begin
			next_date = anytim(anytim(current_year+'/'+current_month+'/'+current_day, /sec)+(86400.*i),/date_only,/ecs)
			next_dir = strmid(out_dir, 0, strlen(out_dir)-10) + next_date
			if strlen(file_search(next_dir)) eq 0 then begin
				det_fls = file_Search(out_dir+dets_path)
                              		stack_fls = file_search(out_dir+'/det_stack*')
			endif else begin
				if n_elements(file_search(fits_dir+next_date+fits_fls)) gt 1 then begin
					fls = [fls, file_search(fits_dir+next_date+fits_fls)]
				endif else begin
					if strlen(file_search(fits_dir+next_date+fits_fls)) ne 0 then fls = [fls, file_search(fits_dir+next_date+fits_fls)]
				endelse
				if i eq 1 then det_fls = [file_search(out_dir+dets_path), file_search(next_dir+dets_path)] $
					else det_fls = [det_fls, file_search(next_dir+dets_path)]
				if i eq 1 then stack_fls = [stack_fl, file_search(next_dir+'/det_stack*')] else $
					stack_fls = [stack_fls, file_search(next_dir+'/det_stack*')]
				;png_fls = [png_fls, file_search(next_dir+'/cme_pngs/*png')]
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
			;help, png_fls
			;print, 'png_fls[0] ', png_fls[0]
			;print, 'png_fls[n_elements(png_fls)-1]', png_fls[n_elements(png_fls)-1]
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
		temp = rm_prev_date_gail(stack_fl, out_dir, debug=debug)
		if n_elements(size(temp,/dim)) eq 2 then pa_total = temp
		if keyword_set(debug) then plot_image, pa_total, tit='pa_total with prev removed but not overlap to next day'
		separate_pa_total, pa_total, det_info, debug=debug
		det_fls = file_Search(out_dir+dets_path)
		stack_fls = file_search(out_dir+'/det_stack*')
	endelse
	if n_elements(det_info) eq 1 then begin
                if det_info eq 0 then goto, jump4
        endif
	mreadfits_corimp, fls, in, /quiet
               r_sun = ave(in.rsun)
               make_pa_total_plot, pa_total_eps, out_dir+'/pa_total_'+current_year+current_month+current_day+'.eps', det_info, r_sun
               ; can also do it so it's the full detections only: make_pa_total_plot, pa_total, dir+'/pa_total.eps', det_info, r_sun
	delvarx, pa_total_eps
	if ~dir_exist(out_dir+'/cme_profs') then spawn, 'mkdir -p '+out_dir+'/cme_profs'
	if keyword_set(debug) then begin
	help, stack_fls
		print, 'stack_fls: ', stack_fls
	endif
	; Check that each stack_fls is a real entry (exists in the directory that was searched):
	stack_fls = stack_fls[where(strlen(stack_fls) ne 0)]
		
	find_pa_heights_all_redo, fls, pa_total, det_info, det_fls, stack_fls, out_dir+'/cme_profs', debug=debug
		
	cme_prof_fls=file_Search(out_dir+'/cme_profs/cme_prof_*sav')
	if ~dir_exist(out_dir+'/cme_profs/cme_kin_profs') then spawn, 'mkdir -p '+out_dir+'/cme_profs/cme_kin_profs'
	; commented out these lines to avoid over-exaiminig with /debug set.
	;if keyword_set(debug) then find_pa_heights_masked, fls, pa_total, det_info, det_fls, stack_fls, cme_prof_fls, dir+'/cme_profs/cme_kin_profs',debug=debug $
	;	else find_pa_heights_masked, fls, pa_total, det_info, det_fls, stack_fls, cme_prof_fls, dir+'/cme_profs/cme_kin_profs',/no_plots
	find_pa_heights_masked, fls, pa_total, det_info, det_fls, stack_fls, cme_prof_fls, out_dir+'/cme_profs/cme_kin_profs',/no_plots;,debug=debug
	if ~dir_exist(out_dir+'/cme_kins') then spawn, 'mkdir -p '+out_dir+'/cme_kins'
	kin_fls = file_search(out_dir+'/cme_profs/yyyy-mm-dd_NN/*txt')
	extn_count = 0 ; intialise
	for i=0,n_elements(kin_fls)-1 do begin 
		readcol, kin_fls[i], datetimes, heights, angs, f='A, D, F'
		print, 'readcol ', kin_fls[i]
		if keyword_set(debug) then print, 'readcol ', kin_fls[i]
		if n_elements(datetimes) eq 0 then goto, jump2
		if keyword_set(debug) then begin
			print, 'datetimes[uniq(datetimes,sort(datetimes))]', datetimes[uniq(datetimes,sort(datetimes))]
			print, 'n_elements(datetimes[uniq(datetimes,sort(datetimes))]) ', n_elements(datetimes[uniq(datetimes,sort(datetimes))])
		endif
		if n_elements(datetimes[uniq(datetimes,sort(datetimes))]) ge 3 then begin
			angs_init = angs
			angs_clean = angs
			heights_clean = heights
			datetimes_clean = datetimes
			clean_heights, datetimes_clean, heights_clean, angs_clean
			test2 = n_elements(datetimes_clean[uniq(datetimes_clean,sort(datetimes_clean))])
			if test2 lt 4 then goto, jump2
			plot_kins_quartiles_gail, datetimes_clean, heights_clean, angs_clean, out_dir+'/cme_kins', crosses360, /linear, /plot_quartiles, /tog, debug=debug, /no_legend
			plot_kins_quartiles_gail, datetimes_clean, heights_clean, angs_clean, out_dir+'/cme_kins', /quadratic, /plot_quartiles, /tog, debug=debug, /no_legend
			plot_kins_quartiles_gail, datetimes_clean, heights_clean, angs_clean, out_dir+'/cme_kins', /sav_gol, /plot_quartiles, /tog, debug=debug, /no_legend
			; Group the pngs per event kinematics.
			t_label = (datetimes_clean[where(anytim(datetimes_clean) eq min(anytim(datetimes_clean)))])[0]
		        t_label = strmid(t_label,0,4)+strmid(t_label,5,2)+strmid(t_label,8,2)+'_'+strmid(t_label,11,2)+strmid(t_label,14,2)+strmid(t_label,17,2)
			datetimes_in = strmid(datetimes,0,4)+strmid(datetimes,5,2)+strmid(datetimes,8,2)+'_'$
				+strmid(datetimes,11,2)+strmid(datetimes,14,2)+strmid(datetimes,17,2)
;goto, temp_skip
			if dir_exist(out_dir+'/cme_ims_'+t_label) then begin
				extn_count = n_elements(file_search(out_dir+'/cme_ims_'+t_label+'*'))
				print, 'dir_exists: ', out_dir+'/cme_ims_'+t_label
				extn = '_'+int2str(extn_count)
			endif else begin
				extn = ''
			endelse
			spawn, 'mkdir -p '+out_dir+'/cme_ims_'+t_label+extn
			spawn, 'mkdir -p '+out_dir+'/cme_ims_'+t_label+extn+'/c3/'
			spawn, 'mkdir -p '+out_dir+'/cme_ims_'+t_label+extn+'/c2/'

			if keyword_set(debug) then window, xs=1024, ys=1024

;			gather_gail_detections_inset_all_device, fls, det_fls, datetimes_in, angs_init, angs_clean, out_dir+'/cme_ims_'+t_label+extn, debug=debug
;			gather_gail_detections_inset_all_device, fls, det_fls, datetimes_in, angs_init, angs_clean, out_dir+'/cme_ims_'+t_label+extn, debug=debug, /c2
			
			if keyword_set(originals) then begin
				datetimes_in = strmid(datetimes,0,4)+strmid(datetimes,5,2)+strmid(datetimes,8,2)+'_'$
                                       	+strmid(datetimes,11,2)+strmid(datetimes,14,2)+strmid(datetimes,17,2)
				spawn, 'mkdir -p '+out_dir+'/cme_ims_orig_'+t_label+extn+'/c3'
				spawn, 'mkdir -p '+out_dir+'/cme_ims_orig_'+t_label+extn+'/c2'
				flso = strarr(n_elements(fls))
				for flso_i=0,n_elements(fls)-1 do $
					flso[flso_i] = strmid(fls[flso_i],0,(strsplit(fls[flso_i],'/'))[n_elements(strsplit(fls[flso_i],'/'))-1])$
					+'original/'+str_replace(file_basename(fls[flso_i]),'dynamics','original')
				;gather_gail_detections_inset_all_device, flso, det_fls, datetimes_in, angs_init, angs_clean, out_dir+'/cme_ims_orig_'+t_label+extn, debug=debug
				;gather_gail_detections_inset_all_device, flso, det_fls, datetimes_in, angs_init, angs_clean, out_dir+'/cme_ims_orig_'+t_label+extn, debug=debug, /c2
			endif
		endif
;temp_skip:
		delvarx, fls1, fls2, det_fls1, det_fls2, datetimes_in1, datetimes_in2, angs_init1, angs_init2, angs1, angs2
		delvarx, datetimes, heights, angs, pa_total, det_info
		jump2:
	; CME Mass
	cmemass_gail, out_dir, mass_path, t_label, extn, crosses360, max_cme_mass
	if ~dir_exist(out_dir+'/cme_masses') then spawn, 'mkdir -p '+out_dir+'/cme_masses'
	save, max_cme_mass, filename=out_dir+'/cme_masses/max_cme_mass_'+t_label+extn+'.sav'
	; add cme mass tag into cme_kins structure
	if file_exist(out_dir+'/cme_kins/cme_kins_savgol_'+t_label+extn+'.sav') then begin
		restore, out_dir+'/cme_kins/cme_kins_savgol_'+t_label+extn+'.sav'
		cme_kins_temp = add_tag(cme_kins,max_cme_mass,'CME_Mass')
		delvarx, cme_kins
		cme_kins = add_tag(cme_kins_temp,'grams','CME_MassUnit')
		delvarx, cme_kins_temp
		save, cme_kins, filename=out_dir+'/cme_kins/cme_kins_savgol_'+t_label+extn+'.sav'
	endif
	if file_exist(out_dir+'/cme_kins/cme_kins_quadratic_'+t_label+extn+'.sav') then begin
		restore, out_dir+'/cme_kins/cme_kins_quadratic_'+t_label+extn+'.sav'
        	cme_kins_temp = add_tag(cme_kins,max_cme_mass,'CME_Mass')
		delvarx, cme_kins
		cme_kins = add_tag(cme_kins_temp,'grams','CME_MassUnit')
		delvarx, cme_kins_temp
        	save, cme_kins, filename=out_dir+'/cme_kins/cme_kins_quadratic_'+t_label+extn+'.sav'
	endif
	if file_exist(out_dir+'/cme_kins/cme_kins_linear_'+t_label+extn+'.sav') then begin
		restore, out_dir+'/cme_kins/cme_kins_linear_'+t_label+extn+'.sav'
        	cme_kins_temp = add_tag(cme_kins,max_cme_mass,'CME_Mass')
		delvarx, cme_kins
		cme_kins = add_tag(cme_kins_temp,'grams','CME_MassUnit')
		delvarx, cme_kins_temp
        	save, cme_kins, filename=out_dir+'/cme_kins/cme_kins_linear_'+t_label+extn+'.sav'
	endif

	endfor 


	jump4:
endfor 


end
