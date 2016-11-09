; Created	07-10-11	to find the height increases corresponding to CMEs propagating along the position angle slices (pa_total)

; Last edited	24-03-11
;		25-03-11
;		28-03-11	to take in detection_info output from separate_pa_total.pro
;		07-06-11	to consider case that loop_end is 0.

pro find_pa_heights_all, pa_total, detection_info, fls, fls_plots

!p.multi=[0,1,2]

set_line_color

sz = size(detection_info,/dim)

if size(sz,/dim) eq 1 then loop_end = 0 else loop_end = sz[1]-1

for i=0,loop_end do begin

	all_h = fltarr(1)

	occulter_crossing = 5743.

	for k_count=(detection_info[0,i]),detection_info[1,i] do begin

		k = k_count
		if k gt 359 then k-=360
		if k lt 0 then k+=360
		plot_image, pa_total, xtit='Position Angle', ytit='Image No. (time)'

		plots, [detection_info[0,i],detection_info[0,i]], [detection_info[2,i],detection_info[3,i]], line=1
		plots, [detection_info[1,i],detection_info[1,i]], [detection_info[2,i],detection_info[3,i]], line=1
		plots, [detection_info[0,i],detection_info[1,i]], [detection_info[2,i],detection_info[2,i]], line=1
		plots, [detection_info[0,i],detection_info[1,i]], [detection_info[3,i],detection_info[3,i]], line=1

		print, 'k ', k
		plots, [k,k],[detection_info[2,i],detection_info[3,i]]
		;print, 'detection_info[*,i] ', detection_info[*,i]

		prof = pa_total[k,detection_info[2,i]:detection_info[3,i]]
		plot, prof, psym=2, yr=[0,20000],/ys, xtit='Image No. (time)', ytit='Height (arcsec)';, line=1
		for j=detection_info[2,i],detection_info[3,i] do begin
;*** the fls are only the times a detection was made, so they can be out of sync with actual steps j here!!!!                
        		print, fls[j]
			print, 'j ', j
			print, 'detection_info[2,i] ', detection_info[2,i]
			fls_plots_j = fls_plots[where(fls_plots ge detection_info[2,i] and fls_plots le detection_info[3,i])]
			print, 'fls_plots_j ', fls_plots_j
			print, 'j-detection_info[2,i] ', j-detection_info[2,i]
			plots, j-detection_info[2,i], 0, psym=1, color=2
			; if the j in question isn't part of the detections then skip
			if where(fls_plots_j eq (j-detection_info[2,i])) eq [-1] then goto, jump4
        		print, 'No Jump!'
			print, fls[j]
			print, 'j ', j
			restore,fls[j],/ver
                        recpol, xf_out-in.xcen, yf_out-in.ycen, r_out, a_out, /deg
			recpol,res[0,*]-in.xcen,res[1,*]-in.ycen,res_r,res_theta,/deg
                        help, res_r, res_theta, r_out, a_out
			pmm, res_theta, a_out
			res_theta = (res_theta+270) mod 360
			a_out = (a_out+270) mod 360
                        pmm, res_theta, a_out
			ind = where(floor(res_theta) eq k,cnt)
			ind2 = where(floor(a_out) eq k,cnt2)
			help, ind, ind2
			if cnt2 eq 0 then goto, jump4
			r_out = r_out[ind2]
			r_out *= in.pix_size
                        oplot, replicate(j,n_elements(r_out))-detection_info[2,i], r_out, psym=5, color=6
			if cnt eq 0 then goto,jump4
			res_r = res_r[ind]
			res_r *= in.pix_size
                        oplot, replicate(j,n_elements(res_r))-detection_info[2,i], res_r, psym=1, color=4
			if n_elements(j_r) eq 0 then j_r=j else j_r=[j_r,j]
			help, j
			jump4:
			pause
                endfor
		;pause
		horline, occulter_crossing
		xyouts,n_elements(prof)-n_elements(prof)*0.2,occulter_crossing+150,'C2/C3 occulter crossing'
	
		inds = where(prof ne 0)
		; remember to bring the inds back up to actual location in pa_total
		;print, 'inds ', inds
		if n_elements(inds) lt 2 then goto, jump1
		count_up = 0
		jump2:
		; if the points are rising take the initial height point
		if prof[inds[1]] gt prof[inds[0]] then begin
			h = prof[inds[0]]
			start_ind = inds[0] ;start_ind is the ind of the starting point in the heights
			;print, 'start_ind ', start_ind
		; otherwise move along and see if the next points start rising.
		endif else begin
			inds = inds[1:*]
			count_up += 1
			if n_elements(inds) eq 1 then goto, jump1
			goto, jump2
		endelse
	
;		plots, inds[0], h[0], psym=6, color=3
		skip = 0
;		previous_ind = start_ind+detection_info[2,i];have to add detection_info[2,i] to bring it up to same inds as pa_total, not just region!
;		previous_ind_gap = 0
;		previous_h = h
;		previous_h_slope = 0
;		previous_count_input_h = 0
		count = 1
	;	print, 'n_elements(inds) ', n_elements(inds)
	;	print, 'h init ', h
		while count+skip lt n_elements(inds) do begin
	;		print, 'count ', count
	;		print, 'prof[inds[count+skip]] ', prof[inds[count+skip]]
	;		print, 'prof[inds[count-1+skip]] ', prof[inds[count-1+skip]]
			; note if the heights are in C3 fov then don't include drops below the occulter to C2 in height counting:
			if prof[inds[count+skip]] gt h[n_elements(h)-1] then begin
	;			print, 'prof[inds[count+skip]] gt prof[inds[count-1+skip]]'
