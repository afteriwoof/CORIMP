; Created	20120419	from gather_gail_plots.pro to put all the images (C2 and C3) on one plot with the current output from the automated routines.

; INPUTS	fls		-	the list of fits files used in the detections.
;		dets_fls	-	the list of dets_*.sav


pro gather_gail_detections, fls, dets_fls, out_dir

if n_elements(fls) ne n_elements(dets_fls) then begin
        print, 'Number of files do not match dets_fls'
        in_times = strmid(file_basename(fls), 9, 15)
        dets_times = strmid(file_basename(dets_fls), 5, 15)
        fls_loc = where(in_times eq dets_times[0])
        for i=1,n_elements(dets_times)-1 do begin
                fls_loc = [fls_loc, where(in_times eq dets_times[i])]
        endfor
        fls = fls[fls_loc]
endif

mreadfits_corimp, fls, in, da

if n_elements(out_dir) eq 0 then out_dir='.'

window, xs=1024, ys=1024

;restore,'c2mask.sav'
;restore,'c3mask.sav'

count=0
c2flag = 0
c3flag = 0

for i=0,n_elements(dets_fls)-1 do begin

	if in[i].xcen le 0 then in[i].xcen=in[i].crpix1
	if in[i].ycen le 0 then in[i].ycen=in[i].crpix2
	
	loadct, 0
	restore, dets_fls[i]
	res = dets.edges
	xf_out = dets.front[0,*]
	yf_out = dets.front[1,*]

	if dets.instr eq 'c2' || dets.instr eq 'C2' then begin
		instr='C2'
		resc2 = res
		xf_outc2 = xf_out
		yf_outc2 = yf_out
	endif
	if dets.instr eq 'c3' || dets.instr eq 'C3' then instr='C3'


	case instr of
	'C2':	begin
		case c3flag of
		0:	plot_image,da[*,*,i],pos=[0.35,0.35,0.65,0.65]
		1:	oplot_image,da[*,*,i]
		endcase
		draw_circle, in[i].xcen, in[i].ycen, in[i].rsun/in[i].pix_size
		c2flag = 1
		current_instr = 0
		dac2 = da[*,*,i]
		inc2 = in[i]
		end
	'C3':	begin
		tvscl,da[*,*,i]
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

		
	case current_instr of
	0:	xyouts, -1100,2100,'C2: '+strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+5,8)+':'+$
			strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+14,6),charsize=2
	1:	begin
		xyouts, -1100,2000,'C3: '+strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+5,8)+':'+$
			strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+14,6),charsize=2
		if exist(date) eq 1 then xyouts, -1100,2100,'C2: '+date,charsize=2
		end
	endcase
	
	date = strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+5,8)+':'+$
			strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+14,6)
	
	;case strmid(in_das[i],strpos(in_das[i],'in_da_')+20,2) of
	;	'C2':	tvscl, sigrange(da[*,*,i]*c2mask,/use_all)
	;	'C3':	tvscl, sigrange(da[*,*,i]*c3mask,/use_all)
	;endcase


	if (i-count) lt n_elements(dets_fls) then begin
		test_date = strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+5,8)+':'+$
			strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+14,6)
		if test_date eq date then begin
			c2_replot = 1
			restore, dets_fls[i-count]
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

	x2png, out_dir+'/'+strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+5,8)+'_'+$
			strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+14,6)+'.png'

endfor


end
