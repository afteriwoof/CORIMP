; code to take in the ellipse axes lengths and tilt and compute the curvature equation to spit out curvature at given points along the ellipse

; Created: 05-05-09
; Last Edited: 07-05-09 to test for more than just quadrant.


pro ellipse_curvature, smj_init, smn_init, tilt


smj_init = float(smj_init)
smn_init = float(smn_init)
smn = smn_init/smj_init
smj = smj_init/smj_init ;arcsec
;tilt = 90 ;degrees
tilt = tilt*!pi/180. ;radians
;print, smj, smn, tilt

range=100
x = dblarr(range)
y = dblarr(range)
omega_prime = (dindgen(range)+110)
omega_prime *= !pi/180. ;radians

for k=0,range-1 do begin
	omega = omega_prime[k] - tilt
	;print, 'omega_prime: ', round(omega_prime[k]*180/!pi)
	;print, 'omega: ', omega*180/!pi
	rho = ((smj)^2.*(smn)^2.) / ( (smj^2.+smn^2.)/2 - ((smj^2.-smn^2.)/2)*cos(2*omega) )
	;print, 'rho: ', rho
	x[k] = rho*cos(omega)
	y[k] = - (smn*(smj)^4.) / ( (smn*x[k])^2.-(smj*x[k])^2.+smj^4. )^(3/2.)
	;print, x[k], y[k]
endfor

oplot, x, y, psym=-1, color=3
plots, ave(x), ave(y), psym=2, color=4
print, min(y)


end