;				print, 'previous_h ', previous_h
				h=[h,prof[inds[count+skip]]]
;				current_h = prof[inds[count+skip]]
;				print, 'current_h ', current_h
;				print, 'previous_ind ', previous_ind
;				current_ind = inds[count+skip]+detection_info[2,i] ;current_ind is the ind of the current point in the heights
;				print, 'current_ind ', current_ind
;				current_ind_gap = current_ind - previous_ind
;				print, 'current_ind_gap ', current_ind_gap
;				count_input_h = count+skip
;				previous_gap = count_input_h - previous_count_input_h
	;			plots, inds[count+skip], h[n_elements(h)-1], psym=6, color=4
	;			print, 'h ', h
	;			print, 'n_elements(h) ', n_elements(h)
	;			print, 'skip ', skip
			endif else begin
				if (count+skip+1) lt n_elements(inds) then begin
	;				print, 'Next point NOT greater!'
	;				print, 'prof[inds[count-1]] ', prof[inds[count-1]]
	;				print, 'occulter crossing ', occulter_crossing
	;				print, 'prof[inds[count]] ', prof[inds[count]]
					if h[n_elements(h)-1] gt occulter_crossing && prof[inds[count+skip]] lt occulter_crossing then begin
	;					print, 'prof[inds[count+skip+1]] ', prof[inds[count+skip+1]]
						if prof[inds[count+1+skip]] gt h[n_elements(h)-1] then begin
;							print, 'previous_h ', previous_h
							h=[h,prof[inds[count+1+skip]]]
;							current_h = prof[inds[count+1+skip]]
;			                                print, 'current_h ', current_h
;							current_ind = inds[count+1+skip]+detection_info[2,i] ;current_ind is the ind of the current point in the heights
;							print, 'current_ind ', current_ind
;							current_ind_gap = current_ind - previous_ind
;							print, 'current_ind_gap ', current_ind_gap
;							count_input_h = count+1+skip
;							previous_gap = count_input_h - previous_count_input_h
	;						plots, inds[count+skip+1], h[n_elements(h)-1], psym=5, color=4
						endif
	;					print, 'h ', h
	;					print, 'n_elements(h) ', n_elements(h)
						skip += 1
	;					print, 'skip ', skip
					endif
				endif
			endelse
;			print, 'previous_ind_gap ', previous_ind_gap
;			print, 'current_ind, previous_ind, current_h, previous_h', current_ind, previous_ind, current_h, previous_h
;			plots, current_ind-detection_info[2,i], current_h, psym=-6, color=4, line=1
;			current_h_slope = (current_h - previous_h) / (current_ind - previous_ind)
;			print, 'current_h_slope ', current_h_slope
;			print, 'previous_h_slope ', previous_h_slope
;			if current_h_slope gt previous_h_slope then slope_diff = ((current_h_slope/previous_h_slope) mod 1)*100 else $
;				slope_diff = ((previous_h_slope/current_h_slope) mod 1)*100
;			print, '% difference in slopes ', slope_diff
;			remove_end_ind = 0
;			if current_ind_gap gt 3*previous_ind_gap && previous_ind_gap ne 0 then begin
;				print, 'current_ind_gap gt 3*previous_ind_gap'
;				remove_end_ind = 1
;				goto, jump3
;			endif
;			previous_ind_gap = current_ind_gap
;			previous_ind = current_ind
;;			previous_h = current_h
;			previous_h_slope = current_h_slope
;			current_gap = count - count_input_h
	;		print, 'current_gap ', current_gap
	;		print, 'previous_gap ', previous_gap
;			previous_count_input_h = count_input_h
			count += 1
;			if current_gap gt 2*previous_gap then goto, jump3
;			pause
		endwhile
	
		jump3:
;		case remove_end_ind of
;		0:	begin
			indices = intarr(n_elements(h))
			for j=0,n_elements(h)-1 do begin
				indices[j] = (inds[where(pa_total[k,inds+detection_info[2,i]] eq h[j])])[0] + detection_info[2,i]
				all_h = [all_h,indices[j],h[j],k]
			endfor
;			end
;		1:	begin
;			indices = intarr(n_elements(h)-1)
;			for j=0,n_elements(h)-2 do begin
;				indices[j] = inds[where(pa_total[k,inds+detection_info[2,i]] eq h[j])]+detection_info[2,i]
;				all_h = [all_h,indices[j],h[j],k]
;			endfor
;			end
;		endcase
		plots, indices-detection_info[2,i], h, psym=-6, color=3, line=1
		jump1:

		wait, 0.05
;		pause
	endfor

	if n_elements(all_h) gt 1 then begin
		all_h = all_h[1:*] ;removing the first zero from initialising the array above
		counter = intarr(n_elements(all_h)/3)
		for c=1,n_elements(counter)-1 do counter[c] = counter[c-1]+3
		
		image_no = all_h[counter]
		heights = all_h[counter+1]
		pos_angles = all_h[counter+2]
		print, 'Saving all_h'+int2str(i)+'.sav'
	;	save, all_h,image_no,heights,pos_angles, f='all_h'+int2str(i)+'.sav'
	endif

endfor


end
