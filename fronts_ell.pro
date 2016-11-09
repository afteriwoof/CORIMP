; Code to take in the images from Matlab of the fronts for ellipse fit.

; Last Edited: 28-06-07

; UNFINISHED!

pro fronts_ell, fls

	sz_fls = size(fls, /dim)
	temp = read_png(fls[0])
	sz_temp = size(temp, /dim)
	read_arr = fltarr(sz_temp[0], sz_temp[1], sz_fls[0])
	
	for i=0,sz_fls[0]-1 do read_arr[*,*,i] = read_png(fls[i])

	xstepper, read_arr, xs=600






end
