; Procedure just to plot ellipse to a front not dependant on map space / reference frame

;Last Edited: 07-08-08

pro standard_ellipse_plot, x, y, ell

ellipse = ellipsefit(x,y)
aprime = ellipse[0:(size(ellipse,/dim)-2)/2-1]
bprime = ellipse[(size(ellipse,/dim)-2)/2:(size(ellipse,/dim)-2)-1]
x_bar = ellipse[size(ellipse,/dim)-2]
y_bar = ellipse[size(ellipse,/dim)-1]

;plot, x, y, psym=3
;plots, aprime, bprime
;plots, x_bar, y_bar, psym=1

;transform x, y to polar coords
recpol, x, y, r, a, /degrees
recpol, x_bar, y_bar, r_bar, a_bar, /degrees

;Find width of CME ellipsefit for use in start params of mpfitellipse.pro
min_ap = min(aprime)
max_ap = max(aprime)
min_bp = bprime[where(aprime eq min_ap)]
max_bp = bprime[where(aprime eq max_ap)]
width = sqrt( (max_bp - min_bp)^2. + (max_ap - min_ap)^2. )

; Use mpfitfun to perform mpfitellipse using my guestimate
x0 = x - x_bar[0]
y0 = y - y_bar[0]
recpol, x0, y0, r0, a0, /degrees
radiusbar = sqrt( x_bar^2. + y_bar^2. )
fit = 'sqrt( (p[0]^2.*p[1]^2.) / ((p[0]^2.+p[1]^2.)/2. - ((p[0]^2.-p[1]^2.)/2.) * cos(2.*x - 2.*p[2]) ) )'
parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
parinfo[*].value = [10.*width, 10.*width, 1.]
param = mpfitexpr( fit, a0, r0, r0*0.1, parinfo=parinfo, $
	        perror=perror, yfit=yfit, quiet=1)
x_fit = x
y_fit = y
;MFITELLIPSE
start_params = [param[0]*0.1, param[1]*0.1, x_bar, y_bar, param[2]*0.1]
wts = 1
p = mpfitellipse( x_fit, y_fit, start_params, /tilt, weights=wts, quiet=1, perror=perror )
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

ell = fltarr(2, n_elements(x_ellipse))
ell[0,*] = x_ellipse
ell[1,*] = y_ellipse

end
