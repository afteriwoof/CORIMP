; Created	2012-12-17	to output plot of pa_total to postscript.

; Last edited:	2012-12-18	to overplot the detection stack boxes
;		2013-01-23	to no longer equlaise the histogram of the pa_total, but scale it into 0-25 R_sun range.

pro make_pa_total_plot, pa_total, fname, det_info, r_sun

set_plot, 'ps'

device, xs=20, ys=10, /cm, bits=8, language=2, /portrait, /color, filename=fname, /encapsul

loadct, 13
tvlct, r, g, b, /get
upper_val = 255
i = 255
r[i]=upper_val & g[i]=upper_val & b[i]=upper_val
loadct, 0

my_charsize=1.5
my_charthick=3.5

maxp = max(pa_total)
km_arc = 6.955e8 / (1000.*r_sun)
ind = where(pa_total eq 0)
;pa_total = (float(hist_equal(pa_total>0, per=1, omin=mn, omax=mx, minv=0, maxv=(1000*695.5)*25/km_arc))*254/255.)
pa_total = (float(pa_total)/((1000*695.5)*25/km_arc))*255.
pa_total[ind] = 255

tvlct, r, g, b

plot_image, pa_total, xtit='Position Angle (degrees)', ytit='Time (image no.)', $
	charsize=my_charsize, charthick=my_charthick, xtickintervals=30, color=-1, pos=[0.13,0.18,0.98,0.76]

sz = size(det_info,/dim)
if n_elements(sz) gt 1 then i_end=sz[1]-1 else i_end=0
; clause in case overlaps 0/360 edge
for i=0,i_end do begin
	if det_info[0,i] gt det_info[1,i] then begin
		plots, [det_info[0,i],det_info[0,i]], [det_info[2,i],det_info[3,i]]
        	plots, [det_info[1,i],det_info[1,i]], [det_info[2,i],det_info[3,i]]
		plots, [0,det_info[1,i]], [det_info[2,i],det_info[2,i]]
		plots, [0,det_info[1,i]], [det_info[3,i],det_info[3,i]]
		plots, [det_info[0,i],360], [det_info[2,i],det_info[2,i]]
		plots, [det_info[0,i],360], [det_info[3,i],det_info[3,i]]
	endif else begin
		plots, [det_info[0,i],det_info[0,i]], [det_info[2,i],det_info[3,i]]
		plots, [det_info[1,i],det_info[1,i]], [det_info[2,i],det_info[3,i]]
		plots, [det_info[0,i],det_info[1,i]], [det_info[2,i],det_info[2,i]]
		plots, [det_info[0,i],det_info[1,i]], [det_info[3,i],det_info[3,i]]
	endelse
endfor
maxc = 25
;maxc = maxp*km_arc/(1000.*695.5)

colorbar, pos=[0.38,0.85,0.68,0.89], ncolors=255, minrange=0, maxrange=maxc, /norm, $
	/horizontal, tit='Height '+symbol_corimp('rs',/parenth), charthick=my_charthick, $
	charsize=my_charsize-0.2, color=-1

device, /close_file

set_plot, 'x'

end
