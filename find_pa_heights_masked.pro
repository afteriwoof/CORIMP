;Created	20111014	to take in the mask of height-time profiles generated in find_pa_heights_all_redo.pro and use it to trace the increasing profiles per CME.

; Last edited:	20111116	included keyword no_plots to make faster running option for code.
;		20111117	to save out definite_x/y as cme_kin_prof_X_X.sav
;		2012-07-23	to input cme_prof_fls for multiple CME detections to be masked out, and all the delvarx at the end!
;		2012-09-19	to fix redundant looping over test_ptx and test_pty
;		2012-12-04	to update from the old_data to the new format of file names.
; 		2012-12-05	to consider the newly scaled mask from find_pa_heights_all_redo.pro cme_profs.

;INPUT:		fls		- the fits files used to generate the other input
;		det_fls		- list of dets*sav files
;		stack_fls	- list of det_stack*sav files.
;		out_dir		- the output directory.

;OUTPUT:	cme_kin_prof_NN_CCC_AAA.sav	where NN=CME number, CCC=profile count, AAA=position angle. It contains definite_x, definite_y, datetime.
;		count_kin_profs_NN.sav		Contains count of how many kin profiles per CME.

;KEYWORDS:	old_data	- for the old format of the naming convention on teh data.



pro find_pa_heights_masked, fls_in, pa_total, detection_info, det_fls, stack_fls, cme_prof_fls, out_dir, plot_prof=plot_prof, loud=loud, pre_loud=pre_loud, pauses=pauses, pngs=pngs, no_plots=no_plots, old_data=old_data, debug=debug

if keyword_set(debug) then begin
        print, '***'
        print, 'find_pa_heights_masked.pro'
        print, '***'
	pause
endif

if ~keyword_set(old_data) then str_count = 23 else str_count = 9

if n_elements(fls_in) ne n_elements(det_fls) then begin
        if keyword_set(debug) then print, 'Number of files do not match det_fls'
        in_times = strmid(file_basename(fls_in), str_count, 15)
        det_times = strmid(file_basename(det_fls), 5, 15)
        fls_loc = where(in_times eq det_times[0])
        for i=1,n_elements(det_times)-1 do begin
                fls_loc = [fls_loc, where(in_times eq det_times[i])]
        endfor
        fls = fls_in[fls_loc]
endif else begin
	fls = fls_in
endelse

mreadfits_corimp, fls, hdrs
mreadfits_corimp, fls_in, all_hdrs

if n_elements(out_dir) eq 0 then out_dir='.'

if n_elements(stack_fls) gt 1 then begin
        for j=0,n_elements(stack_fls)-1 do begin & $
                if keyword_set(debug) then restore, stack_fls[j], /ver else restore, stack_fls[j] & $
                ; Combining the det_stack.list arrays while making sure that any skips in them are maintained across the combination.
                if j eq 0 then begin & $
                        ;filenames = det_stack.filenames & $
                        ;date_obs = det_stack.date_obs & $
                        det_list = det_stack.list & $
                        list_gap = n_elements(det_stack.filenames) - max(det_stack.list) & $
                endif else begin & $
                        ;filenames = [filenames, det_stack.filenames] & $
                        ;date_obs = [date_obs, det_stack.date_obs] & $
                        det_list = [det_list, det_stack.list+max(det_list)+list_gap] & $
                        list_gap = n_elements(det_stack.filenames) - max(det_stack.list) & $
                endelse & $
        endfor
endif else begin
        restore, stack_fls
        det_list = det_stack.list
endelse

if ~keyword_set(no_plots) then begin
	window, 0, xs=1000, ys=800
	!p.multi = [0,1,2]
	if keyword_set(plot_prof) then !p.multi=0
	!p.charsize=1.5
	
	if keyword_set(plot_prof) then window, 1, xs=800, ys=800
	
	set_line_color
endif

occulter_crossing = 6000.

; flag when crosses occulter
occulter_flag = 0

sz1 = size(detection_info,/dim)
if size(sz1,/dim) eq 1 then loop_end = 0 else loop_end = sz1[1]-1

for i=0,loop_end do begin
if keyword_set(loud) then print, 'Looping over i ', i, ' of ', loop_end; & pause
; looping over each CME detection ROI

	; get the mask
	restore, cme_prof_fls[i];,/ver
	sz = size(cme_prof,/dim)
	mask = intarr(sz[0]+1,sz[1])
	if sz[0]-1 gt 10 then begin
		mask[0:sz[0]-1,*] = smooth(cme_prof,10)
		if keyword_set(loud) then print, 'Smoothing mask by 10'
		mask[0:4,*] = 0
	        mask[*,0:4] = 0
	        mask[*,(sz[1]-6):(sz[1]-1)] = 0
	        mask[(sz[0]-7):(sz[0]-1),*] = 0
	        mask = dilate(mask,replicate(1,3,3))
	        for j=0,4 do mask[j,*] = mask[5,*]
	        for j=0,5 do mask[sz[0]-j-1,*] = mask[sz[0]-7,*]
	endif else begin
		mask[0:sz[0]-1,*] = smooth(cme_prof,(sz[0]-1)*0.9)
		if keyword_set(loud) then print, 'Smoothing mask by ', (sz[0]-1)*0.9
		mask = dilate(mask,replicate(1,3,3))
	endelse
	sz_mask = size(mask, /dim)

	;initialising the count for each kinematic profile determined.
	kin_count = 0

	if ~keyword_set(no_plots) and keyword_set(plot_prof) then begin
		wset, 1
		plot_image, mask
	endif
	;initialising the count of how many kinematic profiles come out
	if detection_info[1,i] gt detection_info[0,i] then count_kin_profs = intarr(detection_info[1,i]-detection_info[0,i]) $
		else count_kin_profs = intarr(360-detection_info[0,i]+detection_info[1,i])

	for k_count=detection_info[0,i],detection_info[1,i] do begin
