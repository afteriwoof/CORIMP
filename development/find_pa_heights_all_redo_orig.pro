; code that works on original output of detections (non structure output of dets*sav)

;INPUT:		plots_fls	- list of plots*sav fls
;		plots_list	- restored list of the plots_list*sav


pro find_pa_heights_all_redo, pa_total, detection_info, plots_fls, plots_list, plot_prof=plot_prof, loud=loud

if keyword_set(plot_prof) then !p.multi=[0,1,2] else !p.multi=0

sz = size(detection_info, /dim)

if size(sz,/dim) eq 1 then loop_end=0 else loop_end=sz[1]-1

for i=0,loop_end do begin
;looping over the separate CME detections
		
	cme_prof = intarr((detection_info[3,i]-detection_info[2,i]+1),200) ;scaled down from height 2e4

	for k_count=detection_info[0,i],detection_info[1,i] do begin
	;looping over the relevant angles in the detection

		k = k_count
		if keyword_set(loud) then print, 'k ', k		
		if k gt 359 then k-=360
		if k lt 0 then k+=360

		if keyword_set(loud) then begin
			plot_image, pa_total, xtit='Position Angle', ytit='Image No. (time)'
			plots, [detection_info[0,i],detection_info[0,i]], [detection_info[2,i],detection_info[3,i]], line=1
                	plots, [detection_info[1,i],detection_info[1,i]], [detection_info[2,i],detection_info[3,i]], line=1
                	plots, [detection_info[0,i],detection_info[1,i]], [detection_info[2,i],detection_info[2,i]], line=1
                	plots, [detection_info[0,i],detection_info[1,i]], [detection_info[3,i],detection_info[3,i]], line=1
			plots, [k,k],[detection_info[2,i],detection_info[3,i]]
		endif

		prof = pa_total[k,detection_info[2,i]:detection_info[3,i]]

		if keyword_set(plot_prof) then plot, prof, psym=2, yr=[0,20000], /ys, xtit='Image No. (time)', ytit='Height (arcsec)'

		plots_list_count = 0

		green_counter = 0

		for j=detection_info[2,i], detection_info[3,i] do begin
		;looping over the detections at this angle
			
			plots_list_j = plots_list[where(plots_list ge detection_info[2,i] and plots_list le detection_info[3,i])]

			offset = where(plots_list eq plots_list_j[0])
			
			if keyword_set(loud) then begin
				print, 'k ', k
				;print, 'plots_list ', plots_list
				print, 'j ', j
				print, 'detection_info[2,i], detection_info[3,i] ', detection_info[2,i], detection_info[3,i]
				;print, 'plots_list_j ', plots_list_j
				print, 'offset ', offset
				if keyword_set(plot_prof) then plots, j-detection_info[2,i], 0, psym=1, color=2 else plots, k, j, psym=1, color=2
			endif

			if j gt detection_info[3,i] then goto, jump

			if where(plots_list_j eq j) eq [-1] then begin
				if keyword_set(loud) then print, 'no cme?'
				goto, jump
			endif

			if keyword_set(loud) then begin	
				if keyword_set(plot_prof) then plots, j-detection_info[2,i], 0, psym=2, color=4 else plots, k, j, psym=2, color=4
			endif

			if green_counter eq 0 then green_counter+=offset

			if keyword_set(loud) then print, 'restore ', plots_fls[green_counter]
			restore, plots_fls[green_counter]

			green_counter += 1
		
			; Find associated height at this angle for this detection(timestep).
			; shift the angle due to how recpol is offset from solar north
			k_shift = (k+90) mod 360
			if keyword_set(loud) then print, 'k_shift ', k_shift

			recpol, res[0,*]-in.xcen, res[1,*]-in.ycen, res_r, res_theta, /deg
			recpol, xf_out-in.xcen, yf_out-in.ycen, r_out, a_out, /deg
	
			ind = where(round(res_theta) eq k_shift,cnt)
			ind2 = where(round(a_out) eq k_shift,cnt2)

			help, ind, ind2
	
			if cnt ne 0 then begin
				h = res_r[ind]*in.pix_size
				if keyword_set(loud) then begin
					if keyword_set(plot_prof) then plots, replicate(j-detection_info[2,i],n_elements(h)), h, psym=2, color=5
				endif
				cme_prof[j-detection_info[2,i],round(h/100.)] += 1
			endif
			if cnt2 ne 0 then begin
				hf = r_out[ind2]*in.pix_size
				if keyword_set(loud) then begin
					if keyword_set(plot_prof) then plots, j-detection_info[2,i], hf, psym=2, color=4
				endif
				cme_prof[j-detection_info[2,i],round(hf/100.)] += 1
			endif

			jump:
			;pause

		endfor

	endfor

	save, cme_prof, f='cme_prof_'+int2str(i)+'.sav'
	print, 'save, cme_prof'
	pause

endfor



end
