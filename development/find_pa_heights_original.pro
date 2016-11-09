; Created	23-03-11	to find the height increases corresponding to CMEs propagating along the position angle slices (pa_total)

; Last edited	24-03-11
;		25-03-11

pro find_pa_heights, pa_total

!p.multi=[0,1,2]

all_h = fltarr(1)

occulter_crossing = 5743.

for k=0,359 do begin

	plot_image, pa_total
	verline, k
	prof = pa_total[k,*]
	plot, prof, psym=1, yr=[0,20000],/ys;, line=1
	horline, occulter_crossing

	inds = where(prof ne 0)
	if n_elements(inds) lt 2 then goto, jump1
	count_up = 0
	jump2:
	; if the points are rising take the initial height point
	if prof[inds[1]] gt prof[inds[0]] then begin
		h = prof[inds[0]]
	; otherwise move along and see if the next points start rising.
	endif else begin
		inds = inds[1:*]
		count_up += 1
		if n_elements(inds) eq 1 then goto, jump1
		goto, jump2
	endelse

	plots, inds[0], h[0], psym=6, color=3
	skip = 0
	previous_count_input_h = 0
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
			h=[h,prof[inds[count+skip]]]
			count_input_h = count+skip
			previous_gap = count_input_h - previous_count_input_h
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
						h=[h,prof[inds[count+1+skip]]]
						count_input_h = count+1+skip
						previous_gap = count_input_h - previous_count_input_h
;						plots, inds[count+skip+1], h[n_elements(h)-1], psym=5, color=4
					endif
;					print, 'h ', h
;					print, 'n_elements(h) ', n_elements(h)
					skip += 1
;					print, 'skip ', skip
				endif
			endif
		endelse
		current_gap = count - count_input_h
;		print, 'current_gap ', current_gap
;		print, 'previous_gap ', previous_gap
		previous_count_input_h = count_input_h
		count += 1
		if current_gap gt 2*previous_gap then goto, jump3
;		pause
	endwhile

	jump3:
	indices = intarr(n_elements(h))
	for i=0,n_elements(h)-1 do begin
		indices[i] = inds[where(pa_total[k,inds] eq h[i])]
		all_h = [all_h,indices[i],h[i],k]
	endfor
;	print, 'indices ', indices & print, 'h ', h & print, 'k ', k
	plots, indices, h, psym=-6, color=3, line=1
	jump1:
	pause
endfor

all_h = all_h[1:*] ;removing the first zero from initialising the array above
counter = intarr(n_elements(all_h)/3)
for i=1,n_elements(counter)-1 do counter[i] = counter[i-1]+3

image_no = all_h[counter]
heights = all_h[counter+1]
pos_angles = all_h[counter+2]
save, all_h,image_no,heights,pos_angles, f='all_h.sav'

end
