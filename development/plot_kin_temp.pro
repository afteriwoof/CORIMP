pro plot_kin_temp

!p.multi=[0,1,3]

restore,'kin_temp.sav'

h_param /= 1000.

utplot, t_param, h_param, psym=2, ytit='Height (m)'

t_param = anytim(t_param)

t = t_param - min(t_param)

yf = 'p[0]*(x^2.)+p[1]*x+p[2]'

f = mpfitexpr(yf, t, h_param)

t_coords = make_coordinates(1001,minmax(t))

h_fit = f[0]*(t_coords^2.) + f[1]*t_coords + f[2]

plot, t_param, h_param, psym=2, ytit='Height (m)'
oplot, t_coords+min(t_param), h_fit, psym=-3

v = deriv(t, h_param*1000.)
pmm, v
v_fit = f[0]*t_coords + f[1]
pmm, v_fit*1000.
v_fit_deriv = deriv(t_coords,h_fit)
pmm, v_fit_deriv

plot, t_param, v, psym=2, ytit='Vel. (km/s)'
oplot, t_coords+min(t_param), v_fit*1000., psym=-3
oplot, t_coords+min(t_param), v_fit_deriv*1000., psym=-3, linestyle=2
; SPLINE
; res = spline(X,Y,T)
z = findgen(max(t))
res = spline(t,h_param,z)
plot, t, h_param, psym=2
oplot, res, line=2
help, res

res_t = findgen(n_elements(res))
res_v = deriv(res_t, res)
plot, t_param, v, psym=2, ytit='Vel. (km/s)'
oplot, res_t+min(t_param), res_v*1000.


;stop


end
