; Procedure just to plot ellipse to a front dependant on map space / reference frame

; based on standard_ellipse_plot.pro

; the x and y read in have to be in map space

;Last Edited: 07-08-08

pro map_ellipse_plot, x_map, y_map, x_ellipse, y_ellipse

; transform to original coords
;x_org = ( x_map / in.cdelt1 ) + in.crpix1
;y_org = ( y_map / in.cdelt2 ) + in.crpix2

x_org = x_map 
y_org = y_map 

ellipse = ellipsefit(x_org, y_org)
aprime = ellipse[0:(size(ellipse,/dim)-2)/2-1]
bprime = ellipse[(size(ellipse,/dim)-2)/2:(size(ellipse,/dim)-2)-1]
x_bar_org = ellipse[size(ellipse,/dim)-2]
y_bar_org = ellipse[size(ellipse,/dim)-1]
;x_bar = ( x_bar_org - in.crpix1 ) * in.cdelt1
;y_bar = ( y_bar_org - in.crpix2 ) * in.cdelt2
x_bar =  x_bar_org
y_bar =  y_bar_org

;plot, x, y, psym=3
;plots, aprime, bprime
;plots, x_bar, y_bar, psym=1

;transform x, y to polar coords
recpol, x_bar, y_bar, r_bar, a_bar, /degrees

;Find width of CME ellipsefit for use in start params of mpfitellipse.pro
min_ap = min(aprime)
max_ap = max(aprime)
min_bp = bprime[where(aprime eq min_ap)]
max_bp = bprime[where(aprime eq max_ap)]
;width = sqrt( (max_bp - min_bp)^2. + (max_ap - min_ap)^2. )
width = max(y_map) - min(y_map)

; Use mpfitfun to perform mpfitellipse using my guestimate
x0 = x_map - x_bar[0]
y0 = y_map - y_bar[0]
recpol, x0, y0, r0, a0, /degrees
radiusbar = sqrt( x_bar^2. + y_bar^2. )
fit = 'sqrt( (p[0]^2.*p[1]^2.) / ((p[0]^2.+p[1]^2.)/2. - ((p[0]^2.-p[1]^2.)/2.) * cos(2.*x - 2.*p[2]) ) )'
parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
parinfo[*].value = [10.*width, 10.*width, 1.]
param = mpfitexpr( fit, a0, r0, r0*0.1, parinfo=parinfo, $
	perror=perror, yfit=yfit)
x_fit = x_map
y_fit = y_map
;MFITELLIPSE
start_params = [param[0]*0.1, param[1]*0.1, x_bar, y_bar, param[2]*0.1]
wts = 1
parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 5)
parinfo[*].value = [param[0], param[1], x_bar, y_bar, param[2]]
parinfo[0].limited[1] = 0
parinfo[0].limits[1] = width*0.6
parinfo[1].limited[1] = 0
parinfo[1].limits[1] = width*0.6
p = mpfitellipse( x_fit, y_fit, start_params, /tilt, weights=wts, quiet=1, parinfo=parinfo, perror=perror )
phi = dindgen(101) * 2D * !dpi/100.
x_ell = p[2] + p[0]*cos(phi)
y_ell = p[3] + p[1]*sin(phi)
x_ell2 = x_ell*cos(p[4]) + y_ell*sin(p[4])
y_ell2 = y_ell*cos(p[4]) - x_ell*sin(p[4])
shift_x_bar = p[2]*cos(p[4]) + p[3]*sin(p[4])
shift_y_bar = p[3]*cos(p[4]) - p[2]*sin(p[4])
shift_x = shift_x_bar - p[2]
shift_y = shift_y_bar - p[3]
x_ellipse = x_ell2 - shift_x
y_ellipse = y_ell2 - shift_y





end

;MPFITELLIPSE
;start_params = [param[0]*0.1, param[1]*0.1, x_bar, y_bar, param[2]*0.1]
;print, 'errs: ', errs
;wts = 0.75/(errs^2+errs^2)
;print, 'weights: ', wts
;parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 5)

;parinfo[*].value = [param[0], param[1], x_bar, y_bar, param[2]]
;parinfo[0].limited[1] = 1
;parinfo[0].limits[1] = width.
;parinfo[1].limited[1] = 1
;parinfo[1].limits[1] = width.
;p = mpfitellipse( x_fit, y_fit, start_params, /tilt, weights=wts, quiet=1, parinfo=parinfo, perror=perror )
