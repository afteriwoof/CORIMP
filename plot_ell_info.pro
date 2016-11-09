; Created	2013-07-31	to plot the ellipse info from the set of saved ellipse fits to CME fronts.

; INPUT		ell_fls		the list of ell_arcsec_HHMM.sav files.
;		times		the list of times (date+time) of the entries, from in.date_obs (restore ell_times.sav).

pro plot_ell_info, ell_fls, times

; ei	is the ell_info containing 1)semimajor 2)semiminor 3)angle_mj 4)aw 5)height_centre 6)height_apex

; re	is the r_err, error on the height.

; xe	is the x_ellipse, x-coords of the ellipse.
; ye	is the y_ellipse, y-coords of the ellipse.

; pe	is the perror, error on the parameters from the mpfitellipse.

; mhf	is the max_h_front, maximum height along the front.

; mhe	is the max_h_ell, maximum height along the ellipse.

; aa	is the apex_a, the angle of the apex of the ellipse.

test_time = '2013-05-22T10:05:00'

ell_fls=file_search('ell_arcsec*sav')
restore, 'ell_times.sav',/ver

centers = fltarr(2,n_elements(ell_fls))
smjs = fltarr(n_elements(ell_fls))
smns = fltarr(n_elements(ell_fls))
tilts = fltarr(n_elements(ell_fls))

for i=0,n_elements(ell_fls)-1 do begin & $
	restore, ell_fls[i] & $
	centers[0,i] = ave(xe) & $
	centers[1,i] = ave(ye) & $
	smjs[i] = ei[0] & $
	smns[i] = ei[1] & $
	tilts[i] = ei[2] & $
endfor

window, xs=1100, ys=1200
!p.charsize=2
!p.multi=[0,2,3]
set_line_color

x = indgen(n_elements(ell_fls))

base = anytim(times[0])
atimes = anytim(times) - base
itimes = findgen(atimes[n_elements(atimes)-1])
t = findgen(max(itimes))*((n_elements(atimes)-1)/max(itimes))

test = anytim(test_time)-base

utplot, atimes, centers[0,*], base, psym=-2, tit='x center'
fit = spline(x,centers[0,*],t)
outplot, itimes, fit, line=0, color=3
verline, test, line=2
xc = fit[round(test)]
legend, int2str(xc)
horline, xc, line=2

utplot, atimes, centers[1,*], base, psym=-2, tit='y center'
fit = spline(x,centers[1,*],t)
outplot, itimes, fit, line=0, color=3
verline, test, line=2
yc = fit[round(test)]
legend, int2str(yc)
horline, yc, line=2

utplot, atimes, smjs, base, psym=-2, tit='smj'
fit = spline(x,smjs,t)
outplot, itimes, fit, line=0, color=3
verline, test, line=2
smj = fit[round(test)]
legend, int2str(smj)
horline, smj, line=2

utplot, atimes, smns, base, psym=-2, tit='smn'
fit = spline(x,smns,t)
outplot, itimes, fit, line=0, color=3
verline, test, line=2
smn = fit[round(test)]
legend, int2str(smn)
horline, smn, line=2

utplot, atimes, tilts, base, psym=-2, tit='tilts'
fit = spline(x,tilts,t)
outplot, itimes, fit, line=0, color=3
verline, test, line=2
tilt = fit[round(test)]
legend, int2str(tilt)
horline, tilt, line=2

; Reconstruct ellipse
npoints = 120.
phi = 2*!pi*(findgen(npoints)/(npoints-1))
cosang = cos(tilt*!pi/180.)
sinang = sin(tilt*!pi/180.)
a = smj*cos(phi)
b = smn*sin(phi)
aprime = xc+(a*cosang)-(b*sinang)
bprime = yc+(a*sinang)+(b*cosang)
!p.multi=0
window, 1, xs=1024, ys=1024
plot_map, map, /limb
plots, aprime, bprime, psym=-2
plots, xc, yc, psym=1



end
