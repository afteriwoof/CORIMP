;Created	20111014	to take in the mask of height-time profiles generated in fina_pa_heights_all_redo.pro and use it to trace the increasing profiles per CME.

;INPUT:		plots_fls	- list of plots*sav fls
;		plots_list	- restored list of the plots_list*sav


pro find_pa_heights_masked, pa_total, detection_info, plots_fls, plots_list, plot_prof=plot_prof, loud=loud, pauses=pauses

window, xs=1400, ys=1400
!p.multi = [0,1,2]
if keyword_set(plot_prof) then !p.multi=0
!p.charsize=1.5

set_line_color

occulter_crossing = 6000.

; flag when crosses occulter
occulter_flag = 0

; get the mask
restore, 'cme_prof_0.sav';,/ver
sz = size(cme_prof,/dim)
mask = intarr(sz[0]+1,sz[1])
mask[0:sz[0]-1,*] = smooth(cme_prof,10)
mask[0:4,*] = 0
mask[*,0:4] = 0
mask[*,(sz[1]-6):(sz[1]-1)] = 0
mask[(sz[0]-7):(sz[0]-1),*] = 0
mask = dilate(mask,replicate(1,3,3))
for i=0,4 do mask[i,*] = mask[5,*]
for i=0,5 do mask[sz[0]-i-1,*] = mask[sz[0]-7,*]
sz_mask = size(mask, /dim)

sz = size(detection_info,/dim)
if size(sz,/dim) eq 1 then loop_end = 0 else loop_end = sz[1]-1

for i=0,loop_end do begin
; looping over each CME detection ROI

	for k_count=detection_info[0,i],detection_info[1,i] do begin
;	for k_count=43,detection_info[1,i] do begin
		;looping over each position angle
		k = k_count
		if k gt 359 then k-=360
		if k lt 0 then k+=360
		if keyword_set(loud) then print, 'Position angle: ', k
		plot_image, pa_total, xtit='Position Angle (deg)', ytit='Image No. (time)'
		legend, 'Pos.ang. '+int2str(k)
		plots, [detection_info[0,i],detection_info[0,i]], [detection_info[2,i],detection_info[3,i]], line=1
                plots, [detection_info[1,i],detection_info[1,i]], [detection_info[2,i],detection_info[3,i]], line=1
                plots, [detection_info[0,i],detection_info[1,i]], [detection_info[2,i],detection_info[2,i]], line=1
                plots, [detection_info[0,i],detection_info[1,i]], [detection_info[3,i],detection_info[3,i]], line=1
		plots, [k,k], [detection_info[2,i],detection_info[3,i]]

		; flag when crosses occulter
		occulter_flag = 0
		
		prof = pa_total[k,detection_info[2,i]:detection_info[3,i]]
		;plot, prof, psym=1, yr=[0,20000], /ys, xtit='Image No. (time)', ytit='Height (arcsec)'
		
		plot_image, mask, xtit='Image No. (time)', ytit='Height (arbitrary units)'

		;horline, occulter_crossing/100, line=2, color=5, thick=3
		green_counter = 0

		start_pts = 0

		for j=detection_info[2,i],detection_info[3,i] do begin
		; looping over the detections at this angle
			plots_list_j = plots_list[where(plots_list ge detection_info[2,i] and plots_list le detection_info[3,i])]
			offset = where(plots_list eq plots_list_j[0])
			if j gt detection_info[3,i] then goto, jump1
			if where(plots_list_j eq j) eq [-1] then begin
				if keyword_set(loud) then print, 'no CME?'
				goto, jump1
			endif
			if green_counter eq 0 then green_counter += offset
			restore, plots_fls[green_counter]
			green_counter += 1
			;Find associated height at the angle for this detection(timestep)
			; shift the angle due to how recpol is offset from solar north.
			k_shift = (k+90) mod 360
			recpol, res[0,*]-in.xcen, res[1,*]-in.ycen, res_r, res_theta, /deg
			recpol, xf_out-in.xcen, yf_out-in.ycen, r_out, a_out, /deg
			ind = where(round(res_theta) eq k_shift,cnt)
			ind2 = where(round(a_out) eq k_shift,cnt2)
			if cnt ne 0 then begin
				h = res_r[ind]*in.pix_size
				;plots, replicate(j-detection_info[2,i],n_elements(h)), h, psym=2, color=5
				plots, replicate(j-detection_info[2,i],n_elements(h)), h/100., psym=1, color=5
				for ii=0,n_elements(h)-1 do begin
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
		; this is where to now count up the CME profiles!	
		jump5:
		indx = where(cme_prof_ptsy eq min(cme_prof_ptsy))
		lowest_pt = [cme_prof_ptsx[indx], min(cme_prof_ptsy)] ;[x,y]
		plots, lowest_pt[0], lowest_pt[1]/100, psym=6, color=3, thick=2