;	for k_count=137,detection_info[1,i] do begin
		;looping over each position angle
		if keyword_set(loud) then print, 'loop:  k_count = ', k_count
                ;if keyword_set(pauses) then pause
		k = k_count
		if k gt 359 then k-=360
		if k lt 0 then k+=360
		if keyword_set(loud) then print, 'Position angle: ', k
		if ~keyword_set(no_plots) then begin
			wset, 0
			plot_image, pa_total, xtit='Position Angle (deg)', ytit='Image No. (time)'
			;legend, 'Pos.ang. '+int2str(k)
			plots, [detection_info[0,i],detection_info[0,i]], [detection_info[2,i],detection_info[3,i]], line=1
                	plots, [detection_info[1,i],detection_info[1,i]], [detection_info[2,i],detection_info[3,i]], line=1
                	plots, [detection_info[0,i],detection_info[1,i]], [detection_info[2,i],detection_info[2,i]], line=1
                	plots, [detection_info[0,i],detection_info[1,i]], [detection_info[3,i],detection_info[3,i]], line=1
			plots, [k,k], [detection_info[2,i],detection_info[3,i]]
		endif
		; flag when crosses occulter
		occulter_flag = 0
		
		prof = pa_total[k,detection_info[2,i]:detection_info[3,i]]
		;plot, prof, psym=1, yr=[0,20000], /ys, xtit='Image No. (time)', ytit='Height (arcsec)'
		
		if ~keyword_set(no_plots) then plot_image, mask, xtit='Image No. (time)', ytit='Height (arbitrary units)'

		;horline, occulter_crossing/100, line=2, color=5, thick=3
		green_counter = 0

		start_pts = 0

		prof_count = 0 ; initialising the counter for x2png

		for j=detection_info[2,i],detection_info[3,i] do begin
		; looping over the detections at this angle
			if keyword_set(loud) then print, 'loop:  j = detection_info[2,i],detection_info[3,i] -- j=', j
                        ;if keyword_set(pauses) then pause
			det_list_j = det_list[where(det_list ge detection_info[2,i] and det_list le detection_info[3,i])]
			offset = where(det_list eq det_list_j[0])
			if j gt detection_info[3,i] then begin
				if keyword_set(loud) then print, 'goto jump1' & goto, jump1
			endif
			if where(det_list_j eq j) eq [-1] then begin
				if keyword_set(pre_loud) then print, 'no CME?'
				if keyword_set(loud) then print, 'goto jump1' & goto, jump1
			endif
			if green_counter eq 0 then green_counter += offset
			if keyword_set(loud) then print, 'restore, det_fls['+num2str(green_counter)+']' & $
				restore, det_fls[green_counter]
			if keyword_set(loud) then print, 'finished restoring!'
			in = hdrs[green_counter]
			if in.xcen le 0 then in.xcen=in.crpix1
			if in.ycen le 0 then in.ycen=in.crpix2
			green_counter += 1
			;Find associated height at the angle for this detection(timestep)
			; shift the angle due to how recpol is offset from solar north.
			k_shift = (k+90) mod 360
			res = dets.edges
			xf_out = dets.front[0,*]
			yf_out = dets.front[1,*]
			recpol, res[0,*]-in.xcen, res[1,*]-in.ycen, res_r, res_theta, /deg
			recpol, xf_out-in.xcen, yf_out-in.ycen, r_out, a_out, /deg
			ind = where(round(res_theta) eq k_shift,cnt)
			ind2 = where(round(a_out) eq k_shift,cnt2)
			if keyword_set(loud) then print, 'cnt ', cnt
			if cnt ne 0 then begin
				h = res_r[ind]*in.pix_size
				;plots, replicate(j-detection_info[2,i],n_elements(h)), h, psym=2, color=5
				if keyword_set(pauses) then plots, replicate(j-detection_info[2,i],n_elements(h)), h/100., psym=1, color=5
				for ii=0,n_elements(h)-1 do begin
					if keyword_set(loud) then print, 'ii ', ii
					if start_pts eq 0 then begin
						cme_prof_ptsx = j-detection_info[2,i]
						cme_prof_ptsy = h[ii]
						start_pts = 1
					endif else begin
						cme_prof_ptsx = [cme_prof_ptsx,j-detection_info[2,i]]
						cme_prof_ptsy = [cme_prof_ptsy,h[ii]]
					endelse
				endfor
			endif
			delvarx, cnt
			jump1:
		endfor
		if keyword_set(loud) then print, 'finished loop!'
		if n_elements(cme_prof_ptsy) eq 0 then begin
			if keyword_set(loud) then print, 'goto, jump8' & goto, jump8
		endif
		; this is where to now count up the CME profiles!	
		jump5:
		indx = where(cme_prof_ptsy eq min(cme_prof_ptsy))
		lowest_pt = [cme_prof_ptsx[indx], min(cme_prof_ptsy)] ;[x,y]
		if keyword_set(pauses) then plots, lowest_pt[0], lowest_pt[1]/100, psym=6, color=3, thick=2
;		if keyword_set(pauses) then pause
		; check that the lowest point is within the mask
		if lowest_pt[0] ge sz_mask[0] then begin
			if keyword_set(loud) then print, 'goto, jump8' & goto, jump8
		endif
		if mask[lowest_pt[0],lowest_pt[1]/100] eq 0 then begin
			if keyword_set(pre_loud) then print, 'removing lowest point'
			if n_elements(indx) lt n_elements(cme_prof_ptsx) then begin
				remove, indx, cme_prof_ptsx
				remove, indx, cme_prof_ptsy
			endif else begin
				if keyword_set(pre_loud) then print, 'goto, jump8 ' & goto, jump8
			endelse
			if keyword_set(pre_loud) then print, 'goto, jump5 ' & goto, jump5
		endif

		definite_x = lowest_pt[0]
		definite_y = lowest_pt[1]
		if keyword_set(pre_loud) then begin
			print, '*** Definite point ***'
			if keyword_set(pauses) then plots, definite_x, definite_y/100, psym=6, color=6, thick=1
		endif
		;horline, lowest_pt[1]/100
