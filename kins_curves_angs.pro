
; see plot_vel_cdaw.pro

; Plots the angular width and the ellipse tilt angle.

; Taken from kins_curves3.pro

; Last Edited: 13-08-08 to include Cor1 and Cor2

pro kins_curves_angs


readcol, 'kins_shift.txt', smj, smn, tilt, aw, hc, h, instr, date, time, h_err, delta_t, delta_tilt, mag_err, $
	tilt_err_deg, max_h_front, apex_angle, f='F,F,F,F,F,F,A,A,A,F,F,F,F,F,F,F'
t = anytim(date+' '+time)
utbasedata = t[0]
t = anytim(t) - anytim(t[0])

; Because of occulter interference on the ellipse fit at low C2, check the error isn't larger than PIX_ERRS
for k=0,n_elements(mag_err)-1 do begin
	if (h_err[k] gt mag_err[k]) then h_err[k]=mag_err[k]
	;h_err[k]=mag_err[k]
endfor

; Hardcoding in the minimum error based upon Scale 5 (8-3) which has filter size 2^3=8pixels.
for k=0,n_elements(h_err)-1 do begin
        case instr[k] of
       'C2': if h_err[k] lt 95.2 then h_err[k]=95.2
       'C3': if h_err[k] lt 448 then h_err[k]=448
       'COR1': if h_err[k] lt 60. then h_err[k]=60.
       'COR2': if h_err[k] lt 235.2 then h_err[k]=235.2
        endcase
endfor


;***********
 ;Error analysis for the angles

a_err = fltarr(n_elements(h_err))

for i=0,n_elements(h_err)-1 do begin
	; Taking the angular width error from the error formula dx/x = dy/y + dz/z	
	a_err[i] = aw[i] * (h_err[i] / h[i])
	; Accounting for mag_err using AngWidthErr.jpg in PhD folder
	;if ( h_err[i] lt mag_err[i]) then a_err[i] =  2*(180/!pi) * asin ( (mag_err[i]) / (2*sqrt( (hc[i]^2 + (0.5*mag_err[i])^2) )) )
	; Adding on the error accounted for by filter size at scale 5.
	case instr[i] of
	'C2': a_err[i] += ( atan(95.2 / hc[i])*(180/!pi) )
	'C3': a_err[i] += ( atan(448. / hc[i])*(180/!pi) )
	'COR1': a_err[i] += ( atan(60. / hc[i])*(180/!pi) )
	'COR2': a_err[i] += ( atan(235.2 / hc[i])*(180/!pi) )
	endcase

	; Doing similar for tilt error
	case instr[i] of
	'C2': delta_tilt[i] = delta_tilt[i] + ( atan(95.2/hc[i])*(180/!pi) )
	'C3': delta_tilt[i] = delta_tilt[i] + ( atan(448./hc[i])*(180/!pi) )
	'COR1': delta_tilt[i] = delta_tilt[i]*(180/!pi) + ( atan(60./hc[i])*(180/!pi) )
	'COR2': delta_tilt[i] = delta_tilt[i]*(180/!pi) + ( atan(235.2/hc[i])*(180/!pi) )
	endcase
endfor


; Case of when certain ellipse fits are not accurate take only those that are:
;i = [24,25,26,27,28,32,33,34,35,37,38,39,40,41,42,43,44,45]
;a_err = a_err[i]
;t = t[i]
;aw = aw[i]
;delta_t = delta_t[i]
;tilt = tilt[i]
;delta_tilt = delta_tilt[i]

 
;***********

!p.multi=[0,1,3]

xls = 1200
xrs = 1200

utplot, t, aw, utbasedata, psym=-3, linestyle=1, ytit='!6Angular Width (degrees)', $
       xr=[t[0]-xls,t[*]+xrs], yr=[25,55], /ys, /xs
oploterror, t, aw, delta_t, a_err, psym=3

utplot, t, tilt, utbasedata, psym=-3, linestyle=1, ytit='!6Ellipse Tilt Angle (degrees)', $
	xr=[t[0]-xls,t[*]+xrs], yr=[30,165], /ys, /xs
oploterror, t, tilt, delta_t, delta_tilt, psym=3



end