;		if keyword_set(pauses) then pause
		; check that the lowest point is within the mask
		if mask[lowest_pt[0],lowest_pt[1]/100] eq 0 then begin
			if keyword_set(loud) then print, 'removing lowest point'
			remove, indx, cme_prof_ptsx
			remove, indx, cme_prof_ptsy
			if keyword_set(loud) then print, 'goto, jump5 ' & goto, jump5
		endif

		definite_x = lowest_pt[0]
		definite_y = lowest_pt[1]
		if keyword_set(loud) then print, '*** Definite point ***'
		plots, definite_x, definite_y/100, psym=6, color=6, thick=1
		;horline, lowest_pt[1]/100
;		if keyword_set(pauses) then pause
		; Want to go up from lowest point, to hit top within mask, then go down in time to lowest earliest joint point, then continue up in time from there to count CME profile.
		allindx = where(cme_prof_ptsx eq (cme_prof_ptsx[indx])[0])
		if n_elements(allindx) eq 1 then begin
			if keyword_set(loud) then print, 'ONLY ONE POINT IN COLUMN ALONG POS ANGLE',k
			if keyword_set(loud) then print, 'removing lowest point'
                        remove, indx, cme_prof_ptsx
                        remove, indx, cme_prof_ptsy
                        if keyword_set(loud) then print, 'goto, jump5 ' & goto, jump5

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
				if keyword_set(loud) then print, 'next_highest_pty ', next_highest_pty
				if keyword_set(loud) then print, 'goto, jump2' & goto, jump2
			endif
			if next_highest_pty gt max_next_highest_pty then max_next_highest_pty=next_highest_pty
			definite_x = [definite_x, cme_prof_ptsx[indx]]
			definite_y = [definite_y, next_highest_pty]
		endfor
		jump2:
		; highest point above lowest staying within mask
		highest_pt = [cme_prof_ptsx[indx], max_next_highest_pty]
                if keyword_set(loud) then print, 'highest_pt ', highest_pt
                plots, highest_pt[0], highest_pt[1]/100, psym=6, color=3, thick=2
		;horline, max_next_highest_pty/100
		definite_x = [definite_x, cme_prof_ptsx[indx]]
		definite_y = [definite_y, max_next_highest_pty]
		plots, definite_x, definite_y/100, psym=6, color=6, thick=1
		if keyword_set(loud) then print, '*** Definite point ***'
