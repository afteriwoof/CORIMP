; Following Peter's lead in using a txt file to call in parameters.
; see plot_vel_cdaw.pro

; Last Edited: 10-01-08

pro kins_curves_cdaw

readcol, 'kins_cdaw.txt', h_rsun, date, time, f='F,A,A'
t = anytim(date+' '+time)
utbasedata = t[0]
t = anytim(t) - anytim(t[0])

r_sun = (pb0r(t[0],/arc,/soho))[2] ;arcsec
RSun = 6.96e8 ;metres
km_arc = RSun / (1000*r_sun) ; km per arcsec
h_km = h_rsun*RSun/1000

v = deriv(t, h_rsun)
a = deriv(t, v)

yf = 'p[0]*x^2. + p[1]*x + p[2]'
f = mpfitexpr(yf, t, h_rsun, h_rsun*0.1, [h_rsun[0],v[0],a[0]])

h_model = f[0]*t^2 + f[1]*t + f[2]
v_model = f[0]*t + f[1]
a_model = f[0]

!p.multi=[0,1,2]
plot, h_rsun, v*km_arc*1000, psym=-2, tit='CDAW', xtit='Height (R_sun)', ytit='Velocity (km/sec)'
plot, h_rsun, a*km_arc*1e6, psym=-2, xtit='Height (R_sun)', ytit='Acceleration (km/sec^2)'
pause

!p.multi=[0,1,3]

utplot, t, h_rsun, utbasedata, psym=-1, linestyle=1, tit='!6Height Apex', ytit='R_sun', xr=[t[0]-t[1]/10,t[*]]
outplot, t, h_model, utbasedata, psym=-3, linestyle=0

utplot, t, v*km_arc*1000, utbasedata, psym=-1, linestyle=1,tit='Velocity Apex', ytit='km/sec', xr=[t[0]-100,t[*]]
outplot, t, v_model*km_arc*1000, utbasedata, psym=-3, linestyle=0

utplot, t, a*km_arc*1e6, utbasedata, psym=-1, linestyle=1, tit='Acceleration Apex', ytit='m/sec^2', xr=[t[0]-100,t[*]]
a_model_array = replicate(a_model*km_arc*1e6, n_elements(t))
outplot, t, a_model_array, utbasedata, psym=-3, linestyle=0

line0 = replicate(0, n_elements(t))
outplot, t, line0, utbasedata, psym=-3, linestyle=2

end
