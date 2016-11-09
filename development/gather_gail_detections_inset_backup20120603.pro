;Created	20120601	from gather_gail_detections.pro to inset the C2 image instead of just overplotting it as a square!


; INPUTS	fls		-	the list of fits files used in the detections.
;		dets_fls	-	the list of dets_*.sav


pro gather_gail_detections_inset, fls_in, dets_fls_in, out_dir

fls = fls_in
dets_fls = dets_fls_in

if n_elements(fls) ne n_elements(dets_fls) then begin & $
        print, 'Number of files do not match dets_fls' & $
        in_times = strmid(file_basename(fls), 9, 15) & $
        dets_times = strmid(file_basename(dets_fls), 5, 15) & $
        fls_loc = where(in_times eq dets_times[0]) & $
        for i=1,n_elements(dets_times)-1 do begin & $
                fls_loc = [fls_loc, where(in_times eq dets_times[i])] & $
        endfor & $
        fls = fls[fls_loc] & $
endif

if exist(c2_fls) then delvar, c2_fls
if exist(c3_fls) then delvar, c3_fls

; prep the files for scaling the images
for i=0,n_elements(dets_fls)-1 do begin & $
	test_fl = strmid(file_basename(fls[i]),25,2) & $
	case test_fl of & $
	'c2':	begin & $
		if exist(c2_fls) then c2_fls = [c2_fls,i] else c2_fls = i & $
		end & $
	'c3':	begin & $
		if exist(c3_fls) then c3_fls = [c3_fls,i] else c3_fls = i & $
		end & $
	endcase & $
endfor

mreadfits_corimp,fls[c2_fls],in_c2,da_c2
mreadfits_corimp,fls[c3_fls],in_c3,da_c3

mu_c2 = moment(da_c2[where(da_c2 gt 0)],sdev=sdev_c2)
mu_c3 = moment(da_c3[where(da_c3 gt 0)],sdev=sdev_c3)

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
		; code the inset of C2 into the C3 image
		inc2 = in[i]
		imc2 = da[*,*,i]
		mu_imc2 = moment(imc2[where(imc2 gt 0)],sdev=sdev_imc2)
		minthresh = mu_imc2[0]*0.1
		maxthresh = mu_imc2[0]+4*sdev_imc2
		imc2 = (((imc2<maxthresh)>minthresh)-minthresh)*255/(maxthresh-minthresh)
		if c3flag eq 1 then begin
			imc2 = congrid(imc2,inc2.naxis1/(inc3.pix_size/inc2.pix_size),inc2.naxis1/(inc3.pix_size/inc2.pix_size))
			sz_imc2 = size(imc2,/dim)
			ind_imc2 = where(imc2 gt 0)
			imc3_inset = imc3[(inc3.crpix1-sz_imc2[0]/2.):(inc3.crpix1+sz_imc2[0]/2.)-1, (inc3.crpix2-sz_imc2[1]/2.):(inc3.crpix2+sz_imc2[1]/2.)-1]
			imc3_inset[ind_imc2] = imc2[ind_imc2]
			imc3[(inc3.crpix1-sz_imc2[0]/2.):(inc3.crpix1+sz_imc2[0]/2.)-1, (inc3.crpix2-sz_imc2[1]/2.):(inc3.crpix2+sz_imc2[1]/2.)-1] = imc3_inset
			tv, imc3
		endif else begin
			tv, imc2
		endelse
		c2flag = 1
		current_instr = 0
		dac2 = da[*,*,i]
		inc2 = in[i]
		end
	'C3':	begin
		inc3 = in[i]
		imc3 = da[*,*,i]
		mu_imc3 = moment(imc3[where(imc3 gt 0)],sdev=sdev_imc3)
		minthresh = mu_imc3[0]*0.2
		maxthresh = mu_imc3[0]+4*sdev_imc3
		imc3 = (((imc3<maxthresh)>minthresh)-minthresh)*255/(maxthresh-minthresh)
		case c2flag of
		0:	tv,imc3
		1:	begin	
			if c3flag eq 0 then begin
				imc2 = congrid(imc2,inc2.naxis1/(inc3.pix_size/inc2.pix_size),inc2.naxis1/(inc3.pix_size/inc2.pix_size))
				sz_imc2 = size(imc2, /dim)
				ind_imc2 = where(imc2 gt 0)
			endif
			imc3_inset = imc3[(inc3.crpix1-sz_imc2[0]/2.):(inc3.crpix1+sz_imc2[0]/2.)-1, (inc3.crpix2-sz_imc2[1]/2.):(inc3.crpix2+sz_imc2[1]/2.)-1]
                        imc3_inset[ind_imc2] = imc2[ind_imc2]
			imc3[(inc3.crpix1-sz_imc2[0]/2.):(inc3.crpix1+sz_imc2[0]/2.)-1, (inc3.crpix2-sz_imc2[1]/2.):(inc3.crpix2+sz_imc2[1]/2.)-1] = imc3_inset
			tv, imc3
			set_line_color
			if c2flag eq 1 then begin
			;	oplot_image,dac2
				set_line_color
				if c2_replot eq 1 then begin
					plots, c2res[0,*]/((inc3.pix_size/inc2.pix_size))+inc3.crpix1-(inc3.crpix1/((inc3.pix_size/inc2.pix_size))), $
	                                        c2res[1,*]/((inc3.pix_size/inc2.pix_size))+inc3.crpix2-(inc3.crpix2/((inc3.pix_size/inc2.pix_size))), psym=3, color=2, /device
        	                        plots, c2xf_out/((inc3.pix_size/inc2.pix_size))+inc3.crpix1-(inc3.crpix1/((inc3.pix_size/inc2.pix_size))), $
                 	                       c2yf_out/((inc3.pix_size/inc2.pix_size))+inc3.crpix2-(inc3.crpix2/((inc3.pix_size/inc2.pix_size))), psym=1, color=3, /device
				endif	
			endif
			end
		endcase
		c3flag = 1
		current_instr = 1
		plots, res[0,*], res[1,*], psym=3, color=2, /device
		plots, xf_out, yf_out, psym=1, color=3, /device
		end
	endcase

		