;		if keyword_set(pauses) then pause
		;verline, cme_prof_ptsx[indx]
		; now move down the CME profile from here.
		; go to the previous timestep, lowest point
		; but only if there exist points in previous, lower, direction
		if keyword_set(loud) then print, 'cme_prof_ptsx[indx] ', cme_prof_ptsx[indx]
		;if keyword_set(loud) then print, 'where(cme_prof_ptsx lt (cme_prof_ptsx[indx])[0])', where(cme_prof_ptsx lt (cme_prof_ptsx[indx])[0]) 
		if where(cme_prof_ptsx lt (cme_prof_ptsx[indx])[0]) ne [-1] then lower_ptsx = cme_prof_ptsx[where(cme_prof_ptsx lt (cme_prof_ptsx[indx])[0],cnt)] else goto, jump6
		if cnt eq 0 then goto, jump3
		flag = 0
		for test_ptx=1,n_elements(lower_ptsx)-1 do begin
			current_x = lower_ptsx[test_ptx]
			current_col_y = cme_prof_ptsy[where(cme_prof_ptsx eq current_x,cnt)]
			;plots, current_x, max(current_col_y)/100, psym=6, color=3, thick=3
			;plots, current_x, min(current_col_y)/100, psym=6, color=4, thick=3
			if cnt eq 0 then goto, jump3
			for test_pty=0,n_elements(current_col_y)-1 do begin
				;plots, current_x, current_col_y[test_pty]/100, psym=6, color=5
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

		endfor
		; so the earlier, lower, points to work with are lower_ptsx/y_act
		; if there are no earlier lower points then jump6
		if n_elements(lower_ptsx_act) eq 0 AND n_elements(lower_ptsy_act) eq 0 then begin
			if keyword_set(loud) then print, 'There are no earlier, lower points to worry about!'
			if keyword_set(loud) then print, 'goto, jump6 ' & goto, jump6
		endif else begin
			plots, lower_ptsx_act, lower_ptsy_act/100, psym=6, color=3
			if keyword_set(loud) then print, 'plots, lower_ptsx_act, lower_ptsy_act/100, psym=6, color=3'
		endelse
		jump3:
		delvarx, cnt
		earlier = 0
		count_nlpx = 0 ;count next_lower_ptx
		while earlier eq 0 do begin
			if keyword_set(loud) then print, 'earlier = ', earlier
			if keyword_set(loud) then print, 'count_nlpx = ', count_nlpx
			next_lower_ptx = (reverse(lower_ptsx_act[uniq(lower_ptsx_act)]))[count_nlpx]
			if keyword_set(loud) then print, 'next_lower_ptx ', next_lower_ptx
			;check first that it is in same mask block in x-dir, then in y-dir.
			next_lower_pty = min(lower_ptsy_act[where(lower_ptsx_act eq next_lower_ptx)])
			if keyword_set(loud) then print, 'next_lower_pty ', next_lower_pty
			if keyword_set(pauses) then begin
				plots, next_lower_ptx, next_lower_pty/100, psym=2, color=4, thick=3
		;		pause
				plots, lowest_pt[0], lowest_pt[1]/100, psym=2, color=5, thick=3
				if keyword_set(loud) then print, 'lowest_pt ', lowest_pt
		;		pause
				if keyword_set(paues) then plots, [lowest_pt[0],next_lower_ptx], [lowest_pt[1]/100,next_lower_pty/100], psym=-2, color=5, thick=2
		;		pause
			endif
			; from http://www.idlcoyote.com/ip_tips/image_profile.html
			npoints = abs(lowest_pt[0]-next_lower_ptx+1) > abs(lowest_pt[1]/100-next_lower_pty/100+1)
			xloc = next_lower_ptx + (lowest_pt[0]-next_lower_ptx) * findgen(npoints)/(npoints-1)
			yloc = next_lower_pty/100 + (lowest_pt[1]/100-next_lower_pty/100) * findgen(npoints) / (npoints-1)
			test_arr = interpolate(mask, xloc, yloc)
			if where(test_arr eq 0) ne [-1] then begin
				if keyword_set(loud) then print, 'goto, jump4 ' & goto, jump4
			endif
			;points to definitely include!
			definite_x = [definite_x, next_lower_ptx]
			definite_y = [definite_y, next_lower_pty]
			plots, definite_x, definite_y/100, psym=6, color=6, thick=2
			; and with those definites test the points above along same position angle within the mask.
			test_indx = (where(cme_prof_ptsy eq next_lower_pty))
			if n_elements(test_indx) gt 1 then test_indx = test_indx[where(cme_prof_ptsx[test_indx] eq next_lower_ptx)]
			if keyword_set(loud) then print, 'test_indx ', test_indx
			test_allindx = where(cme_prof_ptsx eq (cme_prof_ptsx[test_indx])[0])
			if keyword_set(loud) then print, 'test_allindx ', test_allindx
			for test_pt=1,n_elements(test_allindx)-1 do begin
	                        if keyword_set(loud) then print, 'test_pt ', test_pt
				if keyword_set(loud) then print, 'test_allindx[test_pt] ', test_allindx[test_pt]
	                        next_highest_pty = cme_prof_ptsy[test_allindx[test_pt]]
	                        if keyword_set(loud) then print, 'cme_prof_ptsx[test_indx] ', cme_prof_ptsx[test_indx]
				if keyword_set(loud) then print, 'next_highest_pty ', next_highest_pty
				if keyword_set(pauses) then plots, cme_prof_ptsx[test_indx], next_highest_pty/100, psym=2, color=4
				test_arr = mask[cme_prof_ptsx[test_indx],(lowest_pt[1]/100):(next_highest_pty[0]/100)]
				if keyword_set(loud) then print, 'test_arr ', test_arr
				
				if where(test_arr eq 0) ne [-1] then begin
	                                ;if test_pt eq 1 then goto, jump??? because the lowest point is the highest point!!!
	                                next_highest_pty = cme_prof_ptsy[test_allindx[test_pt-1]]
	                                if keyword_set(loud) then print, 'goto, jump4 ' & goto, jump4
	                        endif
				definite_x = [definite_x, cme_prof_ptsx[test_indx]]
				definite_y = [definite_y, next_highest_pty]
	                	plots, definite_x, definite_y/100, psym=6, color=6, thick=2
			endfor
		;	if keyword_set(pauses) then pause
	                
			jump4:
			count_nlpx += 1
			if count_nlpx ge n_elements(uniq(lower_ptsx_act)) then begin
				if keyword_set(loud) then print, 'count_nlpx ge n_elements(uniq(lower_ptsx_act))'
				earlier=1
			endif
		endwhile
		prev_indx = cme_prof_ptsx[indx]-1
	
		; If there are no previous points to consider just go up this column (i.e. there are no lower_ptsx/y_act)
		jump6:
		
		;plots, definite_x, definite_y/100, psym=5, color=6, thick=3

		if n_elements(lower_ptsx_act) ne 0 then delvarx, lower_ptsx_act
		if n_elements(lower_ptsy_act) ne 0 then delvarx, lower_ptsy_act
	;	pause



		;******************
		; Now go from the definite point up in time and height
		; Going to the next highest point at each timestep (within mask) and taking the points columned below (within mask)!
		if where(cme_prof_ptsx gt (cme_prof_ptsx[indx])[0]) ne [-1] then higher_ptsx = cme_prof_ptsx[where(cme_prof_ptsx gt (cme_prof_ptsx[indx])[0],cnt)] else goto, jump7
		if cnt eq 0 then goto, jump8
		flag = 0
		first_prev = 0
		for test_ptx=1,n_elements(higher_ptsx)-1 do begin
			current_x = higher_ptsx[test_ptx]
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
			if keyword_set(loud) then print, 'plots, current_x, max_higher_ptsy/100, psym=2, color=3, thick=3   ... starting at min'
			plots, current_x, max_higher_ptsy/100, psym=2, color=3, thick=3
			if keyword_set(pauses) then pause
			; if the first point (min) is not within mask, go up for next point as first.
			if mask[current_x, max_higher_ptsy/100] eq 0 then begin
				keep_ind = where(current_col_y ne max_higher_ptsy, cnt)
				if cnt eq 0 then goto, jump9
				current_col_y = current_col_y[keep_ind]
				plots, replicate(current_x, n_elements(current_col_y[keep_ind])), current_col_y[keep_ind]/100, psym=1, color=4, thick=2
				help, keep_ind
				if keyword_set(loud) then print, 'current_col_y[keep_ind] ', current_col_y[keep_ind]
				max_higher_ptsy = min(current_col_y[keep_ind])
				if keyword_set(loud) then print, 'goto, jump10'
				if keyword_set(pauses) then pause
				goto, jump10
			endif 
			if keyword_set(pauses) then pause
			if cnt eq 0 then goto, jump8
			for test_pty=0,n_elements(current_col_y)-1 do begin
				plots, current_x, current_col_y[test_pty]/100, psym=6, color=5
				if current_col_y[test_pty] gt max_higher_ptsy then begin
					test_arr = mask[current_x, (max_higher_ptsy/100):(current_col_y[test_pty]/100)]
					if where(test_arr eq 0) eq [-1] then max_higher_ptsy=current_col_y[test_pty]
				endif
				plots, current_x, max_higher_ptsy/100, psym=2, color=3, thick=3
			endfor
			if keyword_set(pauses) then pause
			if first_prev eq 0 then begin
				if keyword_set(loud) then print, 'first_prev eq ', first_prev
				; from http://www.idlcoyote.com/ip_tips/image_profile.html
	                        npoints = abs(current_x-highest_pt[0]+1) > abs(max_higher_ptsy/100-highest_pt[1]/100+1)
        	                xloc = highest_pt[0]+ (current_x-highest_pt[0]) * findgen(npoints)/(npoints-1)
               	        	yloc = highest_pt[1]/100 + (max_higher_ptsy/100-highest_pt[1]/100) * findgen(npoints) / (npoints-1)
                        	test_arr = interpolate(mask, xloc, yloc)
                        	;print, 'testing between these'
				if keyword_set(paues) then plots, [current_x,highest_pt[0]], [max_higher_ptsy/100,highest_pt[1]/100], psym=-5, color=6, thick=2
				if keyword_set(pauses) then pause
				if where(test_arr eq 0) ne [-1] then begin
					if keyword_set(loud) then print, 'where(test_arr eq 0) ne [-1]'
                                	if keyword_set(loud) then print, 'goto, jump8 ?'; & goto, jump8
					if keyword_set(pauses) then pause
				endif else begin
					if keyword_set(loud) then print, 'where(test_arr eq 0) eq [-1]'
					if keyword_set(loud) then print, 'plots, [highest_pt[0],current_x], [highest_pt[1]/100,max_higher_ptsy/100],psym=-2, color=5'
					if keyword_set(paues) then plots, [highest_pt[0],current_x], [highest_pt[1]/100,max_higher_ptsy/100],psym=-2, color=5
					if keyword_set(pauses) then pause
					if max_higher_ptsy gt occulter_crossing then print, 'OCCULTER CROSSING'
					definite_x = [definite_x, current_x]
					definite_y = [definite_y, max_higher_ptsy]
					if keyword_set(loud) then print, 'plots definites 1'
                                        plots, definite_x, definite_y/100, psym=5, color=6, thick=2
					; add in the below points at this x-col
					for check_down=0,n_elements(current_col_y)-1 do begin
						test_arr = mask[current_x, (current_col_y[check_down]/100):(max_higher_ptsy/100)]
						if where(test_arr eq 0) eq [-1] then begin
							definite_x = [definite_x, current_x]
							definite_y = [definite_y, current_col_y[check_down]]
							if keyword_set(loud) then print, 'plots definites 2'
                                                        plots, definite_x, definite_y/100, psym=5, color=6, thick=2
							endif
					endfor
					prev_max_higher_ptsy = max_higher_ptsy
					prev_x = current_x
					first_prev = 1
				endelse
			endif else begin
				max_higher_ptsy_flag=0
				npoints = abs(current_x-prev_x+1) > abs(max_higher_ptsy/100-prev_max_higher_ptsy/100+1)
                                xloc = prev_x + (current_x-prev_x) * findgen(npoints)/(npoints-1)
                                yloc = prev_max_higher_ptsy/100 + (max_higher_ptsy/100-prev_max_higher_ptsy/100) * findgen(npoints) / (npoints-1)
                                test_arr = interpolate(mask, xloc, yloc)
                                ;print, 'testing between these'
				if keyword_set(loud) then print, 'initial prev_max_higher_ptsy', prev_max_higher_ptsy
				if keyword_set(loud) then print, 'initial max_higher_ptsy ', max_higher_ptsy
				if keyword_set(loud) then print, 'plots, [current_x,prev_x], [max_higher_ptsy/100,prev_max_higher_ptsy/100], psym=-5, color=6, thick=2'
                                if keyword_set(paues) then plots, [current_x,prev_x], [max_higher_ptsy/100,prev_max_higher_ptsy/100], psym=-5, color=6, thick=2
				if keyword_set(pauses) then pause
				if where(test_arr eq 0) ne [-1] then begin
                                	if keyword_set(loud) then print, 'where(test_arr eq 0) ne [-1] - crosses zeroes!'
				     	;if keyword_set(loud) then print, 'goto, jump8 ?'; & goto, jump8
                                	;if keyword_set(loud) then print, 'do a check down'
					for check_down=0,n_elements(current_col_y)-1 do begin
						if keyword_set(loud) then print, 'check_down ', check_down
						if keyword_set(loud) then print, 'current_col_y[check_down] ', current_col_y[check_down]
						if keyword_set(loud) then print, 'plots, current_x, current_col_y[check_down]/100, psym=6, color=5, thick=4'
						plots, current_x, current_col_y[check_down]/100, psym=6, color=5, thick=4
						if keyword_set(pauses) then pause
						if max_higher_ptsy gt current_col_y[check_down] then begin
							if keyword_set(paues) then plots, [current_x,prev_x],[current_col_y[check_down]/100,prev_max_higher_ptsy/100],psym=-2,color=4
							npoints = abs(current_x-prev_x+1) > abs(current_col_y[check_down]/100-prev_max_higher_ptsy/100+1)
							xloc = prev_x + (current_x-prev_x) * findgen(npoints)/(npoints-1)
							yloc = prev_max_higher_ptsy/100 + (current_col_y[check_down]/100 - prev_max_higher_ptsy/100) * findgen(npoints)/(npoints-1)
							col_test_arr = interpolate(mask,xloc,yloc)
							;col_test_arr = mask[current_x, (current_col_y[check_down]/100):(max_higher_ptsy/100)]
							if where(col_test_arr eq 0) eq [-1] then begin
								if max_higher_ptsy gt occulter_crossing then occulter_flag=1
								if keyword_set(loud) then print, 'col_test_arr: check down doesnt cross zeroes'
								if keyword_set(loud) then print, 'plots, current_x, current_col_y[check_down]/100, psym=2, color=3, thick=2'
								plots, current_x, current_col_y[check_down]/100, psym=2, color=3, thick=2
								if max_higher_ptsy_flag eq 0 then begin
									max_higher_ptsy=current_col_y[check_down]
									max_higher_ptsy_flag=1
								endif else begin
									if current_col_y[check_down] gt max_higher_ptsy then max_higher_ptsy=current_col_y[check_down]
								endelse
								definite_x = [definite_x,current_x]
								definite_y = [definite_y,current_col_y[check_down]]
								if keyword_set(loud) then print, 'plots definites 3'
								plots, definite_x, definite_y/100, psym=5, color=6, thick=2
								if keyword_set(loud) then print, 'plots, current_x, max_higher_ptsy/100, psym=6, color=8, thick=5'
								plots, current_x, max_higher_ptsy/100, psym=6, color=8, thick=5
								if keyword_set(pauses) then pause
								if keyword_set(loud) then print, 'plots, [current_x,prev_x], [max_higher_ptsy/100,prev_max_higher_ptsy/100],psym=-2,color=5,thick=3'
								if keyword_set(paues) then plots, [current_x,prev_x], [max_higher_ptsy/100,prev_max_higher_ptsy/100],psym=-2,color=5,thick=3
                                                                if keyword_set(loud) then print, 'max_higher_ptsy ', max_higher_ptsy
								if keyword_set(pauses) then pause
							endif else begin
								if keyword_set(loud) then print, 'col_test_arr: check down crosses zeroes'
								if keyword_set(loud) then print, 'plots, current_x, current_col_y[check_down]/100, psym=6, color=4, thick=2'
								plots, current_x, current_col_y[check_down]/100, psym=6, color=4, thick=2
								if keyword_set(pauses) then pause
							endelse
							if keyword_set(pauses) then pause
						endif
					endfor
					if occulter_flag eq 1 then begin
						if max_higher_ptsy gt prev_max_higher_ptsy then begin
							prev_max_higher_ptsy = max_higher_ptsy
                                        		prev_x = current_x
						endif
					endif else begin
						prev_max_higher_ptsy = max_higher_ptsy
                                                prev_x = current_x
					endelse
				endif else begin
					if keyword_set(loud) then print, 'where(test_arr eq 0) eq [-1]'
					if keyword_set(loud) then print, 'plots, [prev_x,current_x], [prev_max_higher_ptsy/100,max_higher_ptsy/100], psym=-2, color=5'
					if keyword_set(paues) then plots, [prev_x,current_x], [prev_max_higher_ptsy/100,max_higher_ptsy/100], psym=-2, color=5
					definite_x = [definite_x, current_x]
					definite_y = [definite_y, max_higher_ptsy]
					if keyword_set(loud) then print, 'plots definites 4'
                                        plots, definite_x, definite_y/100, psym=5, color=6, thick=2
					; add in the below points at this x-col
					for check_down=0,n_elements(current_col_y)-1 do begin
                                                if max_higher_ptsy gt current_col_y[check_down] then begin
							col_test_arr = mask[current_x, (current_col_y[check_down]/100):(max_higher_ptsy/100)]
                                                	if where(col_test_arr eq 0) eq [-1] then begin
                        			                if max_higher_ptsy gt occulter_crossing then occulter_flag=1
			                        	        definite_x = [definite_x, current_x]
                                                	        definite_y = [definite_y, current_col_y[check_down]]
                                        			if keyword_set(loud) then print, 'plots definites 5'
                                                                plots, definite_x, definite_y/100, psym=5, color=6, thick=2
					        	endif
						endif
                                        endfor
					if occulter_flag eq 1 then begin
						if max_higher_ptsy gt prev_max_higher_ptsy then begin
							prev_max_higher_ptsy = max_higher_ptsy
							prev_x = current_x
						endif
					endif else begin
						prev_max_higher_ptsy = max_higher_ptsy
						prev_x = current_x
					endelse
				endelse
			endelse
		
			jump9:
	
		endfor
		delvarx, prev_x, prev_max_higher_ptsy

		if keyword_set(loud) then print, 'plots definites 6'
		plots, definite_x, definite_y/100, psym=5, color=4, thick=1.5
		



		jump8:
		jump7:


		x2png, 'scan'+int2str(i)+'_'+int2str(k)+'.png'
	;	wait, 2
		if keyword_set(pauses) then pause		

		plots, definite_x, definite_y/100, psym=6, color=6, thick=3
;		pause
	endfor
endfor
end	
