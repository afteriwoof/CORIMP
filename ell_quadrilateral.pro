; Procedure just to plot ellipse to a front not dependant on map space / reference frame

; Creadted: 17-09-08
;Last Edited: 17-09-08
;Last Edited: 22-04-09 to include adjustment for a tilt angle > 90degrees.

; x, y, are the four vertices coords

pro ell_quadrilateral, x, y, semimajor, semiminor, xc, yc, ell, flip=flip

;ellipse = ellipsefit(x,y)
;aprime = ellipse[0:(size(ellipse,/dim)-2)/2-1]
;bprime = ellipse[(size(ellipse,/dim)-2)/2:(size(ellipse,/dim)-2)-1]
;x_bar = ellipse[size(ellipse,/dim)-2]
;y_bar = ellipse[size(ellipse,/dim)-1]

;plot, x, y, psym=3
;plots, aprime, bprime
;plots, x_bar, y_bar, psym=1

;transform x, y to polar coords
;recpol, x, y, r, a, /degrees
;recpol, x_bar, y_bar, r_bar, a_bar, /degrees

;Find width of CME ellipsefit for use in start params of mpfitellipse.pro
;min_ap = min(aprime)
;max_ap = max(aprime)
;min_bp = bprime[where(aprime eq min_ap)]
;max_bp = bprime[where(aprime eq max_ap)]
;width = sqrt( (max_bp - min_bp)^2. + (max_ap - min_ap)^2. )

; Use mpfitfun to perform mpfitellipse using my guestimate
x0 = x - xc
y0 = y - yc
recpol, x0, y0, r0, a0, /degrees
;radiusbar = sqrt( x_bar^2.d0 + y_bar^2.d0 )
fit = 'sqrt( (p[0]^2.d0*p[1]^2.d0) / ((p[0]^2.d0+p[1]^2.d0)/2.d0 - ((p[0]^2.d0-p[1]^2.d0)/2.d0) * cos(2.d0*x - 2.d0*p[2]) ) )'
; want to fix the axes lengths and the ellipse centre coords
; want to keep the tilt not fixed
parinfo = replicate({value:0.D, fixed:1, limited:[1,1], limits:[0.D,0]}, 2)
parinfo = [parinfo,{value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}]
parinfo[*].value = [semimajor, semiminor, 1.]
parinfo[0].limits = [semimajor, semimajor]
parinfo[1].limits = [semiminor, semiminor]
param = mpfitexpr( fit, a0, r0, r0*0.1d0, parinfo=parinfo, $
	        perror=perror, yfit=yfit, quiet=1)
print, param
x_fit = x
y_fit = y
;MFITELLIPSE
start_params = [param[0], param[1], xc, yc, param[2]]
parinfo = replicate({value:0.D, fixed:1, limited:[1,1], limits:[0.D,0]}, 4)
parinfo = [parinfo, {value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}]
parinfo[*].value = [semimajor, semiminor, xc, yc, param[2]]
parinfo[0].limits = [semimajor, semimajor]
parinfo[1].limits = [semiminor, semiminor]
parinfo[2].limits = [xc, xc]
parinfo[3].limits = [yc, yc]
wts = 1
p = mpfitellipse( x_fit, y_fit, start_params, /tilt, weights=wts, quiet=1, parinfo=parinfo, perror=perror )
help, p
print,p
phi = dindgen(101) * 2D * !dpi/100.d0
x_ell = p[2] + p[0]*cos(phi)
y_ell = p[3] + p[1]*sin(phi)
if keyword_set(flip) then begin
	print, '***************'
	print, 'Adjusting it by 90'
	print, 'tilt: ', p[4]*180.d0/!dpi
	p[4] -= 1.57079
	print, 'adjusted tilt: ', p[4]*180.d0/!dpi
endif
x_ell2 = x_ell*cos(p[4]) + y_ell*sin(p[4])
y_ell2 = y_ell*cos(p[4]) - x_ell*sin(p[4])
shift_x_bar = p[2]*cos(p[4]) + p[3]*sin(p[4])
shift_y_bar = p[3]*cos(p[4]) - p[2]*sin(p[4])
shift_x = shift_x_bar - p[2]
shift_y = shift_y_bar - p[3]
x_ellipse = x_ell2 - shift_x
y_ellipse = y_ell2 - shift_y

ell = dblarr(2, n_elements(x_ellipse))
ell[0,*] = x_ellipse
ell[1,*] = y_ellipse

end
