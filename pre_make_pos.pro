; My code to calculate arrays for the input of Huw's make_pos

; Last Edited: 02-10-07

PRO pre_make_pos, in, im, x, y

sz=size(im,/dim)
x = fltarr(sz[0])
y = x

	for j=0,sz[0]-1 do begin
		x[j] = j - in.crpix1
		y[j] = j - in.crpix2
	endfor

; Arcseconds
	x = x*in.cdelt1
	y = y*in.cdelt2
	
; Solar coords
	index2map, in, im, map
	r_sun = pb0r(map.time, /soho, /arcsec)
	;r_sun is the r_sun[2] entry
	x = x/r_sun[2]
	y = y/r_sun[2]

end
