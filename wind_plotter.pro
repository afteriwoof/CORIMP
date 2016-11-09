; Written from ace_plotter3.pro to plot WIND data from txt files

;Created 14-06-10

pro wind_plotter, file, no_lines=no_lines, tog=tog

if keyword_set(tog) then begin
	toggle, f='wind_plot.ps', /color, /portrait
	!p.font=2
	!p.charsize=2
	!p.charthick=2
	!p.thick=2
	!x.thick=2
	!y.thick=2
endif else begin
	!p.font=-1
	!p.charsize=2
	!p.charthick=1
	!p.thick=1
endelse

readcol, file, date, time, b_ave, bx, by, bz, sp, den, temp, f='A,A,D,D,D,D,D,D,D'

b_ave[where(b_ave eq max(b_ave))] = 1/0.
bx[where(bx eq max(bx))] = 1/0.
by[where(by eq max(by))] = 1/0.
bz[where(bz eq max(bz))] = 1/0.
sp[where(sp eq max(sp))] = 1/0.
den[where(den eq max(den))] = 1/0.
temp[where(temp eq max(temp))] = 1/0.

!p.background = 255
!p.color = 0   


base=anytim(time[0]+' '+dmy2ymd(date[0]))

t = dblarr(n_elements(time))
for k=0,n_elements(time)-1 do t[k] = anytim(time[k]+' '+dmy2ymd(date[k])) - anytim(base)

rsun = 6.95508e8


day15 = anytim('15-Dec-2008 00:00')-base ;'16-Dec-2008 07:25'
day16 = anytim('16-Dec-2008 00:00')-base
day17 = anytim('17-Dec-2008 00:00')-base
day18 = anytim('18-Dec-2008 00:00')-base ;'16-Dec-2008 11:19'

denline = anytim('16-Dec-2008 08:09')-base
denline2=anytim('16-Dec-2008 13:20')-base
mc1 = anytim('17-Dec-2008 04:50')-base
mc2 = anytim('17-Dec-2008 15:25')-base

ram = (0.5 * (1.67262158d*10.0d^(-27.0d)) * ((den)*(100.0d^3.0d)) * ((sp*1000.0d)^2.0d))/(10.0d^(-9.0d))

!p.multi=[0,1,7]

; plot full range:
; timerange1 = anytim(dmy2ymd(date[0])+' '+time[0],/atime)
; timerange2 = anytim(dmy2ymd(date[n_elements(t)-1])+' '+time[n_elements(t)-1],/atime)
timerange1 = '2008-12-15 12:00'
timerange2 = '2008-12-18 12:00'

utplot, t, den, base , timerange=[timerange1,timerange2],yrange=[0,35], /xstyle, ytitle='Proton density (cm!U-3!N)', $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], ytickname=['0',' ','10',' ','20',' ','30',' '], $
	/nolabel, xmargin =[10, 4], ymargin=[0,0], /ys, xticklen=0.05

; below 3 lines plot ---CME front---
;oplot, [anytim('16-dec-2008 08:09')-base,anytim('17-dec-2008 04:50')-base], [30,30], psym=-3, lines=0, color=3
;legend, ['             '], box=0, pos=[anytim('16-Dec-2008 14:00')-base,33], charsize=1, /clear
;xyouts, anytim('16-dec-08 14:20')-base, 29, 'CME front', charsize=1

;oplot, [anytim('17-dec-08 04:50')-base,anytim('17-dec-08 15:25')-base], [30,30], psym=-3, lines=0, color=5
;legend, ['  '], box=0, pos=[anytim('17-Dec-2008 08:00')-base,33], charsize=1, /clear
;xyouts, anytim('17-dec-08 08:20')-base, 29, 'MC', charsize=1


if ~keyword_set(no_lines) then begin
	verline, denline, color=3, lines=2, thick=3
	verline, denline2, color=3, lines=2, thick=3
	verline, mc1, color=5, lines=3, thick=3
	verline, mc2, color=5, lines=3, thick=3
	;arrow, anytim('16-Dec-2008 03:00')-base, 24, anytim('16-Dec-2008 07:00')-base, 15, color=3,/data, /solid, thick=2
	arrow, anytim('16-dec-08 09:09')-base, 22, anytim('16-dec-08 13:20')-base, 22, color=3,/data,/solid,thick=2
	arrow, anytim('16-dec-08 12:20')-base, 22, anytim('16-dec-08 08:09')-base, 22, color=3,/data,/solid,thick=2
	xyouts, anytim('15-Dec-2008 18:50')-base, 29, 'ENLIL arrival of', charsize=1
	xyouts, anytim('15-Dec-2008 19:25')-base, 24.5, 'the CME front', charsize=1
	xyouts, anytim('15-Dec-08 19:40')-base, 20, '08:09 - 13:20', charsize=1
	arrow, anytim('17-dec-08 05:50')-base, 22, anytim('17-dec-08 15:25')-base, 22, color=5,/data,/solid,thick=2
	arrow, anytim('17-dec-08 14:25')-base, 22, anytim('17-dec-08 04:50')-base, 22, color=5,/data,/solid,thick=2
	xyouts, anytim('17-dec-08 06:30')-base, 29, 'Magnetic', charsize=1
	xyouts, anytim('17-dec-08 07:50')-base, 24.5, 'cloud', charsize=1
	;verline, day15, color=3, lines=0
	;verline, day16, color=3, lines=0
	;verline, day17, color=3, lines=0
	;verline, day18, color=3, lines=0
