;Created	01-04-11	to distinguish between the sets of pa_heights restored from all_h.sav

pro distinguish_pa_heights, image_no, heights


; take the heights grouped per image_no
heights_per = fltarr(n_elements(image_no))
print, n_elements(image_no)

image_no_inds = image_no[uniq(image_no,sort(image_no))]
print, n_elements(image_no_inds)

for i=21,n_elements(image_no_inds)-1 do begin
	plot, image_no, heights, psym=1
	print, 'i ', i
	heights_per = heights[where(image_no eq image_no_inds[i])]
	heights_per = heights_per[sort(heights_per)]
	plots, image_no_inds[i], heights_per, psym=1, color=3
	tot_len = max(heights_per)-min(heights_per)
	print, 'tot_len ', tot_len & print, 'n_elements(heights_per) ', n_elements(heights_per)
	for j=0,n_elements(heights_per)-2 do begin
		gap = heights_per[j+1]-heights_per[j]
		if j ne 0 then begin
			if gap gt biggest_gap then begin
				biggest_gap = gap		
				plots, image_no_inds[i], heights_per[j+1], psym=1, color=4
				plots, image_no_inds[i], heights_per[j], psym=1, color=4
			endif
		endif else begin
			biggest_gap = gap
			plots, image_no_inds[i], heights_per[j+1], psym=1, color=4
                        plots, image_no_inds[i], heights_per[j], psym=1, color=4
		endelse
;		pause
	endfor
	print, 'tot_len ', tot_len & print, 'biggest_gap ', biggest_gap
;	pause
stop
endfor


end
