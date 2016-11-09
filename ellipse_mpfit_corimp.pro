; Trying to rewrite and make it better!

; Last Edited: 	11-10-07
; Last edited: 	01-02-11  to include cases of corimp where header info has changed.
; 		10-02-11 to include clause for too few front points to warrant fitting ellipse.
;		20120316	to include keyword rm_inner_front to remove the inner part of the front so it's never included.

pro ellipse_mpfit_corimp, x, y, in, da, xf, yf, x_ellipse, y_ellipse, error, p, show=show, full_front=full_front, rm_inner_front=rm_inner_front


error=0

;print, 'THERE IS AN ISSUE WITH CALLING ELLIPSE_MPFIT_CORIMP.PRO DUE TO INDEX2MAP FUNCTION LACKING PROPER HEADER INFO'
xcen=in.xcen
ycen=in.ycen
in.xcen=0
in.ycen=0
; reset back at end of code!

index2map, in, da, map
x_map = (x-xcen)*in.cdelt1
y_map = (y-ycen)*in.cdelt2
recpol, x_map, y_map, r, a, /degrees
a_max1 = max(a)
a_min1 = min(a)

if keyword_set(rm_inner_front) then begin
	r_max1 = r[where(a eq a_max1)]
	r_min1 = r[where(a eq a_min1)]
	if n_elements(r_max1) gt 1 then r_max1=max(r_max1)
	if n_elements(r_min1) gt 1 then r_min1=max(r_min1)
	r_thresh = min([r_min1,r_max1])
	if r_thresh lt ave(r) then begin
		r_front = r[where(r gt r_thresh)]
		a_front = a[where(r gt r_thresh)]
		r = r_front
		a = a_front
	endif
endif

a = round(a)
r = round(r)
a_max = max(a)
a_min = min(a)
a_front = fltarr(a_max - a_min +1)
r_front = a_front

temp = 0.
count = a_min
stepsize = 1.
while (count le a_max) do begin
	a_front[temp] = count
	if (where(a eq count) eq [-1]) then goto, jump1
	r_front[temp] = max(r[where(a eq count)])
	jump1:
	temp += 1
	count += stepsize
endwhile
polrec, r_front, a_front, x_front, y_front, /degrees
if keyword_set(full_front) then polrec, r, a, x_front, y_front, /degrees
if keyword_set(show) then plot_map, map
non_zero_front, x_front, y_front, xf, yf
if keyword_set(show) then plots, xf, yf, psym=1, color=2

; Case that too few points are available for ellipse fitting:
if n_elements(xf) lt 3 then begin
	print, 'Too few points on front, ellipse fitting will not work.'
	error = 1
	goto, jump2
endif

; Calling ellipsefit.pro that I wrote as initial guess.
x_org = (xf / in.cdelt1) + xcen
y_org = (yf / in.cdelt2) + ycen
ellipse = ellipsefit(x_org, y_org)
aprime = ellipse[0:(size(ellipse,/dim)-2)/2-1]
bprime = ellipse[(size(ellipse,/dim)-2)/2:(size(ellipse,/dim)-2)-1]
aprime = (aprime - xcen) * in.cdelt1
brpime = (bprime - ycen) * in.cdelt2
x_bar_org = ellipse[size(ellipse,/dim)-2]
y_bar_org = ellipse[size(ellipse,/dim)-1]
x_bar = (x_bar_org - xcen) * in.cdelt1
y_bar = (y_bar_org - ycen) * in.cdelt2
recpol, x_bar, y_bar, r_bar, a_bar, /degrees

min_ap = min(aprime)
max_ap = max(aprime)
min_bp = min(bprime)
max_bp = max(bprime)
width = sqrt( (max_bp - min_bp)^2. + (max_ap - min_ap)^2. )

;MPFITFUN
x0 = xf - x_bar
y0 = yf - y_bar
recpol, x0, y0, r0, a0, /degrees
radiusbar = sqrt( x_bar^2. + y_bar^2. )
fit = 'sqrt( (p[0]^2.*p[1]^2.) / ((p[0]^2.+p[1]^2.)/2. - ((p[0]^2.-p[1]^2.)/2.) * cos(2.*x - 2.*p[2]) ) )'
parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 3)
parinfo[*].value = [10.*width, 10.*width, 1.]
param = mpfitexpr( fit, a0, r0, r0*0.1, parinfo=parinfo, $
	perror=perror, yfit=yfit )
; Case that ellipse fails and param is undefined or NaN
if n_elements(param) eq 1 && finite(param) eq 0 then begin
	print, 'Ellipse fitting fails.'
	error = 1
	goto, jump2
endif
x_fit = xf
y_fit = yf
;mpfitellipse
start_params = [ param[0]*0.01, param[1]*0.01, x_bar, y_bar, param[2]*0.01 ]
wts = 1
p = mpfitellipse( x_fit, y_fit, start_params, /tilt, weight=wts, quiet=1 )
phi = dindgen(1001) * 2D * !dpi/1000.
x_ell = p[2] + p[0]*cos(phi)
y_ell = p[3] + p[1]*sin(phi)
;transform by swinging around map centre
x_ell2 = x_ell*cos(p[4]) + y_ell*sin(p[4])
y_ell2 = y_ell*cos(p[4]) - x_ell*sin(p[4])
shift_x_bar = p[2]*cos(p[4]) + p[3]*sin(p[4])
shift_y_bar = p[3]*cos(p[4]) - p[2]*sin(p[4])
shift_x = shift_x_bar - p[2]
shift_y = shift_y_bar - p[3]
x_ellipse = x_ell2 - shift_x
y_ellipse = y_ell2 - shift_y
if keyword_set(show) then plots, xf, yf, psym=2
if keyword_set(show) then plots, x_ellipse, y_ellipse

jump2:

; Resetting the header back to how it was read in.
in.xcen=xcen
in.ycen=ycen

end