;		if keyword_set(pauses) then pause
		; Want to go up from lowest point, to hit top within mask, then go down in time to lowest earliest joint point, then continue up in time from there to count CME profile.
		allindx = where(cme_prof_ptsx eq (cme_prof_ptsx[indx])[0])
		if n_elements(allindx) eq 1 then begin
			if keyword_set(pre_loud) then print, 'ONLY ONE POINT IN COLUMN ALONG POS ANGLE',k
			if keyword_set(pre_loud) then print, 'removing lowest point'
                        if n_elements(indx) lt n_elements(cme_prof_ptsx) then begin
				remove, indx, cme_prof_ptsx
                        	remove, indx, cme_prof_ptsy
                        endif else begin
				if keyword_set(pre_loud) then print, 'goto, jump11 ' & goto, jump11 ;used to goto jump9 but got error about jumping into a loop illegally.
			endelse
			if keyword_set(pre_loud) then print, 'goto, jump5 ' & goto, jump5

		endif
		;test for highest point without jumping the mask
		testim = mask
		max_next_highest_pty = lowest_pt[1] ; intialising the variable to find the max along pos angle (within mask col)
		for test_pt=1,n_elements(allindx)-1 do begin
			;print, 'cme_prof_ptsy[allindx[test_pt]] ', cme_prof_ptsy[allindx[test_pt]]
			next_highest_pty = cme_prof_ptsy[allindx[test_pt]]
			test_arr = mask[cme_prof_ptsx[indx],(lowest_pt[1]/100):(next_highest_pty[0]/100)]
			if where(test_arr eq 0) ne [-1] then begin
				;if test_pt eq 1 then goto, jump??? because the lowest point is the highest point!!!
				next_highest_pty = cme_prof_ptsy[allindx[test_pt-1]]
				if keyword_set(pre_loud) then print, 'next_highest_pty ', next_highest_pty
				if keyword_set(pre_loud) then print, 'goto, jump2' & goto, jump2
			endif
			if next_highest_pty gt max_next_highest_pty then max_next_highest_pty=next_highest_pty
			definite_x = [definite_x, cme_prof_ptsx[indx]]
			definite_y = [definite_y, next_highest_pty]
		endfor
		jump2:
		; highest point above lowest staying within mask
		highest_pt = [cme_prof_ptsx[indx], max_next_highest_pty]
                if keyword_set(pre_loud) then print, 'highest_pt ', highest_pt
                if keyword_set(pauses) then plots, highest_pt[0], highest_pt[1]/100, psym=6, color=3, thick=2
		;horline, max_next_highest_pty/100
		definite_x = [definite_x, cme_prof_ptsx[indx]]
		definite_y = [definite_y, max_next_highest_pty]
		if keyword_set(pre_loud) then begin
			print, '*** Definite point ***'
			if keyword_set(pauses) then plots, definite_x, definite_y/100, psym=6, color=6, thick=1
		endif
;		if keyword_set(pauses) then pause
		;verline, cme_prof_ptsx[indx]
		; now move down the CME profile from here.
		; go to the previous timestep, lowest point
		; but only if there exist points in previous, lower, direction
		if keyword_set(pre_loud) then print, 'cme_prof_ptsx[indx] ', cme_prof_ptsx[indx]
		;if keyword_set(loud) then print, 'where(cme_prof_ptsx lt (cme_prof_ptsx[indx])[0])', where(cme_prof_ptsx lt (cme_prof_ptsx[indx])[0]) 
		if where(cme_prof_ptsx lt (cme_prof_ptsx[indx])[0]) ne [-1] then begin
			lower_ptsx = cme_prof_ptsx[where(cme_prof_ptsx lt (cme_prof_ptsx[indx])[0],cnt)]
		endif else begin
			if keyword_set(loud) then print, 'goto, jump6' & goto, jump6
		endelse
		if cnt eq 0 then begin
			if keyword_set(loud) then print, 'goto, jump3' & goto, jump3
		endif
		if keyword_set(loud) then print, 'flag = 0' & flag = 0
		uniq_lower_ptsx = lower_ptsx[uniq(lower_ptsx)]
		for test_ptx=1,n_elements(uniq_lower_ptsx)-1 do begin
			if keyword_set(loud) then print, 'test_ptx ', test_ptx
			if ~keyword_set(no_plots) then plots, definite_x, definite_y/100, psym=2, color=4
			current_x = uniq_lower_ptsx[test_ptx]
			current_col_y = cme_prof_ptsy[where(cme_prof_ptsx eq current_x,cnt)]
			; only test the current_col_y that are lower then definite_y
			if where(current_col_y lt max(definite_y)) eq [-1] then goto, jump12
			test_current_col_y = current_col_y[where(current_col_y lt max(definite_y))]
			test_current_x = current_x[where(current_col_y lt max(definite_y))]
			current_x = test_current_x[uniq(test_current_x)]
			current_col_y = test_current_col_y
			if exist(prev_current_x) eq 1 then begin
				if current_x eq prev_current_x then goto, jump12
			endif
			prev_current_x = current_x
			;plots, current_x, max(current_col_y)/100, psym=6, color=3, thick=3
			;plots, current_x, min(current_col_y)/100, psym=6, color=4, thick=3
			if cnt eq 0 then begin
				if keyword_set(loud) then print, 'goto, jump3' & goto, jump3
			endif
			for test_pty=0,n_elements(current_col_y)-1 do begin
				if keyword_set(loud) then print, 'test_pty ', test_pty
				if ~keyword_set(no_plots) then plots, current_x, current_col_y[test_pty]/100, psym=6, color=5
				if ~keyword_set(no_plots) then plots, [definite_x, current_x], [definite_y/100, current_col_y[test_pty]/100], color=3
				;print, 'current_col_y[test_pty] ', current_col_y[test_pty]
				;pause
				; don't need to restrict it lower than highest point on first column detection 
				;if current_col_y[test_pty] lt max_next_highest_pty then begin
                                	if flag eq 0 then begin
						lower_ptsy_act=current_col_y[test_pty]
						lower_ptsx_act=current_x
					endif else begin
						lower_ptsy_act = [lower_ptsy_act, current_col_y[test_pty]]
						lower_ptsx_act=[lower_ptsx_act,current_x]
					endelse
					;plots, current_x, current_col_y[test_pty]/100, psym=6, color=7
					flag=1
				;endif
			endfor
			jump12:
		endfor
		; so the earlier, lower, points to work with are lower_ptsx/y_act
		; if there are no earlier lower points then jump6
		if n_elements(lower_ptsx_act) eq 0 AND n_elements(lower_ptsy_act) eq 0 then begin
			if keyword_set(pre_loud) then print, 'There are no earlier, lower points to worry about!'
			if keyword_set(pre_loud) then print, 'goto, jump6 ' & goto, jump6
		endif else begin
			if keyword_set(pauses) then plots, lower_ptsx_act, lower_ptsy_act/100, psym=6, color=3
			if keyword_set(pre_loud) then print, 'plots, lower_ptsx_act, lower_ptsy_act/100, psym=6, color=3'
		endelse
		jump3:
		delvarx, cnt
		earlier = 0
		count_nlpx = 0 ;count next_lower_ptx
		while earlier eq 0 do begin
			if keyword_set(pre_loud) then print, 'earlier = ', earlier
			if keyword_set(pre_loud) then print, 'count_nlpx = ', count_nlpx
			next_lower_ptx = (reverse(lower_ptsx_act[uniq(lower_ptsx_act)]))[count_nlpx]
			if keyword_set(pre_loud) then print, 'next_lower_ptx ', next_lower_ptx
			;check first that it is in same mask block in x-dir, then in y-dir.
			next_lower_pty = min(lower_ptsy_act[where(lower_ptsx_act eq next_lower_ptx)])
			if keyword_set(pre_loud) then print, 'next_lower_pty ', next_lower_pty
			if keyword_set(pauses) then begin
				plots, next_lower_ptx, next_lower_pty/100, psym=2, color=0, thick=1
		;		pause
				plots, lowest_pt[0], lowest_pt[1]/100, psym=2, color=5, thick=3
				if keyword_set(pre_loud) then print, 'lowest_pt ', lowest_pt
		;		pause
