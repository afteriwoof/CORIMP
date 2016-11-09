; code to take in the ellipse axes lengths and tilt and compute the curvature equation to spit out curvature at given points along the ellipse

; Created: 07-05-09 from ellipse_curvature1.pro to try and step around the whole ellipse.
; Last Edited: 11-09-09  to apply to event 20081212.

pro ellipse_curvature2, smj_init, smn_init, tilt, xf, zf


smj_init = float(smj_init)
smn_init = float(smn_init)
smn = smn_init/smj_init
smj = smj_init/smj_init ;arcsec
print, 'semimajor: ', smj & print, 'semiminor: ', smn

tilt *= !dpi/180.  ;radians
print, 'tilt (rad): ', tilt & print, 'tilt(deg): ', tilt*180/!dpi

omega_prime = dindgen(36)

; going to step through 360degrees at 10degree intervals
x = dblarr(36)
y = dblarr(36)

plot, indgen(2), xr=[-1.5,1.5], yr=[-4,4], /nodata

for k=0,9 do begin
	omega = (omega_prime[k]*10*!dpi/180.) - tilt ;(k*10)*!pi/180. ;radians
	rho = ((smj)^2.*(smn)^2.) / ( (smj^2.+smn^2.)/2 - ((smj^2.-smn^2.)/2)*cos(2*omega) )
	x[k] = rho
	y[k] =  (smn*(smj)^4.) / ( (smn*x[k])^2.-(smj*x[k])^2.+smj^4. )^(3/2.)
	plots, x[k], y[k], color=3, psym=-2
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


plots, x, y, color=2, psym=-1

end
