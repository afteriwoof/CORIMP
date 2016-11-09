; code to take in the ellipse axes lengths and tilt and compute the curvature equation to spit out curvature at given points along the ellipse

; Created: 11-09-09  to apply to event 20081212.

; Last Edited: 14-09-09 to include the middle curvature measure.

pro ellipse_curvature_front, smj_init, smn_init, tilt, xf, zf, x, y, avex, avey, mid_curvature

;if smj_init lt smn_init then begin
;	temp = smn_init
;	smn_init = smj_init
;	smj_init = temp
;endif
smj_init = float(smj_init)
smn_init = float(smn_init)
smn = smn_init/smj_init
smj = smj_init/smj_init ;arcsec
print, 'semimajor: ', smj & print, 'semiminor: ', smn

tilt *= !dpi/180.  ;radians
print, 'tilt (rad): ', tilt & print, 'tilt(deg): ', tilt*180/!dpi

; from kins_meanspread.pro
top_point = [(xf[where(zf eq max(zf))])[0], (max(zf))[0]]
recpol, top_point[0], top_point[1], top_r, top_a, /degrees
bottom_point = [(xf[where(zf eq min(zf))])[0], (min(zf))[0]]
recpol, bottom_point[0], bottom_point[1], bottom_r, bottom_a, /degrees
if bottom_a gt 180 then bottom_a -= 360.0d
mid_a = (top_a + bottom_a)/2.0d
recpol, xf, zf, r, a, /degrees
; sort it in order of angle
polrec, r[sort(a)], a[sort(a)], xf_sort, zf_sort, /degrees
recpol, xf_sort, zf_sort, r, a, /degrees
linterp, a, r, mid_a, mid_r
print, mid_a, mid_r
pause

recpol, xf, zf, r, a, /degrees
upper = max(a) 
lower = min(a) 
if upper eq 360 then begin	; case for when it crosses the ecliptic
	a -= 90
	upper = max(a[where(a lt 0)]) + 90
	lower = min(a[where(a gt 0)]) + 90 - 360
endif
steps = abs(upper - lower)
print, upper, lower, steps
omega_prime = indgen(steps+2)
omega_prime += lower
print, 'omega_prime (deg): ', omega_prime


; going to step through 1 degree angles along the front portion of the ellipse to measure curvature.
x = dblarr(steps+2)
y = dblarr(steps+2)

;plot, indgen(2), xr=[-1.5,1.5], yr=[-4,4], /nodata

flag = where(omega_prime eq round(mid_a)) ;flagging the middle point in the steps through angle.

print, 'semimajor: ', smj
print, 'semiminor: ', smn
print, 'tilt: ', tilt
pause
for k=0,steps+1 do begin
	omega = (omega_prime[k]*!dpi/180.) - tilt ;(k*10)*!pi/180. ;radians
	rho = ((smj)^2.*(smn)^2.) / ( (smj^2.+smn^2.)/2 - ((smj^2.-smn^2.)/2)*cos(2*omega) )
	x[k] = rho
	y[k] =  (smn*(smj)^4.) / ( (smn*x[k])^2.-(smj*x[k])^2.+smj^4. )^(3/2.)
	;plots, x[k], y[k], color=3, psym=-2
	;print, x[k], y[k]
	;******************
	; The curvature only at the middle
	if k eq flag then mid_curvature = [x[k], y[k]]
endfor

print, 'mid_curvature: ', mid_curvature


plots, x, y, color=3, psym=-2
;oplot, y, color=3, psym=-2
avey = ave(y)
avex = ave(x)




;**********************
; Overplot the full curvature curve!


omega_prime = dindgen(36)

; going to step through 360degrees at 10degree intervals
x = dblarr(36)
y = dblarr(36)

for k=0,9 do begin
	omega = (omega_prime[k]*10*!dpi/180.) - tilt ;(k*10)*!pi/180. ;radians
	rho = ((smj)^2.*(smn)^2.) / ( (smj^2.+smn^2.)/2 - ((smj^2.-smn^2.)/2)*cos(2*omega) )
	x[k] = rho
	y[k] =  (smn*(smj)^4.) / ( (smn*x[k])^2.-(smj*x[k])^2.+smj^4. )^(3/2.)
	;print, x[k], y[k]
endfor

for k=10,18 do begin
	omega = (k*10)*!pi/180. ;radians
	rho = ((smj)^2.*(smn)^2.) / ( (smj^2.+smn^2.)/2 - ((smj^2.-smn^2.)/2)*cos(2*omega) )
	x[k] = - rho
	y[k] =  (smn*(smj)^4.) / ( (smn*x[k])^2.-(smj*x[k])^2.+smj^4. )^(3/2.)
	;print, x[k], y[k]
endfor

for k=19,27 do begin
	omega = (k*10)*!pi/180. ;radians
	rho = ((smj)^2.*(smn)^2.) / ( (smj^2.+smn^2.)/2 - ((smj^2.-smn^2.)/2)*cos(2*omega) )
	x[k] = - rho
	y[k] = - (smn*(smj)^4.) / ( (smn*x[k])^2.-(smj*x[k])^2.+smj^4. )^(3/2.)
	;print, x[k], y[k]
endfor

for k=27,35 do begin
	omega = (k*10)*!pi/180. ;radians
	rho = ((smj)^2.*(smn)^2.) / ( (smj^2.+smn^2.)/2 - ((smj^2.-smn^2.)/2)*cos(2*omega) )
	x[k] =  rho
	y[k] = - (smn*(smj)^4.) / ( (smn*x[k])^2.-(smj*x[k])^2.+smj^4. )^(3/2.)
	;print, x[k], y[k]
endfor


plots, x, y, color=2, psym=1
;oplot, y, color=2, psym=1

end
