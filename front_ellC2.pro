; Code to take in an image from Matlab of the front for ellipse fit.

; Last Edited: 21-11-07

pro front_ellC2, image, in, da

	ans = ''

	temp = image
	sz = size(image, /dim)
	for i=0,sz[0]-1 do temp[*,abs(sz[0]-1-i)]=image[*,i]
	im = temp
	delvarx, temp, image
	
	front = where(im ne 0)
	ind = array_indices(im, front)
	x = ind[0,*]
	y = ind[1,*]

	index2map, in, da, map
	x_map = (x-in.crpix1)*in.cdelt1
	y_map = (y-in.crpix2)*in.cdelt2
	plot_map, map
	plots, x_map, y_map, psym=1

	;******
	; Take only a number of points across the front
	recpol, x_map, y_map, r, a, /degrees

	a_max1 = max(a)
	a_min1 = min(a)

	a = round(a)
	r = round(r)

	a_max = max(a)
	a_min = min(a)

	a_front = fltarr(a_max - a_min +1)
	r_front = fltarr(a_max - a_min +1)
	temp = 0.
	count = a_min
	stepsize = 1.
	while (count le a_max) do begin
		a_front[temp] = count
		if (where(a eq count) eq [-1]) then goto, jump1
		r_front[temp] = max(r[where(a eq count)])
		jump1:
		temp = temp + 1
		count = count + stepsize
	endwhile

	polrec, r_front, a_front, x_front, y_front, /degrees
	plot_map, map
	non_zero_front, x_front, y_front, xnf, ynf
	x_front=xnf
	y_front=ynf
	plots, x_front, y_front, psym=1;, color=2;yellow
	
	; drawing circle of solar limb
        r_sun = pb0r(map.time, /arcsec)
        draw_circle, 0, 0, r_sun[2]
	; messin with solar grid
	;plot_helio, in.date_d$obs, roll=in.crota, /over
	
	
	; Take only the points that I deem part of the front
	sz_xf = size(x_front, /dim)
	sz_yf = size(y_front, /dim)
	my_xfront = fltarr(sz_xf[0])
	my_yfront = fltarr(sz_yf[0])
	count = 0
	read, 'Specify front? y/n ', ans
	if ans eq 'n' then begin
		for i=0,sz_xf[0]-1 do begin
			my_xfront[count] = x_front[i]
			my_yfront[count] = y_front[i]
			count += 1
		endfor
	endif else begin	
	for i=0,sz_xf[0]-1 do begin
		plots, x_front[i], y_front[i], psym=2, color=3
		read, 'Front? y/n', ans
		if ans ne 'n' then begin
			my_xfront[count] = x_front[i]
			my_yfront[count] = y_front[i]
			count = count + 1
		endif
	endfor
	endelse
	my_xfront = my_xfront[0:count-1]
	my_yfront = my_yfront[0:count-1]
	plot_map, map
	draw_circle, 0, 0, r_sun[2]
	plots, my_xfront, my_yfront, psym=1;, color=6
	x_front = my_xfront
	y_front = my_yfront
	delvarx, count, my_xfront, my_yfront, sz_xf, sz_yf
	;******

	;********
	; Calling function to plot ellipse (written by Jason)
	; Coords need to be in original array format (not map)
	x_org = ( x_front / in.cdelt1 ) + in.crpix1
	y_org = ( y_front / in.cdelt2 ) + in.crpix2
	ellipse = ellipsefit(x_org, y_org)
	aprime = ellipse[0:(size(ellipse,/dim)-2)/2-1]
	bprime = ellipse[(size(ellipse,/dim)-2)/2:(size(ellipse,/dim)-2)-1]
	aprime = (aprime-in.crpix1) * in.cdelt1
	bprime = (bprime-in.crpix2) * in.cdelt2
	x_bar_org = ellipse[size(ellipse,/dim)-2]
	y_bar_org = ellipse[size(ellipse,/dim)-1]
	x_bar = (x_bar_org-in.crpix1) * in.cdelt1
	y_bar = (y_bar_org-in.crpix2) * in.cdelt2
	;plots, aprime, bprime, color=3;red
	;plots, x_bar, y_bar, psym=4;diamond
	recpol, x_bar, y_bar, r_bar, a_bar, /degrees
	;********

	;******
	; Find width of CME ellipsefit for use in start params of mpfitellipse.pro
	min_ap = min(aprime)
	max_ap = max(aprime)
	min_bp = bprime[where(aprime eq min_ap)]
	max_bp = bprime[where(aprime eq max_ap)]
	;plots, [min_ap,max_ap], [min_bp,max_bp], color=5;blue	
	width = sqrt( (max_bp-min_bp)^2. + (max_ap-min_ap)^2. )
	;******

	;********
	; Use mpfitfun for perform mpfitellipse using my guestimate.
	x0 = x_front - x_bar
	y0 = y_front - y_bar
	recpol, x0, y0, r0, a0, /degrees
	radiusbar = sqrt( x_bar^2. + y_bar^2. )
	fit = 'sqrt( (p[0]^2.*p[1]^2.) / ((p[0]^2.+p[1]^2.)/2. - ((p[0]^2.-p[1]^2.)/2.) * cos(2.*x - 2.*p[2]) ) )'
	parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
	parinfo[*].value = [10.*width, 10.*width, 1.]
	param = mpfitexpr( fit, a0, r0, r0*0.1, parinfo=parinfo, $
		perror=perror, yfit=yfit)
	x_fit = x_front
	y_fit = y_front
	;MPFITELLIPSE
	start_params = [param[0]*0.1, param[1]*0.1, x_bar, y_bar, param[2]*0.1]
	wts = 1
	p = mpfitellipse( x_fit, y_fit, start_params, /tilt, weights=wts, quiet=1 )
	phi = dindgen(101) * 2D * !dpi/100.
	x_ell = p[2] + p[0]*cos(phi)
	y_ell = p[3] + p[1]*sin(phi)
	;transform by swinging about map centre
	x_ell2 = x_ell*cos(p[4]) + y_ell*sin(p[4])
	y_ell2 = y_ell*cos(p[4]) - x_ell*sin(p[4])
	shift_x_bar = p[2]*cos(p[4]) + p[3]*sin(p[4])
	shift_y_bar = p[3]*cos(p[4]) - p[2]*sin(p[4])
	shift_x = shift_x_bar - p[2]
	shift_y = shift_y_bar - p[3]
	x_ellipse = x_ell2 - shift_x
	y_ellipse = y_ell2 - shift_y
	plots, x_ellipse, y_ellipse
	plots, p[2], p[3], psym=5;, color=6

	;plots, [0,p[2]], [0,p[3]]
	
end
