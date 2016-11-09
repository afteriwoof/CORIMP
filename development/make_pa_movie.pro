; Created to make movie of the heights along the position angles saved as pa_total.sav from run_algorithms_edges_tvsl.pro

; Created:	21-03-11
; Last edited:	22-03-11	to include C2, C3 and ylog keywords.


pro make_pa_movie, rsun, pa_total, pa_movie, C2=C2, C3=C3, ylog=ylog

sz = size(pa_total, /dim)

if keyword_set(C2) then begin
	yr1 = 0
	yr2 = 6500
	inner = 2.35
	outer = 6
	x = sz[1]-(sz[1]*0.2)
	yinn = 1950
	yout = 6000
	ysun = 600
endif

if keyword_set(C3) then begin
	yr1 = 0
	yr2 = 22000
	inner = 6
	outer = 19.5
	x = sz[1]-(sz[1]*0.2)
	yinn = 4500
	yout = 19600
	ysun = 1300
endif

if ~keyword_set(C2) && ~keyword_set(C3) then begin
	yr1 = 0
	yr2 = 22000
	inner1 = 2.35
	inner2 = 6
	outer = 19.5
	x = sz[1]-(sz[1]*0.2)
	yinn1 = 2150
	yinn2 = 4500
	yout = 19600
	ysun = 1200
endif

!p.charsize=2

xs1 = 1000
ys1 = 800

window, xs=xs1, ys=ys1
!p.multi=[0,1,2]

pa_movie = fltarr(xs1,ys1,360)

for k=0,359 do begin
	plot_image,pa_total,xtit='Position Angle (degrees)',ytit='Image No.'
	verline, k
	if ~keyword_set(ylog) then begin
		plot, pa_total[k,*], psym=1, yr=[yr1,yr2], /ys, xtit='Image No.', ytit='Height (arcsec)'
	endif else begin
		plot, pa_total[k,*], psym=1, yr=[rsun,3e4], /ylog, /ys, xtit='Image No.', ytit='Height (arcsec)'
	endelse
	horline, rsun
	if keyword_set(C2) || keyword_set(C3) then begin
		horline, rsun*inner, linestyle=2
		horline, rsun*outer, linestyle=2
		xyouts, x, yinn, 'Inner occulter'
		xyouts, x, yout, 'Outer occulter'
		xyouts, x, ysun, 'Solar limb'
	endif else begin
		horline, rsun*inner1, linestyle=2
		horline, rsun*inner2, linestyle=2
		horline, rsun*outer, linestyle=2
		xyouts, x, yinn1, 'Inner C2 occulter'
		xyouts, x, yinn2, 'Inner C3 occulter'
		xyouts, x, yout, 'Outer C3 occulter'
		xyouts, x, ysun, 'Solar limb'
	endelse
	pa_movie[*,*,k] = tvrd()
endfor


end