;				if keyword_set(pauses) then plots, [lowest_pt[0],next_lower_ptx], [lowest_pt[1]/100,next_lower_pty/100], psym=-2, color=5, thick=1
		;		pause
			endif
			; from http://www.idlcoyote.com/ip_tips/image_profile.html
			npoints = abs(lowest_pt[0]-next_lower_ptx+1) > abs(lowest_pt[1]/100-next_lower_pty/100+1)
			xloc = next_lower_ptx + (lowest_pt[0]-next_lower_ptx) * findgen(npoints)/(npoints-1)
			yloc = next_lower_pty/100 + (lowest_pt[1]/100-next_lower_pty/100) * findgen(npoints) / (npoints-1)
			test_arr = interpolate(mask, xloc, yloc)
			if where(test_arr eq 0) ne [-1] then begin
				if keyword_set(pre_loud) then print, 'goto, jump4 ' & goto, jump4
			endif
			;points to definitely include!
			definite_x = [definite_x, next_lower_ptx]
			definite_y = [definite_y, next_lower_pty]
			if keyword_set(pauses) then plots, definite_x, definite_y/100, psym=6, color=6, thick=1
			; and with those definites test the points above along same position angle within the mask.
			test_indx = (where(cme_prof_ptsy eq next_lower_pty))
			if n_elements(test_indx) gt 1 then test_indx = test_indx[where(cme_prof_ptsx[test_indx] eq next_lower_ptx)]
			if keyword_set(pre_loud) then print, 'test_indx ', test_indx
			test_allindx = where(cme_prof_ptsx eq (cme_prof_ptsx[test_indx])[0])
			if keyword_set(pre_loud) then print, 'test_allindx ', test_allindx
			for test_pt=1,n_elements(test_allindx)-1 do begin
	                        if keyword_set(pre_loud) then print, 'test_pt ', test_pt
				if keyword_set(pre_loud) then print, 'test_allindx[test_pt] ', test_allindx[test_pt]
	                        next_highest_pty = cme_prof_ptsy[test_allindx[test_pt]]
	                        if keyword_set(pre_loud) then print, 'cme_prof_ptsx[test_indx] ', cme_prof_ptsx[test_indx]
				if keyword_set(pre_loud) then print, 'next_highest_pty ', next_highest_pty
				if keyword_set(pauses) then plots, cme_prof_ptsx[test_indx], next_highest_pty/100, psym=2, color=6
				test_arr = mask[cme_prof_ptsx[test_indx],(lowest_pt[1]/100):(next_highest_pty[0]/100)]
				if keyword_set(pre_loud) then print, 'test_arr ', test_arr
				
				if where(test_arr eq 0) ne [-1] then begin
	                                ;if test_pt eq 1 then goto, jump??? because the lowest point is the highest point!!!
	                                next_highest_pty = cme_prof_ptsy[test_allindx[test_pt-1]]
	                                if keyword_set(pre_loud) then print, 'goto, jump4 ' & goto, jump4
	                        endif
				definite_x = [definite_x, cme_prof_ptsx[test_indx]]
				definite_y = [definite_y, next_highest_pty]
	                	if keyword_set(pauses) then plots, definite_x, definite_y/100, psym=6, color=6, thick=1
			endfor
		;	if keyword_set(pauses) then pause
	                
			jump4:
			count_nlpx += 1
			if count_nlpx ge n_elements(uniq(lower_ptsx_act)) then begin
				if keyword_set(pre_loud) then print, 'count_nlpx ge n_elements(uniq(lower_ptsx_act))'
				earlier=1
			endif
		endwhile
		prev_indx = cme_prof_ptsx[indx]-1
	
		; If there are no previous points to consider just go up this column (i.e. there are no lower_ptsx/y_act)
		jump6:
		
		;plots, definite_x, definite_y/100, psym=5, color=6, thick=3

		if n_elements(lower_ptsx_act) ne 0 then delvarx, lower_ptsx_act
		if n_elements(lower_ptsy_act) ne 0 then delvarx, lower_ptsy_act



		;******************************************************************************************************************************************************************
		; Now go from the definite point up in time and height
		; Going to the next highest point at each timestep (within mask) and taking the points columned below (within mask)!
		if where(cme_prof_ptsx gt (cme_prof_ptsx[indx])[0]) ne [-1] then higher_ptsx = cme_prof_ptsx[where(cme_prof_ptsx gt (cme_prof_ptsx[indx])[0],cnt)] else goto, jump7
		if cnt eq 0 then goto, jump8
		flag = 0
		first_prev = 0
		for test_ptx=1L,n_elements(higher_ptsx)-1 do begin
			if keyword_set(loud) then print, 'loop:  test_ptx = ', test_ptx, ' of', n_elements(higher_ptsx)-1
			;if keyword_set(pauses) then pause
			current_x = higher_ptsx[test_ptx]
			add_to_defs = 0
			if keyword_set(pauses) then verline, current_x, line=1, color=7
			if test_ptx ne 1 then begin
				if current_x eq prev_current_x then begin
					if keyword_set(loud) then print, 'current_x eq prev_current_x --> goto, jump9'
					goto, jump9
				endif
			endif
			prev_current_x = current_x	
			current_col_y = cme_prof_ptsy[where(cme_prof_ptsx eq current_x,cnt)]
			;starting from the bottom and counting up through to the highest
			max_higher_ptsy = min(cme_prof_ptsy[where(cme_prof_ptsx eq current_x)])
			jump10:
			if keyword_set(loud) then begin
				print, 'plots, current_x, max_higher_ptsy/100, psym=2, color=5, thick=3   ... starting at min'
				plots, current_x, max_higher_ptsy/100, psym=2, color=5, thick=3
			endif
			if keyword_set(pauses) then pause
			; if the first point (min) is not within mask, go up for next point as first.
			if current_x ge sz_mask[0] then goto, jump8
			if mask[current_x, max_higher_ptsy/100] eq 0 then begin
				keep_ind = where(current_col_y ne max_higher_ptsy, cnt)
				if cnt eq 0 then begin
					if keyword_set(loud) then print, 'cnt eq 0 --> goto, jump9'
					goto, jump9
				endif
				current_col_y = current_col_y[keep_ind]
				if keyword_set(pauses) then plots, replicate(current_x, n_elements(current_col_y[keep_ind])), current_col_y[keep_ind]/100, psym=1, color=6, thick=1
				if keyword_set(loud) then print, 'current_col_y[keep_ind] ', current_col_y[keep_ind]
				max_higher_ptsy = min(current_col_y[keep_ind])
				if keyword_set(loud) then print, 'goto, jump10'
				if keyword_set(pauses) then pause
				goto, jump10
			endif 
			if cnt eq 0 then begin
				print, 'cnt eq 0 --> goto, jump9 (used to be jump8)'
				goto, jump9  ; used to be jump8???
			endif