;	case current_instr of
;	0:	xyouts, 10,1000,'C2: '+strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+5,8)+':'+$
;			strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+14,6),charsize=2, /device
;	1:	begin
;		xyouts, 10,900,'C3: '+strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+5,8)+':'+$
;			strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+14,6),charsize=2, /device
;		if exist(date) eq 1 then xyouts, 10,900,'C2: '+date,charsize=2, /device
;		end
;	endcase

        if exist(inc2) then xyouts, 10,1000,'C2: '+inc2.date_obs, charsize=2, /device
        if exist(inc3) then xyouts, 10,970,'C3: '+inc3.date_obs, charsize=2, /device
	
	if exist(inc3) then draw_circle, inc3.xcen, inc3.ycen, inc3.rsun/inc3.pix_size, /device else draw_circle, inc2.xcen, inc2.ycen, inc2.rsun/inc2.pix_size, /device
	
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
				c2res=res
				c2xf_out = xf_out
				c2yf_out = yf_out
				if c3flag eq 1 then begin
					plots, res[0,*]/((inc3.pix_size/inc2.pix_size))+inc3.crpix1-(inc3.crpix1/((inc3.pix_size/inc2.pix_size))), $
						res[1,*]/((inc3.pix_size/inc2.pix_size))+inc3.crpix2-(inc3.crpix2/((inc3.pix_size/inc2.pix_size))), psym=3, color=2, /device
					plots, xf_out/((inc3.pix_size/inc2.pix_size))+inc3.crpix1-(inc3.crpix1/((inc3.pix_size/inc2.pix_size))), $
						yf_out/((inc3.pix_size/inc2.pix_size))+inc3.crpix2-(inc3.crpix2/((inc3.pix_size/inc2.pix_size))), psym=1, color=3, /device
					plots, c3res[0,*], c3res[1,*], psym=3, color=2, /device
					plots, c3xf_out, c3yf_out, psym=1, color=3, /device
				endif
			endif else begin
				c3res = res
				c3xf_out = xf_out
				c3yf_out = yf_out
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
