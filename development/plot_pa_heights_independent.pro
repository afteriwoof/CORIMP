; Created:	29-03-11	from plot_pa_heights.pro but used for only independet position angles.

pro plot_pa_heights_independent, pngs, in, image_no, heights, pos_angles, temp

window,xs=1024,ys=1024

temp = fltarr(1024,1024,n_elements(image_no))

for k=0,n_elements(image_no)-1 do begin
;	print, 'k ', k
;	print, 'image_no[k] ', image_no[k]
	im = read_png(pngs[image_no[k]])
	;if k ne 0 then if pos_angles[k] ne pos_angles[k-1] then print, 'New pos_angle'
	polrec, heights[k]/in[image_no[k]].pix_size, pos_angles[k], x, y, /degrees
	x += in[image_no[k]].xcen
	y += in[image_no[k]].ycen
	tvscl, im[0,*,*]
	plots, x, y, psym=2, color=3, /device
	plots,[in[image_no[k]].xcen,x],[in[image_no[k]].ycen,y],psym=-3, /device
	xyouts, 470, 965, 'PA '+int2str(round(pos_angles[k])), charsize=2, /device
;	pause
	temp1 = tvrd()	
	;temp[*,*,k] = rebin(temp1,342,342)
	temp[*,*,k]=temp1
endfor

;xmovie,temp



end