; uncomment the read ans bits to skip cases in pausing for inspecting code!
;			ans = 'y'
;			read, 'skip? ', ans
			for test_pty=0,n_elements(current_col_y)-1 do begin
				if keyword_set(loud) then begin
					print, 'plots, current_x, current_col_y[test_pty]/100, psym=6, color=5, thick=3'
					plots, current_x, current_col_y[test_pty]/100, psym=6, color=5, thick=3
				endif
;				if ans eq 'n' then pause
				if current_col_y[test_pty] gt max_higher_ptsy then begin
					if keyword_set(loud) then print, 'current_col_y[test_pty] gt max_higher_ptsy'
					test_arr = mask[current_x, (max_higher_ptsy/100):(current_col_y[test_pty]/100)]
					if keyword_set(loud) then print, 'where(test_arr eq 0) eq ', where(test_arr eq 0)
					if where(test_arr eq 0) eq [-1] then max_higher_ptsy=current_col_y[test_pty]
				endif
				if keyword_set(pauses) then plots, current_x, max_higher_ptsy/100, psym=2, color=(test_pty mod 7)+2, thick=5
				if keyword_set(loud) then print, 'current_x, max_higher_ptsy/100', current_x, max_higher_ptsy/100
;				if ans eq 'n' then pause
			endfor
			if keyword_set(pauses) then pause
			if first_prev eq 0 then begin
				add_to_defs = 0
				; from http://www.idlcoyote.com/ip_tips/image_profile.html
	                        npoints = abs(current_x-highest_pt[0]+1) > abs(max_higher_ptsy/100-highest_pt[1]/100+1)
        	                xloc = highest_pt[0]+ (current_x-highest_pt[0]) * findgen(npoints)/(npoints-1)
               	        	yloc = highest_pt[1]/100 + (max_higher_ptsy/100-highest_pt[1]/100) * findgen(npoints) / (npoints-1)
                        	test_arr = interpolate(mask, xloc, yloc)
                        	if keyword_set(loud) then print, 'first_prev eq 0: testing between these'
				if keyword_set(pauses) then plots, [current_x,highest_pt[0]], [max_higher_ptsy/100,highest_pt[1]/100], psym=-5, color=5, thick=1
				if keyword_set(pauses) then pause
				if where(test_arr eq 0) ne [-1] then begin
					if keyword_set(loud) then print, 'where(test_arr eq 0) ne [-1]'
                                	if keyword_set(loud) then print, 'goto, jump8 ?'; & goto, jump8
					if keyword_set(pauses) then pause
				endif else begin
					if keyword_set(loud) then print, 'where(test_arr eq 0) eq [-1]'
					if keyword_set(loud) then print, 'plots, [highest_pt[0],current_x], [highest_pt[1]/100,max_higher_ptsy/100],psym=-2, color=5'
					if keyword_set(pauses) then plots, [highest_pt[0],current_x], [highest_pt[1]/100,max_higher_ptsy/100],psym=-2, color=5
					if keyword_set(pauses) then pause
					if max_higher_ptsy gt occulter_crossing and keyword_set(loud) then print, 'OCCULTER CROSSING'
					add_to_defs = 1
					if keyword_set(loud) then print, 'add_to_defs = 1'
					if keyword_set(pauses) then pause
					definite_x = [definite_x, current_x]
					definite_y = [definite_y, max_higher_ptsy]
					if keyword_set(loud) then begin
						print, 'plots definites 1'
						print, 'plots, definite_x, definite_y/100, psym=5, color=6, thick=1'
                                        	plots, definite_x, definite_y/100, psym=5, color=6, thick=1
					endif
					; add in the below points at this x-col
					if keyword_set(loud) then print, 'n_elements(current_col_y) ', n_elements(current_col_y)
					for check_down=0,n_elements(current_col_y)-1 do begin
						if keyword_set(loud) then print, 'check_down ', check_down, ' of ', n_elements(current_col_y)-1
						if max_higher_ptsy gt current_col_y[check_down] then begin
							if keyword_set(loud) then begin
								print, 'max_higher_ptsy gt current_col_y[check_down]'
								if keyword_set(pauses) then pause
							endif
							test_arr_2 = mask[current_x, (current_col_y[check_down]/100):(max_higher_ptsy/100)]
							if keyword_set(loud) then begin
								print, 'this is the test_arr: '
								plots, [current_x,current_x],[current_col_y[check_down]/100,max_higher_ptsy/100], psym=-2, color=0
							endif
							if where(test_arr_2 eq 0) eq [-1] then begin
	       	                                                definite_x = [definite_x, current_x]
	                                                        definite_y = [definite_y, current_col_y[check_down]]
	                                                        if keyword_set(loud) then begin
									print, 'plots definites 2'
	                                                        	plots, definite_x, definite_y/100, psym=5, color=6, thick=1
				                        	endif
							endif
                                                if keyword_set(pauses) then pause
						endif else begin
							if add_to_defs eq 1 then begin
								prev_max_higher_ptsy = max_higher_ptsy
								prev_x = current_x
								first_prev = 1
							endif else begin
								goto, jump9
							endelse
						endelse
