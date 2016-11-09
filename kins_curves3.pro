; Following Peter's lead in using a txt file to call in parameters.
; see plot_vel_cdaw.pro

; Plots the angular width and the ellipse tilt angle.

; Last Edited: 13-02-08

pro kins_curves3 ; incl_cdaw


readcol, 'kins.txt', smj, smn, tilt, aw, hc, h, instr, date, time, h_err, delta_t, delta_tilt, mag_err, $
	f='F,F,F,F,F,F,A,A,A,F,F,F,F'
t = anytim(date+' '+time)
utbasedata = t[0]
t = anytim(t) - anytim(t[0])


;*********** Read in CDAW to compare / overplot.

readcol, 'kins_cdaw.txt', h_cdaw, date_cdaw, time_cdaw, angle_cdaw, f='F,A,A,F'

t_cdaw = anytim(date_cdaw+' '+time_cdaw)
t_cdaw = anytim(t_cdaw) - utbasedata

;***********
 ;Error analysis for the angles

a_err = fltarr(n_elements(h_err))
for i=0,n_elements(h_err)-1 do begin
	;x = h[i]/sqrt(2)
	;x_err = h_err[i]/sqrt(2)
	;x1 = x+(x_err/2.)
	;x2 = x-(x_err/2.)
	;recpol, x1, x2, radius1, angle1, /degrees
	;recpol, x2, x1, radius2, angle2, /degrees
	;a_err[i] = abs(angle1-angle2)
	a_err[i] = aw[i] * (h_err[i] / h[i])
	if ( h_err[i] lt mag_err[i]) then a_err[i] =  2*(180/!pi) * asin ( (mag_err[i]) / (2*sqrt( (hc[i]^2 + (0.5*mag_err[i])^2) )) )
endfor


 
;***********

!p.multi=[0,1,3]

utplot, t, aw, utbasedata, psym=-3, linestyle=1, ytit='Angular Width (degrees)', $
       xr=[t[0]-1000,t[*]+1000], yr=[30,110], /ys, /xs
oploterror, t, aw, delta_t, a_err, psym=3

utplot, t, tilt, utbasedata, psym=-3, linestyle=1, ytit='Ellipse Tilt Angle (degrees)', $
	xr=[t[0]-1000,t[*]+1000], yr=[-90,90], /ys, /xs
oploterror, t, tilt, delta_t, delta_tilt, psym=3



end
