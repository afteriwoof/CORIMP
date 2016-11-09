; Created	15-09-11	from gather_gail_all.pro to put all the images (C2 and C3) on one plot.

; INPUTS	plot_savs	-	the list of plots_*.sav


pro gather_gail_plots, plot_savs, out_dir

window, xs=1024, ys=1024

;restore,'c2mask.sav'
;restore,'c3mask.sav'

count=0
c2flag = 0
c3flag = 0

for i=0,n_elements(plot_savs)-1 do begin

	loadct, 0
	restore, plot_savs[i]

	if in.i3_instr eq 'c2' || in.i3_instr eq 'C2' then begin
		instr='C2'
		resc2 = res
		xf_outc2 = xf_out
		yf_outc2 = yf_out
	endif
	if in.i4_instr eq 'c3' || in.i4_instr eq 'C3' then instr='C3'


	case instr of
	'C2':	begin
		case c3flag of
		0:	plot_image,da,pos=[0.35,0.35,0.65,0.65]
		1:	oplot_image,da
		endcase
		draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size
		c2flag = 1
		current_instr = 0
		dac2 = da
		inc2 = in
		end
	'C3':	begin
		tvscl,da
		;set_line_color
		;draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size, color=3,/device
		;pause
		if c2flag eq 1 then begin
			oplot_image,dac2
			set_line_color
			if c2_replot eq 1 then begin
				plots, resc2[0,*], resc2[1,*], psym=3, color=2
                        	plots, xf_outc2, yf_outc2, psym=1, color=3
			endif	
			draw_circle, inc2.xcen, inc2.ycen, inc2.rsun/inc2.pix_size
		endif
		c3flag = 1
		current_instr = 1
		end
	endcase

		
	;legend, strmid(in_das[i],strpos(in_das[i],'in_da_')+6,12),/left,/device,box=0,charsize=2
	case current_instr of
	0:	xyouts, -1100,2100,'C2: '+strmid(plot_savs[i],strpos(plot_savs[i],'plots_')+6,12),charsize=2
	1:	begin
		xyouts, -1100,2000,'C3: '+strmid(plot_savs[i],strpos(plot_savs[i],'plots_')+6,12),charsize=2
		if exist(date) eq 1 then xyouts, -1100,2100,'C2: '+date,charsize=2
		end
	endcase
	
	date = strmid(plot_savs[i],strpos(plot_savs[i],'plots_')+6,12)
	
	;case strmid(in_das[i],strpos(in_das[i],'in_da_')+20,2) of
	;	'C2':	tvscl, sigrange(da*c2mask,/use_all)
	;	'C3':	tvscl, sigrange(da*c3mask,/use_all)
	;endcase


	if (i-count) lt n_elements(plot_savs) then begin
		test_date = strmid(plot_savs[i-count],strpos(plot_savs[i-count],'plots_')+6,12)
		if test_date eq date then begin
			c2_replot = 1
			restore, plot_savs[i-count]
			set_line_color
			if current_instr eq 0 then begin
				plots, res[0,*], res[1,*], psym=3, color=2
				plots, xf_out, yf_out, psym=1, color=3
			endif else begin
				plots, res[0,*], res[1,*], psym=3, color=2, /device
                                plots, xf_out, yf_out, psym=1, color=3, /device
			endelse
		endif else begin
			c2_replot = 0
			;legend, 'No CME detections', /right, /device, box=0, charsize=2
			xyouts, 1500, 2500, 'No CME detections', charsize=2
			count+=1
		endelse
	endif else begin
		legend, 'No CME detections', /right, /device, box=0, charsize=2
	endelse

	;case strmid(in_das[i],strpos(in_das[i],'in_da_')+20,2) of
	;'C2':	x2png, out_dir+'/'+strmid(in_das[i],strpos(in_das[i],'in_da_')+6,12)+'_C2.png'
	;'C3':	x2png, out_dir+'/'+strmid(in_das[i],strpos(in_das[i],'in_da_')+6,12)+'_C3.png'
	;endcase

	x2png, out_dir+'/'+strmid(plot_savs[i],strpos(plot_savs[i],'plots_')+6,12)+'.png'

endfor


end