;						if where(test_arr_2 eq 0) eq [-1] then begin
;							definite_x = [definite_x, current_x]
;							definite_y = [definite_y, current_col_y[check_down]]
;							if keyword_set(loud) then print, 'plots definites 2'
;							plots, definite_x, definite_y/100, psym=5, color=6, thick=1 & pause
;						endif
						if keyword_set(pauses) then pause
					endfor
					if keyword_set(pauses) then pause
					if add_to_defs eq 1 then begin
						prev_max_higher_ptsy = max_higher_ptsy
						prev_x = current_x
						if keyword_set(loud) then begin
							print, 'prev_max_higher_ptsy = max_higher_ptsy'
                                                	print, 'prev_x = current_x'
						endif
					endif
					first_prev = 1
					if keyword_set(loud) then print, 'first_prev = 1'
				endelse
			endif else begin
				add_to_defs = 0
				max_higher_ptsy_flag=0
				npoints = abs(current_x-prev_x+1) > abs(max_higher_ptsy/100-prev_max_higher_ptsy/100+1)
                                xloc = prev_x + (current_x-prev_x) * findgen(npoints)/(npoints-1)
                                yloc = prev_max_higher_ptsy/100 + (max_higher_ptsy/100-prev_max_higher_ptsy/100) * findgen(npoints) / (npoints-1)
                                test_arr = interpolate(mask, xloc, yloc)
                                if keyword_set(loud) then print, 'first_prev ne 0: testing between these'
				if keyword_set(loud) then print, 'initial prev_max_higher_ptsy', prev_max_higher_ptsy
				if keyword_set(loud) then print, 'initial max_higher_ptsy ', max_higher_ptsy
				if keyword_set(loud) then print, 'plots, [current_x,prev_x], [max_higher_ptsy/100,prev_max_higher_ptsy/100], psym=-5, color=5, thick=2'
                                if keyword_set(pauses) then plots, [current_x,prev_x], [max_higher_ptsy/100,prev_max_higher_ptsy/100], psym=-5, color=5, thick=2
				if keyword_set(pauses) then pause
				if where(test_arr eq 0) ne [-1] then begin
                                	if keyword_set(loud) then print, 'where(test_arr eq 0) ne [-1] - crosses zeroes!'
				     	;if keyword_set(loud) then print, 'goto, jump8 ?'; & goto, jump8
                                	;if keyword_set(loud) then print, 'do a check down'
					for check_down=0,n_elements(current_col_y)-1 do begin
						if keyword_set(loud) then print, 'check_down ', check_down
						if keyword_set(loud) then print, 'max_higher_ptsy ', max_higher_ptsy
						if keyword_set(loud) then print, 'current_col_y[check_down] ', current_col_y[check_down]
						if keyword_set(loud) then begin
							print, 'plots, current_x, current_col_y[check_down]/100, psym=6, color=5, thick=4'
							plots, current_x, current_col_y[check_down]/100, psym=6, color=5, thick=4
						endif
						if keyword_set(pauses) then pause
						if max_higher_ptsy ne current_col_y[check_down] then begin ;used to be gt instead of ne but changed on 20111109
							if keyword_set(pauses) then plots, [current_x,prev_x],[current_col_y[check_down]/100,prev_max_higher_ptsy/100],psym=-2,color=6
							npoints = abs(current_x-prev_x+1) > abs(current_col_y[check_down]/100-prev_max_higher_ptsy/100+1)
							xloc = prev_x + (current_x-prev_x) * findgen(npoints)/(npoints-1)
							yloc = prev_max_higher_ptsy/100 + (current_col_y[check_down]/100 - prev_max_higher_ptsy/100) * findgen(npoints)/(npoints-1)
							col_test_arr = interpolate(mask,xloc,yloc)
							;col_test_arr = mask[current_x, (current_col_y[check_down]/100):(max_higher_ptsy/100)]
							if where(col_test_arr eq 0) eq [-1] then begin
								if max_higher_ptsy gt occulter_crossing then occulter_flag = 1
								if keyword_set(loud) then print, 'col_test_arr: check down doesnt cross zeroes'
								if keyword_set(pauses) then pause
								if keyword_set(loud) then print, 'plots, current_x, current_col_y[check_down]/100, psym=2, color=3, thick=2'
								if keyword_set(pauses) then plots, current_x, current_col_y[check_down]/100, psym=2, color=3, thick=2
								if max_higher_ptsy_flag eq 0 then begin
									max_higher_ptsy=current_col_y[check_down]
									max_higher_ptsy_flag=1
								endif else begin
									if current_col_y[check_down] gt max_higher_ptsy then max_higher_ptsy=current_col_y[check_down]
								endelse
								if keyword_set(loud) then print, 'Adding to definite_x/y'
								add_to_defs = 1
								if keyword_set(loud) then print, 'add_to_defs = 1'
								;if keyword_set(pauses) then pause
								definite_x = [definite_x,current_x]
								definite_y = [definite_y,current_col_y[check_down]]
								if keyword_set(loud) then print, 'plots definites 3'
								if keyword_set(pauses) then plots, definite_x, definite_y/100, psym=5, color=6, thick=1
								if keyword_set(loud) then begin
									print, 'plots, current_x, max_higher_ptsy/100, psym=6, color=8, thick=5'
									plots, current_x, max_higher_ptsy/100, psym=6, color=8, thick=5
								endif
								if keyword_set(pauses) then pause
								if keyword_set(loud) then print, 'plots, [current_x,prev_x], [max_higher_ptsy/100,prev_max_higher_ptsy/100],psym=-2,color=5,thick=3'
								if keyword_set(pauses) then plots, [current_x,prev_x], [max_higher_ptsy/100,prev_max_higher_ptsy/100],psym=-2,color=5,thick=3
                                                                if keyword_set(loud) then print, 'max_higher_ptsy ', max_higher_ptsy
								if keyword_set(pauses) then pause
							endif else begin
								if keyword_set(loud) then print, 'col_test_arr: check down crosses zeroes'
								if keyword_set(loud) then begin
									print, 'plots, current_x, current_col_y[check_down]/100, psym=6, color=5, thick=2'
									plots, current_x, current_col_y[check_down]/100, psym=6, color=5, thick=2
								endif
								if keyword_set(pauses) then pause
							endelse
							if keyword_set(pauses) then pause
						endif
					endfor
					if occulter_flag eq 1 then begin
						if keyword_set(loud) then print, 'occulter_flag eq 1'
						if max_higher_ptsy gt prev_max_higher_ptsy then begin
							if add_to_defs eq 1 then begin
								prev_max_higher_ptsy = max_higher_ptsy
                                        			prev_x = current_x
								if keyword_set(loud) then begin
									print, 'add_to_defs eq 1'
									print, 'max_higher__ptsy gt prev_max_higher_ptsy'
									print, 'prev_max_higher_ptsy = max_higher_ptsy'
                                                		        print, 'prev_x = current_x'
								endif
							endif
						endif
					endif else begin
						if add_to_defs eq 1 then begin
							prev_max_higher_ptsy = max_higher_ptsy
                                                	prev_x = current_x
							if keyword_set(loud) then begin
								print, 'add_to_defs eq 1'
								print, 'occulter_flag ne 1'
								print, 'prev_max_higher_ptsy = max_higher_ptsy'
                                                		print, 'prev_x = current_x'
							endif
						endif
					endelse
					if keyword_set(pauses) then pause
				endif else begin
					add_to_defs = 0
					if keyword_set(loud) then print, 'where(test_arr eq 0) eq [-1]'
					if keyword_set(loud) then print, 'plots, [prev_x,current_x], [prev_max_higher_ptsy/100,max_higher_ptsy/100], psym=-2, color=5'
					if keyword_set(pauses) then plots, [prev_x,current_x], [prev_max_higher_ptsy/100,max_higher_ptsy/100], psym=-2, color=5
					if keyword_set(loud) then print, 'Adding to definites_x/y'
					if keyword_set(pauses) then pause
					definite_x = [definite_x, current_x]
					definite_y = [definite_y, max_higher_ptsy]
					if keyword_set(loud) then begin
						print, 'plots definites 4'
                                        	plots, definite_x, definite_y/100, psym=5, color=6, thick=1
					endif
					; add in the below points at this x-col
					for check_down=0,n_elements(current_col_y)-1 do begin
                                                if max_higher_ptsy gt current_col_y[check_down] then begin
							col_test_arr = mask[current_x, (current_col_y[check_down]/100):(max_higher_ptsy/100)]
                                                	if where(col_test_arr eq 0) eq [-1] then begin
                        			                if max_higher_ptsy gt occulter_crossing then occulter_flag=1
			                        	        add_to_defs = 1
                                                                if keyword_set(loud) then print, 'add_to_defs = 1'
								;if keyword_set(pauses) then pause
								definite_x = [definite_x, current_x]
                                                	        definite_y = [definite_y, current_col_y[check_down]]
                                        			if keyword_set(loud) then begin
									print, 'plots definites 5'
                                                                	plots, definite_x, definite_y/100, psym=5, color=6, thick=1
					        		endif
							endif
						endif
                                        endfor
					if occulter_flag eq 1 then begin
						if max_higher_ptsy gt prev_max_higher_ptsy then begin
							if add_to_defs eq 1 then begin
								prev_max_higher_ptsy = max_higher_ptsy
								prev_x = current_x
							endif
						endif
					endif else begin
						if add_to_defs eq 1 then begin
							prev_max_higher_ptsy = max_higher_ptsy
							prev_x = current_x
						endif
					endelse
				endelse
			endelse
		
			jump9:
	
		endfor
		
		jump11:

		delvarx, prev_x, prev_max_higher_ptsy

		if keyword_set(loud) then begin
		;	print, 'Plotting all points'
		;	plots, cme_prof_ptsx, cme_prof_ptsy/100, psym=6, color=3
		;	plots, cme_prof_ptsx, cme_prof_ptsy/100, psym=2, color=3
		;	if keyword_set(pauses) then pause
			print, 'plots definites 6'
			print, 'Plotting the final definite_y/100 against definite_x'
		endif
		
		plotsym, 0, /fill ;circle
		if ~keyword_set(no_plots) then plots, definite_x, definite_y/100, psym=8, color=4, thick=1.5
		if keyword_set(pauses) then pause

		if all_hdrs[definite_x[0]+detection_info[2,i]].i3_instr eq 'c2' then datetime = all_hdrs[definite_x[0]+detection_info[2,i]].i3_date else datetime = all_hdrs[definite_x[0]+detection_info[2,i]].i4_date
		if (definite_x[n_elements(definite_x)-1]+detection_info[2,i]) lt n_elements(all_hdrs) then temp_end=n_elements(definite_x) else temp_end=n_elements(all_hdrs)-detection_info[2,i]
		;for temp=1,n_elements(definite_x)-1 do begin
		for temp=1L,temp_end-1 do begin
			if all_hdrs[definite_x[temp]+detection_info[2,i]].i3_instr eq 'c2' then datetime = [datetime, all_hdrs[definite_x[temp]+detection_info[2,i]].i3_date] $
				else datetime = [datetime, all_hdrs[definite_x[temp]+detection_info[2,i]].i4_date]
		endfor

		if k lt 10 then ang_int = '00'+int2str(k)
		if k ge 10 AND k lt 100 then ang_int = '0'+int2str(k)
		if k ge 100 then ang_int = int2str(k)
		
		if i lt 10 then begin
			if kin_count lt 10 then save, definite_x, definite_y, datetime, f=out_dir+'/cme_kin_prof_0'+int2str(i)+'_00'+int2str(kin_count)+'_'+ang_int+'.sav'
			if kin_count ge 10 AND kin_count lt 100 then save, definite_x, definite_y, datetime, f=out_dir+'/cme_kin_prof_0'+int2str(i)+'_0'+int2str(kin_count)+'_'+ang_int+'.sav'
			if kin_count ge 100 AND kin_count lt 1000 then save, definite_x, definite_y, datetime, f=out_dir+'/cme_kin_prof_0'+int2str(i)+'_'+int2str(kin_count)+'_'+ang_int+'.sav'
		endif else begin
			if kin_count lt 10 then save, definite_x, definite_y, datetime, f=out_dir+'/cme_kin_prof_'+int2str(i)+'_00'+int2str(kin_count)+'_'+ang_int+'.sav'
                        if kin_count ge 10 AND kin_count lt 100 then save, definite_x, definite_y, datetime, f=out_dir+'/cme_kin_prof_'+int2str(i)+'_0'+int2str(kin_count)+'_'+ang_int+'.sav'
                        if kin_count ge 100 AND kin_count lt 1000 then save, definite_x, definite_y, datetime, f=out_dir+'/cme_kin_prof_'+int2str(i)+'_'+int2str(kin_count)+'_'+ang_int+'.sav'
		endelse

		;save, definite_x, definite_y, f=out_dir+'/cme_kin_prof_'+int2str(i)+'_'+int2str(kin_count)+'.sav'
		if keyword_set(debug) then print, 'Saving definite_x, definite_y, and datetime, as cme_kin_prof_?'+int2str(i)+'_?'+int2str(kin_count)+'_?'+ang_int+'.sav  of ', detection_info[1,i]
		kin_count += 1

		; calculate the centre-of-gravity of the points
		def_x_centre = ave(definite_x)
		def_y_centre = ave(definite_y)
		plotsym, 0;, /fill ;circle
		if ~keyword_set(no_plots) then plots, def_x_centre, def_y_centre/100, psym=8, color=7, symsize=5
		if keyword_set(plot_prof) then begin
			wset, 1
			if ~keyword_set(no_plots) then begin
				plots, def_x_centre, def_y_centre/100, psym=8, color=7, symsize=5
			endif
			wset, 0
		endif
		if n_elements(uniq(definite_x)) gt 1 AND keyword_set(plot_prof) then begin
                        wset,1
			yf = 'p[0]*x + p[1]'
                        f = mpfitexpr(yf, definite_x, definite_y, /quiet)
                        model = f[0]*definite_x + f[1]
			oplot, definite_x, model/100, psym=-3, color=3, thick=3
                        wset,0
                endif
		;pause

		def_uniq = uniq(definite_x)
		for temp=0,n_elements(def_uniq)-1 do begin
			if temp eq 0 then def_x_now = where(cme_prof_ptsx eq definite_x[def_uniq[temp]]) else def_x_now = [def_x_now, where(cme_prof_ptsx eq definite_x[def_uniq[temp]])]
			;def_y_now = where(cme_prof_ptsy eq definite_y[temp])
			;plots, cme_prof_ptsx[def_x_now], cme_prof_ptsy[def_x_now]/100, psym=2, color=6
		endfor
		if keyword_set(pngs) then x2png, out_dir+'/scan'+int2str(i)+'_'+ang_int+'_'+int2str(prof_count)+'.png'

		if k_count lt detection_info[1,i] then count_kin_profs[k_count-detection_info[0,i]] += 1
                if keyword_set(loud) then print, 'count_kin_profs ', count_kin_profs[k_count-detection_info[0,i]]

		; removing the current CME points from all the points
		if n_elements(def_x_now) lt n_elements(cme_prof_ptsx) then begin
			if ~keyword_set(no_plots) then plots, cme_prof_ptsx, cme_prof_ptsy/100, psym=6, color=3
                        if ~keyword_set(no_plots) then plots, cme_prof_ptsx, cme_prof_ptsy/100, psym=2, color=3
			remove, def_x_now, cme_prof_ptsx
			remove, def_x_now, cme_prof_ptsy
			prof_count += 1
			goto, jump5
		endif

		jump8:
		jump7:


