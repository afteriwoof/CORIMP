; Following Peter's lead in using a txt file to call in parameters.
; see plot_vel_cdaw.pro

; Last Edited: 28-08-08

pro kins_curves_and_angs, cdaw=cdaw, fit_vel=fit_vel, seeds=seeds

readcol, 'kins_shift.txt', smj, smn, tilt, aw, hc, h, instr, date, time, h_err, delta_t, $
	delta_tilt, mag_err, tilt_err_deg, max_h_front, apex_angle, f='F,F,F,F,F,F,A,A,A,F,F,F,F,F,F,F'
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
       endcase
endfor
print, 'h_err' & print, h_err
	
r_sun = (pb0r((date[0]+' '+time[0]),/arc,/soho))[2] ;arcsec
RSun = 6.96e8 ;metres
km_arc = RSun / (1000*r_sun) ; km per arcsec
h_km = h*km_arc
h_rsun = h_km*1000 / RSun
h_rsun_err = (h_err*km_arc / RSun)*1000
v = deriv(t, h)
a = deriv(t, v)
;using derivsig instead of this formula
;v_err = fltarr(n_elements(t))
;a_err = v_err
;for i=0,n_elements(t)-1 do begin
;	v_err[i] = v[i] * ( h_err[i]/h[i] + delta_t[i]/t[i] )
;	a_err[i] = a[i] * ( v_err[i]/v[i] + delta_t[i]/t[i] )
;endfor
v_err = derivsig(t,h,delta_t,h_err)
a_err = derivsig(t,v,delta_t,v_err)

if keyword_set(fit_vel) then begin
	yf = 'p[0]*x + p[1]'
	f = mpfitexpr(yf, t, v, v_err, [h[0],v[0],a[0]], perror=perror)
	h_model = (f[0]/2.)*t^2 + f[1]*t + f[2]+0.9*h[0]
	v_model = f[0]*t + f[1]
	a_model = f[0]
endif else begin
	yf = 'p[0]*x^2. + p[1]*x + p[2]'
	f = mpfitexpr(yf, t, h, h_err, [h[0],v[0],a[0]], perror=perror)
	h_model = f[0]*t^2 + f[1]*t + f[2]
	v_model = f[0]*t + f[1]
	a_model = f[0]
endelse
print, 'h[0] ', h[0]
	
;!p.multi=[0,1,2]
;plot, h_rsun, v*km_arc, psym=-2, linestyle=1, tit='Ellipse', xtit='Height (R_sun)', ytit='Velocity (km/sec)'
;oploterror, h_rsun, v*km_arc, fltarr(n_elements(h_rsun)), v_err*km_arc, psym=3
;plot, h_rsun, a*km_arc*1000, psym=-2, linestyle=1, xtit='Height (R_sun)', ytit='Acceleration (km/sec^2)'
;oploterror, h_rsun, a*km_arc*1000, fltarr(n_elements(h_rsun)), a_err*km_arc*1000, psym=3
;line0 = replicate(0, n_elements(t))
;outplot, t, line0, utbasedata, psym=-3, linestyle=2
;pause


;*********** Read in CDAW to compare / overplot.

if keyword_set(cdaw) then begin
	readcol, 'kins_cdaw.txt', h_cdaw, date_cdaw, time_cdaw, angle_cdaw, f='F,A,A,F'
	t_cdaw = anytim(date_cdaw+' '+time_cdaw)
	t_cdaw = anytim(t_cdaw) - utbasedata
	;v_cdaw = deriv(t_cdaw, h_cdaw*r_sun)
	;a_cdaw = deriv(t_cdaw, v_cdaw)
endif

;***********

if keyword_set(seeds) then begin
	readcol, 'kins_seeds.txt', date_seeds, time_seeds, h_seeds, f='A,A,F'
	t_seeds = anytim(date_seeds+' '+time_seeds)
	print, t_seeds
	t_seeds = anytim(t_seeds) - utbasedata
endif



!p.multi=[0,1,4]

xrs = 1000
xls = 2000

utplot, t, h_rsun, utbasedata, psym=3, linestyle=1, ytit='!6Height (R!D!9n!N!X)', $
	xr=[t[0]-xls,t[*]+xrs], yr=[0,23], /xs, /ys, /notit, /nolabel, $
	xtickname = [' ',' ',' ',' ',' ',' ',' '], $
	pos=[0.15,0.78,0.95,0.98];, ytickname=['0','5','10','15','20','25','30']
outplot, t, h_model/r_sun, utbasedata, psym=-3, linestyle=0
oploterror, t, h_rsun, delta_t, h_rsun_err, psym=3

if keyword_set(cdaw) && ~keyword_set(seeds) then begin
	outplot, t_cdaw, h_cdaw, utbasedata, psym=-4, linestyle=2
	legend, ['CDAW','Multiscale','Model'], psym=[4,1,-3], charsize=1
endif
if keyword_set(seeds) && keyword_set(cdaw) then begin
	outplot, t_cdaw, h_cdaw, utbasedata, psym=-4, linestyle=2
	outplot, t_seeds, h_seeds, utbasedata, psym=-7, linestyle=3
	legend, ['CDAW', 'SEEDS', 'Multiscale', 'Model'], psym=[4,7,1,-3], charsize=1
endif
if keyword_set(seeds) && ~keyword_set(cdaw) then begin
	outplot, t_seeds, h_seeds, utbasedata, psym=-7, linestyle=3
	legend, ['SEEDS','Multiscale','Model'], psym=[7,1,-3], charsize=1
endif
if ~keyword_set(cdaw) && ~keyword_set(cdaw) then begin
	legend, ['Multiscale', 'Model'], psym=[1,-3], charsize=1.5
endif


utplot, t, v*km_arc, utbasedata, psym=3, linestyle=1, ytit='!6Velocity (km s!U-1!N)', $
	/notit, /nolabel, xtickname = [' ',' ',' ',' ',' ',' ',' '], xr=[t[0]-xls,t[*]+xrs], /xs, $
	yr=[-200,850], /ys, pos=[0.15,0.58,0.95,0.78];, ytickname=['-500','0','500','1000',' '] 
outplot, t, v_model*km_arc, utbasedata, psym=-3, linestyle=0
oploterror, t, v*km_arc, delta_t, v_err*km_arc, psym=3

;outplot, t_cdaw, v_cdaw*km_arc, utbasedata, psym=-4, line=2

print, 'accel (model): ', a_model*km_arc*1000
print, 'perror: ', perror
print, perror[0]*km_arc*1000
print, perror[1]*km_arc
print, perror[2]/r_sun
print, 'h_model: ', h_model/r_sun
print, 'v_model: ', v_model*km_arc
print, 'a_model: ', a_model[0]*km_arc*1000



;***************************************************

; Stick on the angle plots now



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


utplot, t, aw, utbasedata, psym=-3, linestyle=1, /notit, /nolabel, xtickname = [' ',' ',' ',' ',' ',' ',' '], ytit='!6Angular Width (degrees)', $
       xr=[t[0]-xls,t[*]+xrs], yr=[40,105], pos=[0.15,0.38,0.95,0.58], /ys, /xs
oploterror, t, aw, delta_t, a_err, psym=3

utplot, t, tilt, utbasedata, psym=-3, linestyle=1, /notit, ytit='!6Ellipse Tilt (degrees)', $
	xr=[t[0]-xls,t[*]+xrs], yr=[10,110], pos=[0.15,0.18,0.95,0.38], /ys, /xs
oploterror, t, tilt, delta_t, delta_tilt, psym=3


end
