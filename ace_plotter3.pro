pro ace_plotter3, d1, d2, no_lines=no_lines

a=get_acedata(d1,d2,/swepam)

!p.background = 255
!p.color = 0   
!p.charsize = 2
!p.charthick=1

size_a=size(a)

ts = a.time/1e3
mjd2date,a.mjd,y,m,d    
m = strcompress(string(m),/rem)     
d = strcompress(string(d),/rem)
y=strcompress(string(y),/rem)

date=anytim(y+'-'+m+'-'+d)
ut=date+ts

base = anytim(ut[0])
t=anytim(ut)-anytim(base)

pret = anytim('15-Dec-2008 13:31:52.752')-base
t1 = anytim('15-Dec-2008 13:31:52.752')-base ;'16-Dec-2008 07:25'
t1p = anytim('16-Dec-2008 01:15:51.250')-base
t1m = anytim('15-Dec-2008 03:18:02.266')-base
t2 = anytim('15-Dec-2008 11:28:38.986')-base ;'16-Dec-2008 11:19'
t2p = anytim('16-Dec-2008 07:51:38.111')-base
t2m = anytim('14-Dec-2008 20:43:27.966')-base
t3 = anytim('15-Dec-2008 22:23:09.544')-base
t3p = anytim('16-Dec-2008 06:05:23.956')-base
t3m = anytim('15-Dec-2008 07:00:41.038')-base



sp = a.b_speed
den = a.p_density
ram = (0.5 * (1.67262158d*10.0d^(-27.0d)) * ((den)*(100.0d^3.0d)) * ((sp*1000.0d)^2.0d))/(10.0d^(-9.0d))
!p.multi=[0,1,7]

utplot, t, median(sp, 15), ut[0] , timerange=[anytim(ut[0],/atime),anytim(ut[n_elements(ut)-1],/atime) ],yrange=[280,380], /xstyle, ytitle='Bulk speed [km/s]', $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 1], ymargin=[0,3], /ys
;legend, ['ACE']
if ~keyword_set(no_lines) then begin
	horline, mean(sp)
	;verline, pret, color=7
	verline, t1, color=3
	verline, t1p, color=3, lines=2
	verline, t1m, color=3, lines=2
	verline, t2, color=4
	verline, t2p, color=4, lines=2
	verline, t2m, color=4, lines=2
	verline, t3, color=5
	verline, t3p, color=5, lines=2
	verline, t3m, color=5, lines=2
	; my expected arrival
	;verline, anytim('16-dec-2008T08:00')-base, color=6, lines=2
endif

;xyouts, t1+500.0d, 380.0, anytim(t1+base, /vms), color=3, charthick=1.8

utplot, t, median(den, 15), ut[0] , timerange=[anytim(ut[0],/atime),anytim(ut[n_elements(ut)-1],/atime) ],yrange=[0,6], /xstyle, ytitle='Density [p/cm!u2!n]', $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 1], ymargin=[0,0], /ys
;legend, ['ACE']
if ~keyword_set(no_lines) then begin
	horline, mean(den)
	;verline, pret, color=7
	verline, t1, color=3
	verline, t1p, color=3, lines=2
	verline, t1m, color=3, lines=2
	verline, t2, color=4
	verline, t2p, color=4, lines=2
	verline, t2m, color=4, lines=2
	verline, t3, color=5
	verline, t3p, color=5, lines=2
	verline, t3m, color=5, lines=2
endif
;xyouts, t2+500.0d, 6.0, anytim(t2+base, /vms), color=5, charthick=1.8

;utplot, t, median(ram, 10), ut[0] ,timerange=[anytim(ut[0],/atime),anytim(ut[n_elements(ut)-1],/atime) ],yrange=[0,0.8], /xstyle, ytitle='Dnynamic Pressure [nPa]', $
;	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 1], ymargin=[0,0]
;legend, ['ACE']
;verline, t1, color=3
;verline, t2, color=5

utplot, t, median(a.ion_temp, 15), ut[0] , timerange=[anytim(ut[0],/atime),anytim(ut[n_elements(ut)-1],/atime) ],yrange=[0,100000], /xstyle, ytitle='Ion Temperature [k]', $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 1], ymargin=[0,0], /ys