;		if keyword_set(pngs) then x2png, 'scan'+int2str(i)+'_'+int2str(k)+'.png'
		;wait, 0.2
		if keyword_set(pauses) then pause		

;		plots, definite_x, definite_y/100, psym=6, color=6, thick=3
;		pause


	endfor

	save, count_kin_profs, f=out_dir+'/count_kin_profs_'+int2str(i)+'.sav'
	if keyword_set(debug) then print, 'Saving '+out_dir+'/count_kin_profs_'+int2str(i)+'.sav'

	if keyword_set(pauses) then pause
	
	delvarx, add_to_defs, allindx, a_out, check_down, cme_prof, cme_prof_ptsx, cme_prof_ptsy, cnt, cnt2, col_test_arr
	delvarx, count_kin_profs, count_nlpx, current_col_y, current_x, definite_x, definite_y, def_uniq, def_x_centre, dets
	delvarx, det_list_j, earlier, f, first_prev, flag, green_counter, h, higher_ptsx, highest_pt, ii
	delvarx, ind, ind2, indx, j, k, keep_ind, kin_count, k_count, k_shift, lower_ptsx
	delvarx, lower_ptsx_act, lower_ptys_act, lowest_pt, mas_higher_ptsy, max_higher_ptsy_flag, max_next_highest_pty, next_lower_ptx, next_lower_pty, npoints, offset
	delvarx, prev_current_x, prev_indx, prev_max_hgiher_ptsy, prev_x, prof, prof_count, res, res_r, res_theta, r_out
	delvarx, start_pts, sz_mask, temp, testim, test_allindx, test_arr, test_arr_2, test_indx, test_pt, test_ptx
	delvarx, test_pty, xf_out, xloc, yf, yf_out, yloc


endfor


end	
