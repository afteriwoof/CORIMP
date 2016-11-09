; code to take in the ellipse axes lengths and tilt and compute the curvature equation to spit out curvature at given points along the ellipse

; Created: 05-05-09

pro ellipse_curvature1, smj_init, smn_init


smj_init = float(smj_init)
smn_init = float(smn_init)
smn = smn_init/smj_init
smj = smj_init/smj_init ;arcsec
;print, smj, smn

steps = 10.
stepsize = (smj/2.)/steps

x = fltarr(21)
x[0]= -(smj/2.)
for k=1,20 do x[k] = x[k-1] + stepsize

y = - (smn*(smj)^4.) / ( (smn*x)^2.-(smj*x)^2.+smj^4. )^(3/2.)

;for k=0,20 do print, x[k], y[k]

oplot, x, y, color=0, psym=-3

end