;verline, pret, color=7
if ~keyword_set(no_lines) then begin
	horline, mean(a.ion_temp)
	verline, t1, color=3
	verline, t1p, color=3, lines=2
	verline, t1m, color=3, lines=2
	verline, t2, color=4
	verline, t2p, color=4, lines=2
	verline, t2m, color=4, lines=2
	verline, t3, color=5
	verline, t3p, color=5, lines=2
	verline, t3m, color=5, lines=2
endif

b=get_acedata(d1,d2,/mag)

tsb = b.time/1e3
mjd2date,b.mjd,yb,mb,db    
mb = strcompress(string(mb),/rem)     
db = strcompress(string(db),/rem)
yb=strcompress(string(yb),/rem)

dateb=anytim(yb+'-'+mb+'-'+db)
utb=dateb+tsb

baseb = anytim(utb[0])
tb=anytim(utb)-anytim(baseb)

btot = sqrt((b.bx^2.0d)+(b.by^2.0d)+(b.bz^2.0d))

utplot, tb, median(b.bx/btot, 15), base, ytitle='Bx/|B|', timerange=[anytim(utb[0],/atime),anytim(utb[n_elements(utb)-1],/atime) ], /xs, $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 1], ymargin=[0,0]

if ~keyword_set(no_lines) then begin
	horline, mean(b.bx/btot)
	;verline, pret, color=7
	verline, t1, color=3
	verline, t1p, color=3, lines=2
	verline, t1m, color=3, lines=2
	verline, t2, color=4
	verline, t2p, color=4, lines=2
	verline, t2m, color=4, lines=2
	verline, t3, color=5
	verline, t3p, color=5, lines=2
	verline, t3m, color=5, lines=2
endif

utplot, tb, median(b.by/btot, 15), base, ytitle='Bx/|B|', timerange=[anytim(utb[0],/atime),anytim(utb[n_elements(utb)-1],/atime) ], /xs, $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 1], ymargin=[0,0]
if ~keyword_set(no_lines) then begin
	horline, mean(b.by/btot)
	;verline, pret, color=7
	verline, t1, color=3
	verline, t1p, color=3, lines=2
	verline, t1m, color=3, lines=2
	verline, t2, color=4
	verline, t2p, color=4, lines=2
	verline, t2m, color=4, lines=2
	verline, t3, color=5
	verline, t3p, color=5, lines=2
	verline, t3m, color=5, lines=2
endif

utplot, tb, median(b.bz/btot, 15), base, ytitle='Bx/|B|', timerange=[anytim(utb[0],/atime),anytim(utb[n_elements(utb)-1],/atime) ], /xs, $
	xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 1], ymargin=[0,0]
if ~keyword_set(no_lines) then begin
	horline, mean(b.bz/btot)
	;verline, pret, color=7
	verline, t1, color=3
	verline, t1p, color=3, lines=2
	verline, t1m, color=3, lines=2
	verline, t2, color=4
	verline, t2p, color=4, lines=2
	verline, t2m, color=4, lines=2
	verline, t3, color=5
	verline, t3p, color=5, lines=2
	verline, t3m, color=5, lines=2
endif

utplot, tb, median(btot, 30), base, ytitle='|B|', timerange=[anytim(utb[0],/atime),anytim(utb[n_elements(utb)-1],/atime) ], /xs, yr=[0,10],$
	xmargin =[10, 1], ymargin=[5,0], /ys
if ~keyword_set(no_lines) then begin
	horline, mean(btot)
	;verline, pret, color=7
	verline, t1, color=3
	verline, t1p, color=3, lines=2
	verline, t1m, color=3, lines=2
	verline, t2, color=4
	verline, t2p, color=4, lines=2
	verline, t2m, color=4, lines=2
	verline, t3, color=5
	verline, t3p, color=5, lines=2
	verline, t3m, color=5, lines=2
endif

;xtickname=[' ',' ',' ',' ',' ', ' ', ' '], /nolabel, xmargin =[10, 1], ymargin=[0,3], charsize=2.5, psym=-1, pos=[0.1, 0.666667, 0.97, 0.95], yr=[1, 300.0], /ystyle, color=2


end

