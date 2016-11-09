; Created:	24-03-11	to plot the measured heights along position angles from the output pa_total and find_pa_heights.pro

pro plot_pa_heights, pngs, in, image_no, heights, pos_angles

;temp = fltarr(512,512,n_elements(image_no))

individs = image_no[0]
for i=0,n_elements(image_no)-1 do begin
	if where(individs eq image_no[i]) eq [-1] then individs = [individs,image_no[i]]
endfor

;sort in time
;individs = individs[sort(individs)]

for i=0,n_elements(individs)-1 do begin
;	print, 'k ', k
;	print, 'image_no[k] ', image_no[k]
	im = read_png(pngs[individs[i]])
	inds = where(image_no eq individs[i])
	;if k ne 0 then if pos_angles[k] ne pos_angles[k-1] then print, 'New pos_angle'
	polrec, heights[inds]/in[individs[i]].pix_size, pos_angles[inds], x, y, /degrees
	x += in[individs[i]].xcen
	y += in[individs[i]].ycen
	tvscl, im[0,*,*]
	plots, x, y, psym=2, color=3, /device
;	plots,[in[individs[i]].xcen,x],[in[individs[i]].ycen,y],psym=-3, /device
	xyouts, 470, 965, 'PA '+int2str(round(pos_angles[inds])), charsize=2, /device
	pause
;	temp1 = tvrd()	
;	temp[*,*,k] = rebin(temp1,512,512)
endfor

;xmovie,temp



end
