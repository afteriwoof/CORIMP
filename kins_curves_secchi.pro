; Writing from kins_curves_incl_cdaw.pro to make plots for the secchi instruments.

; see plot_vel_cdaw.pro

; Last Edited: 12-08-08

pro kins_curves_secchi, fit_vel=fit_vel

readcol, 'kins.txt', smj, smn, tilt, aw, hc, h, instr, date, time, h_err, delta_t, $
	tilt_err, mag_err, tilt_err_deg, max_h_front, apex_angle, f='F,F,F,F,F,F,A,A,A,F,F,F,F,F,F,F'
t = anytim(date+' '+time)
utbasedata = t[0]
t = anytim(t) - anytim(t[0])

; Because of occulter interference on the ellipse fit at low heights, check the error isn't larger than PIX_ERRS
;for k=0,n_elements(mag_err)-1 do begin
;	if (h_err[k] gt mag_err[k]) then h_err[k]=mag_err[k]
;	h_err[k]=mag_err[k]
;endfor

; Hardcoding in the minimum error based upon Scale 5 (8-3) which has filter size 2^3=8pixels.
for k=0,n_elements(h_err)-1 do begin
	case instr[k] of
       'COR1': h_err[k]=60 ; should be a minimum but it's actually appropriate
       'COR2': h_err[k]=235.2
       endcase
endfor

for k=0,n_elements(h_err)-2 do h_err[k]=500.

; When ellipse height is not on front, take the max_h_front
;i = [10,11,12,13,14,16,19,20,22,23,29,30,31]
;h[i] = max_h_front[i]
;h = max_h_front

; Must input the r_sun for each plot manually:
r_sun_cor1 = 999.45
r_sun_cor2 = 999.45
r_sun_ave = (r_sun_cor1 + r_sun_cor2)/2.
RSun = 6.96e8 ;metres
km_arc_cor1 = RSun / (1000*r_sun_cor1) ; km per arcsec
km_arc_cor2 = RSun / (1000*r_sun_cor2) ; km per arcsec
km_arc_ave = (km_arc_cor1 + km_arc_cor2)/2.
h_km = fltarr(n_elements(h))
for k=0,n_elements(h)-1 do begin
	case instr[k] of
	'COR1': h_km[k] = h[k]*km_arc_cor1
	'COR2': h_km[k] = h[k]*km_arc_cor2
	endcase
endfor
h_rsun = h_km*1000 / RSun
h_rsun_err = fltarr(n_elements(h_rsun))
for k=0,n_elements(h_rsun)-1 do begin
	case instr[k] of
	'COR1': h_rsun_err[k] = (h_err[k]*km_arc_cor1 / RSun)*1000
	'COR2': h_rsun_err[k] = (h_err[k]*km_arc_cor2 / RSun)*1000
	endcase
endfor
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
	h_model = (f[0]/2.)*t^2 + f[1]*t + f[2]+1.0*h[0]
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
	


;*********** Read in CDAW to compare / overplot.

;readcol, 'kins_cdaw.txt', h_cdaw, date_cdaw, time_cdaw, angle_cdaw, f='F,A,A,F'
;
;t_cdaw = anytim(date_cdaw+' '+time_cdaw)
;t_cdaw = anytim(t_cdaw) - utbasedata
;
;v_cdaw = deriv(t_cdaw, h_cdaw*r_sun)
;a_cdaw = deriv(t_cdaw, v_cdaw)

;***********



!p.multi=[0,1,3]

xrs = 1000
xls = 1000

utplot, t, h_rsun, utbasedata, psym=3, linestyle=1, ytit='!6Height (R!D!9n!N!X)', $
	xr=[t[0]-xls,t[*]+xrs], yr=[0,16], /xs, /ys, /notit, /nolabel, $
	xtickname = [' ',' ',' ',' ',' ',' ',' '], $
	pos=[0.15,0.68,0.95,0.98];, ytickname=['0','5','10','15','20','25','30']
outplot, t, h_model/r_sun_ave, utbasedata, psym=-3, linestyle=0
oploterror, t, h_rsun, delta_t, h_rsun_err, psym=3

;outplot, t_cdaw, h_cdaw, utbasedata, psym=-4, linestyle=2

legend, ['Multiscale', 'Model'], psym=[1,-3], charsize=1
;legend, ['Multiscale', 'Model'], psym=[1,-3], charsize=1

utplot, t, v*km_arc_ave, utbasedata, psym=3, linestyle=1, ytit='!6Velocity (km s!U-1!N)', $
	/notit, /nolabel, xtickname = [' ',' ',' ',' ',' ',' ',' '], xr=[t[0]-xls,t[*]+xrs], /xs, $
	yr=[0,800], /ys, pos=[0.15,0.38,0.95,0.68];, ytickname=['-500','0','500','1000',' '] 
outplot, t, v_model*km_arc_ave, utbasedata, psym=-3, linestyle=0
oploterror, t, v*km_arc_ave, delta_t, v_err*km_arc_ave, psym=3

;outplot, t_cdaw, v_cdaw*km_arc, utbasedata, psym=-4, line=2

utplot, t, a*km_arc_ave*1000, utbasedata, psym=3, linestyle=1, /notit, ytit='!6Acceleration (m s!U-1!N s!U-1!N)', $
	xr=[t[0]-xls,t[*]+xrs], /xs, /ys, yr=[-350,150], pos=[0.15,0.08,0.95,0.38];, ytickname=['-600','-400','-200','0','200','400',' ']
a_model_array = replicate(a_model*km_arc_ave*1000, n_elements(t))
outplot, t, a_model_array, utbasedata, psym=-3, linestyle=0
oploterror, t, a*km_arc_ave*1000, delta_t, a_err*km_arc_ave*1000, psym=3

;outplot, t_cdaw, a_cdaw*km_arc*1000, utbasedata, psym=-4, line=2

print, 'accel (model): ', a_model*km_arc_ave*1000
print, 'perror: ', perror
print, perror[0]*km_arc_ave*1000
print, perror[1]*km_arc_ave
print, perror[2]/r_sun_ave
print, 'h_model: ', h_model/r_sun_ave
print, 'v_model: ', v_model*km_arc_ave
print, 'a_model: ', a_model[0]*km_arc_ave*1000

;outplot, t, line0, utbasedata, psym=-3, linestyle=2
print, '*********************************'
print, ' DID YOU INPUT R_Sun MANUALLY??? '
print, '*********************************'
end