endif

;xyouts, t1+500.0d, 380.0, anytim(t1+base, /vms), color=3, charthick=1.8
utplot, t, sp, base , timerange=[timerange1,timerange2],$
	yrange=[300,400], /xstyle, ytickname=[' ',' ',' ',' ',' ',' ',' '], $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 4], ymargin=[0,0], /ys, xticklen=0.05
axis, yaxis=1, ytit='Flow speed (km s!U-1!N)'
;legend, ['ACE']
if ~keyword_set(no_lines) then begin
	verline, denline, color=3, lines=2, thick=3
	verline, denline2, color=3, lines=2, thick=3
	verline, mc1, color=5, lines=3, thick=3
	verline, mc2, color=5, lines=3, thick=3
endif
;xyouts, t2+500.0d, 6.0, anytim(t2+base, /vms), color=5, charthick=1.8

;utplot, t, ram, ut[0] ,timerange=[anytim(ut[0],/atime),anytim(ut[n_elements(ut)-1],/atime) ],yrange=[0,0.8], /xstyle, ytitle='Dnynamic Pressure [nPa]', $
;	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 1], ymargin=[0,0]
;legend, ['ACE']
;verline, t1, color=3
;verline, t2, color=5

utplot, t, temp, base , timerange=[timerange1,timerange2],$
	yr=[10e3,10e4], /xstyle, ytit='Temperature (K)', /ylog, $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 4], ymargin=[0,0], /ys, xticklen=0.05

if ~keyword_set(no_lines) then begin
	verline, denline, /ylog, color=3, lines=2, thick=3
	verline, denline2, /ylog, color=3, lines=2, thick=3
	verline, mc1, color=5, lines=3, thick=3, /ylog
	verline, mc2, color=5, lines=3, thick=3, /ylog
endif

utplot, t, b_ave, base , timerange=[timerange1,timerange2],$
	yr=[0,12], /xstyle, ytickname=[' ',' ',' ',' ',' ',' ',' ',' '], $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 4], ymargin=[0,0], xticklen=0.05

axis, yaxis=1, ytit='|B| (nT)'

if ~keyword_set(no_lines) then begin
	verline, denline, color=3, lines=2, thick=3
	verline, denline2, color=3, lines=2, thick=3
	verline, mc1, color=5, lines=3, thick=3
	verline, mc2, color=5, lines=3, thick=3
endif

utplot, t, bx, base, timerange=[timerange1,timerange2], $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 4], ymargin=[0,0], $
	yr=[-6,4], /xstyle, ytit='B!Dx!N (nT)', xticklen=0.05

if ~keyword_set(no_lines) then begin
	verline, denline, color=3, lines=2, thick=3
	verline, denline2, color=3, lines=2, thick=3
	verline, mc1, color=5, lines=3, thick=3
	verline, mc2, color=5, lines=3, thick=3
endif

utplot, t, by, base, timerange=[timerange1,timerange2], $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 4], ymargin=[0,0], $
	yr=[-10,10], /xstyle, ytickname=[' ',' ',' ',' ',' ',' '], xticklen=0.05
axis, yaxis=1, ytit='B!Dy!N (nT)'
if ~keyword_set(no_lines) then begin
	verline, denline, color=3, lines=2, thick=3
	verline, denline2, color=3, lines=2, thick=3
	verline, mc1, color=5, lines=3, thick=3
	verline, mc2, color=5, lines=3, thick=3
endif

utplot, t, bz, base, ytitle='B!Dz!N (nT)', timerange=[timerange1,timerange2], $
	/nolabel, xmargin =[10, 4], ymargin=[0,0], /ys, yr=[-10,10], /xstyle, $
	xticklen=0.05, $
	xtickname=['12:00','00:00!C16-Dec-08','12:00','00:00!C17-Dec-08','12:00','00:00!C18-Dec-08','12:00','00:00!C19-Dec-08']
	
if ~keyword_set(no_lines) then begin
	verline, denline, color=3, lines=2, thick=3
	verline, denline2, color=3, lines=2, thick=3
	verline, mc1, color=5, lines=3, thick=3
	verline, mc2, color=5, lines=3, thick=3
endif

;xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 1], ymargin=[0,3], charsize=2.5, psym=-1, pos=[0.1, 0.666667, 0.97, 0.95], yr=[1, 300.0], /ystyle, color=2

if keyword_set(tog) then toggle

end

