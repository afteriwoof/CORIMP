; Created:	2013-03-28	from gather_gail_detections_inset_all.pro to apply to stereo cor images.

; Last edited:	
;	

; INPUTS	fls_in		-	the list of fits files used in the detections.
;		dets_fls_in	-	the list of dets_*.sav
;		datetimes	-	the edited yyyymmdd_hhmmss list read in from the /cme_profs/*txt files.


pro gather_detections_inset_all_stereo, fls_in, dets_fls_in, datetimes, angs, out_dir, map=map, old_data=old_data, debug=debug, behind=behind

!p.charsize=1
!p.charthick=1
!p.thick=1

str_count = 23
fls = fls_in
dets_fls = dets_fls_in

if keyword_set(behind) then C2_thr_inner = 4.5 else C2_thr_inner = 3d
if keyword_set(behind) then C2_thr_outer = 14d else C2_thr_outer = 14d

in_times = strmid(file_basename(fls), str_count, 15)
dets_times = strmid(file_basename(dets_fls), 5, 15)

fls_start = where(in_times eq min(datetimes))
fls_end = where(in_times eq max(datetimes))
fls = fls[fls_start:fls_end]
in_times = strmid(file_basename(fls), str_count, 15)

if exist(cor1_fls) then delvar, cor1_fls
if exist(cor2_fls) then delvar, cor2_fls

; prep the files for scaling the images
if ~keyword_set(old_data) then str_cor = 0 else str_cor = 25
for i=0,n_elements(fls)-1 do begin & $
	test_fl = strmid(file_basename(fls[i]),str_cor,4) & $
	;if keyword_set(debug)
	;	print, 'file_basename(fls[i]) ', file_basename(fls[i])
	;	print, 'test_fl ', test_fl
	;endif
	case test_fl of & $
	'cor1':	begin & $
		if exist(cor1_fls) then cor1_fls = [cor1_fls,i] else cor1_fls = i & $
		end & $
	'cor2':	begin & $
		if exist(cor2_fls) then cor2_fls = [cor2_fls,i] else cor2_fls = i & $
		end & $
	endcase & $
endfor

if ~exist(cor1_fls) OR ~exist(cor2_fls) then goto, jump1
mreadfits_corimp,fls[c3_fls],in_c3,da_c3, /quiet
mreadfits_corimp,fls[c2_fls],in_c2,da_c2, /quiet
mreadfits_corimp, fls, in, da, /quiet

if n_elements(out_dir) eq 0 then out_dir='.'

; in case it crosses 0/360 line
if keyword_set(debug) then begin
	;print, 'angs', angs
	print, 'pmm, angs (initial) '
	pmm, angs
endif
angs += 90 mod 360 ;shifting to solar north
if keyword_set(debug) then begin
	print, 'pmm, angs (shifted) '
	pmm, angs
endif
;if max(angs) - min(angs) lt 0 then begin
;	temp_angs = angs+180
;	min_angs = min(temp_angs) - 180
;        max_angs = max(temp_angs) - 180
;        if min_angs lt 0 then min_angs += 360
;endif else begin
;        min_angs = min(angs)
;        max_angs = max(angs)
;endelse
if min(angs) le 1 AND max(angs) ge 359 then begin
	ind_min = min(where(angs eq min(angs)))
	ind_max = max(where(angs eq max(angs)))
	new_angs = [angs[ind_min:n_elements(angs)-1],angs[0:ind_max]]
	new_fls = [fls[ind_min:n_elements(angs)-1],fls[0:ind_max]]
	new_dets_fls = [dets_fls[ind_min:n_elements(angs)-1],dets_fls[0:ind_max]]
	angs = new_angs
	fls = new_fls
	dets_fls = new_dets_fls
	delvarx, new_angs, new_fls, new_dets_fls
endif
min_angs = angs[0]
max_angs = angs[n_elements(angs)-1]
polrec, 515, min_angs, x1, y1, /degrees
polrec, 515, max_angs, x2, y2, /degrees
if keyword_set(debug) then begin
	print, 'pmm, angs (final) '
	pmm, angs
	print, 'min_angs ', min_angs
	print, 'max_angs ', max_angs
	print, 'x1, y1 ', x1, y1
	print, 'x2, y2 ', x2, y2
endif


window, xs=1024, ys=1024

; initialise movie array
mov_arr = dblarr(512,512,n_elements(fls))

count=0
c2flag = 0
c3flag = 0
c2_replot = 0

; Get the masked off region of the congrid-ed c2 image ready for insetting to c3
imc2 = da_c2[*,*,0]
inc2 = in_c2[0]
inc3 = in_c3[0]
temp_mask = bytarr(size(imc2,/dim))
temp_mask[*,*] = 1
temp_mask = rm_inner_corimp(temp_mask, inc2, thr=2.2, fill=0)
temp_mask = rm_outer_corimp(temp_mask, inc2, thr=6., fill=0)
imc2 = congrid(imc2,inc2.naxis1/(inc3.pix_size/inc2.pix_size),inc2.naxis1/(inc3.pix_size/inc2.pix_size))
temp_mask = congrid(temp_mask,inc2.naxis1/(inc3.pix_size/inc2.pix_size),inc2.naxis1/(inc3.pix_size/inc2.pix_size))


for i=0,n_elements(fls)-1 do begin

	if keyword_set(debug) then print, '********  i: ', i, '  ********'
	if ~keyword_set(old_data) then instr = strmid(file_basename(fls[i]),0,2) else instr=strmid(file_basename(fls[i]),25,2)
	; making sure it's not just a case-sensitive error
	if instr eq 'C2' then instr='c2'
        if instr eq 'C3' then instr='c3'

	; condition for calling the following C3 image if the first one is C2
	if i eq 0 AND instr eq 'c2' then begin
		if keyword_set(debug) then print, 'First image is C2'
		inc3 = in_c3[i]
		imc3 = da_c3[*,*,i]
		if ~keyword_set(old_data) then imc3 = (imc3>100.)<60000.
                imc3 = hist_equal(imc3,percent=0.1)
                get_ht_pa_2d_corimp, inc3.naxis1, inc3.naxis2, inc3.crpix1, inc3.crpix2, pix_size=inc3.pix_size/inc3.rsun, x, y,ht,pa
                fov = where(ht ge C3_thr_inner and ht lt C3_thr_outer, comp=nfov)
                ;imc3[nfov] = mean(imc3[fov],/nan)
                imc3[nfov] = max(imc3)
		c3flag = 1
	endif
	if i eq 0 AND instr eq 'c3' then begin
		if keyword_set(debug) then print, 'First image is C3'
		inc2 = in_c2[i]
		imc2 = da_c2[*,*,i]
		;if ~keyword_set(old_data) then imc2 = (imc2>100.)<60000.
                ;if max(imc2) gt min(imc2) then imc2 = hist_equal(imc2, percent=0.1)
                ;get_ht_pa_2d_corimp, inc2.naxis1, inc2.naxis2, inc2.crpix1, inc2.crpix2, pix_size=inc2.pix_size/inc2.rsun, x, y,ht,pa
		;fov = where(ht ge C2_thr_inner and ht lt C2_thr_outer, comp=nfov)
                ;imc2[nfov] = mean(imc2[fov],/nan)
                ;imc2[nfov] = 0;max(imc2)
		c2flag = 1
	endif

	if in[i].xcen le 0 then in[i].xcen=in[i].crpix1
	if in[i].ycen le 0 then in[i].ycen=in[i].crpix2
	
	loadct, 0
	test = where(dets_times eq in_times[i])
	if test ne [-1] then begin
		dets_instr = strmid(file_basename(dets_fls[test]),21,2)
		case dets_instr of
		'C2':begin
			dets_check_C2 = 1
                        dets_check_C3 = 0
                        restore, dets_fls[where(dets_times eq in_times[i])]
                        c2res = dets.edges
                        c2xf_out = dets.front[0,*]
                        c2yf_out = dets.front[1,*]
		     end
		'C3':begin
			dets_check_C3 = 1
			dets_check_C2 = 0
			restore, dets_fls[where(dets_times eq in_times[i])]
			c3res = dets.edges
			c3xf_out = dets.front[0,*]
			c3yf_out = dets.front[1,*]
                     end
		endcase
	endif else begin
		dets_check_C2 = 0
		dets_check_C3 = 0
	endelse

	;if dets_check_c3 eq 1 then print, 'C3 detections to be plotted: ', dets_fls[test]
	;if dets_check_C2 eq 1 then print, 'C2 detections to be plotted: ', dets_fls[test]

	case instr of
	'c2':	begin
		if keyword_set(debug) then print, 'instr is C2'
		; code the inset of C2 into the C3 image
		inc2 = in[i]
		imc2 = da[*,*,i]
		;if ~keyword_set(old_data) then imc2 = (imc2>10000.)<50000.
		if ~keyword_set(old_data) then imc2 = (imc2>100.)<60000.
		if max(imc2) gt min(imc2) then imc2 = hist_equal(imc2, percent=0.1)
		get_ht_pa_2d_corimp, inc2.naxis1, inc2.naxis2, inc2.crpix1, inc2.crpix2, pix_size=inc2.pix_size/inc2.rsun, x, y,ht,pa
		fov = where(ht ge C2_thr_inner and ht lt C2_thr_outer, comp=nfov)
		;imc2[nfov] = mean(imc2[fov],/nan)
		imc2[nfov] = 0;max(imc2)
		;imc2 = fmedian(imc2,6,6)
		if c3flag eq 1 then begin
			if keyword_set(debug) then print, 'C2: c3flag eq 1'
			imc2 = congrid(imc2,inc2.naxis1/(inc3.pix_size/inc2.pix_size),inc2.naxis1/(inc3.pix_size/inc2.pix_size))
			sz_imc2 = size(imc2,/dim)
			ind_imc2 = where(temp_mask eq 1)
			imc3_inset = imc3[(inc3.crpix1-sz_imc2[0]/2.):(inc3.crpix1+sz_imc2[0]/2.)-1, (inc3.crpix2-sz_imc2[1]/2.):(inc3.crpix2+sz_imc2[1]/2.)-1]
			if ind_imc2 ne [-1] then imc3_inset[ind_imc2] = imc2[ind_imc2]
			imc3[(inc3.crpix1-sz_imc2[0]/2.):(inc3.crpix1+sz_imc2[0]/2.)-1, (inc3.crpix2-sz_imc2[1]/2.):(inc3.crpix2+sz_imc2[1]/2.)-1] = imc3_inset
			if keyword_set(map) then begin
				index2map, inc3, imc3, mapc3
				plot_map, mapc3, /limb
			endif else begin
				tv, imc3
				if keyword_set(debug) then pause
				set_line_color
				plots, [in[i].crpix1,in[i].crpix1+x1], [in[i].crpix2, in[i].crpix2+y1], line=0, color=5, thick=2, /device
				plots, [in[i].crpix1,in[i].crpix1+x2], [in[i].crpix2, in[i].crpix2+y2], line=0, color=5, thick=2, /device
				if keyword_set(debug) then pause
				if exist(prev_c3res) then begin
					set_line_color
					plots, prev_c3res[0,*], prev_c3res[1,*], psym=3, color=2, /device
		                        plots, prev_c3xf_out, prev_c3yf_out, psym=1, color=3, /device
					delvarx, prev_c3res, prev_c3xf_out, prev_c3yf_out
					if keyword_set(debug) then pause
				endif
			endelse
		endif else begin
			if keyword_set(debug) then print, 'C2: c3flag eq 0'
			tv, imc2
			if keyword_set(debug) then pause
		endelse
		c2flag = 1
		current_instr = 0
		imc2 = da[*,*,i]
		inc2 = in[i]
		end
	'c3':	begin
		if keyword_set(debug) then print, 'instr is C3'
		inc3 = in[i]
		imc3 = da[*,*,i]
		;if ~keyword_set(old_data) then imc3 = (imc3>10000.)<50000.
		if ~keyword_set(old_data) then imc3 = (imc3>100.)<60000.
		imc3 = hist_equal(imc3,percent=0.1)
		get_ht_pa_2d_corimp, inc3.naxis1, inc3.naxis2, inc3.crpix1, inc3.crpix2, pix_size=inc3.pix_size/inc3.rsun, x, y,ht,pa
		fov = where(ht ge C3_thr_inner and ht lt C3_thr_outer, comp=nfov)
		;imc3[nfov] = mean(imc3[fov],/nan)
		imc3[nfov] = max(imc3)
;		case c2flag of
;		0:	begin
;			if keyword_set(debug) then print, 'C3: c2flag eq 0'
;			if keyword_set(map) then begin
;				index2map, inc3, imc3, mapc3
;				plot_map, mapc3, /limb
;			endif else begin
;				tv,imc3
;				if keyword_set(debug) then pause
;				set_line_color
 ;                               plots, [in[i].crpix1,in[i].crpix1+x1], [in[i].crpix2, in[i].crpix2+y1], line=0, color=5, thick=2, /device
  ;                              plots, [in[i].crpix1,in[i].crpix1+x2], [in[i].crpix2, in[i].crpix2+y2], line=0, color=5, thick=2, /device
;				if keyword_set(debug) then pause
;			endelse
;			end
;		1:	begin	
			if keyword_set(debug) then print, 'C3: c2flag eq 1'
			if c2flag eq 1 then begin
				if keyword_set(debug) then print, 'C3: c3flag eq 0'
				if ~keyword_set(old_data) then imc2 = (imc2>100.)<60000.
		                if max(imc2) gt min(imc2) then imc2 = hist_equal(imc2, percent=0.1)
		                get_ht_pa_2d_corimp, inc2.naxis1, inc2.naxis2, inc2.crpix1, inc2.crpix2, pix_size=inc2.pix_size/inc2.rsun, x, y,ht,pa
		                fov = where(ht ge C2_thr_inner and ht lt C2_thr_outer, comp=nfov)
		                ;imc2[nfov] = mean(imc2[fov],/nan)
		                imc2[nfov] = 0;max(imc2)
				imc2 = congrid(imc2,inc2.naxis1/(inc3.pix_size/inc2.pix_size),inc2.naxis1/(inc3.pix_size/inc2.pix_size))
				sz_imc2 = size(imc2, /dim)
				ind_imc2 = where(temp_mask eq 1)
			endif
			imc3_inset = imc3[(inc3.crpix1-sz_imc2[0]/2.):(inc3.crpix1+sz_imc2[0]/2.)-1, (inc3.crpix2-sz_imc2[1]/2.):(inc3.crpix2+sz_imc2[1]/2.)-1]
			if ind_imc2 ne [-1] then imc3_inset[ind_imc2] = imc2[ind_imc2]
			imc3[(inc3.crpix1-sz_imc2[0]/2.):(inc3.crpix1+sz_imc2[0]/2.)-1, (inc3.crpix2-sz_imc2[1]/2.):(inc3.crpix2+sz_imc2[1]/2.)-1] = imc3_inset
			if keyword_set(map) then begin
				index2map, inc3, imc3, mapc3
				plot_map,mapc3,/limb,/notit
			endif else begin
				tv, imc3
				save, imc3, f='temp_imc3.sav'
				if keyword_set(debug) then pause
				set_line_color
                                plots, [in[i].crpix1,in[i].crpix1+x1], [in[i].crpix2, in[i].crpix2+y1], line=0, color=5, thick=2, /device
                                plots, [in[i].crpix1,in[i].crpix1+x2], [in[i].crpix2, in[i].crpix2+y2], line=0, color=5, thick=2, /device
				if keyword_set(debug) then pause
				if exist(prev_c2res) then begin
					set_line_color
					plots, prev_c2res[0,*]/((inc3.pix_size/inc2.pix_size))+inc3.crpix1-(inc3.crpix1/((inc3.pix_size/inc2.pix_size))), $
	        	                        prev_c2res[1,*]/((inc3.pix_size/inc2.pix_size))+inc3.crpix2-(inc3.crpix2/((inc3.pix_size/inc2.pix_size))), psym=3, color=2, /device
		                        plots, prev_c2xf_out/((inc3.pix_size/inc2.pix_size))+inc3.crpix1-(inc3.crpix1/((inc3.pix_size/inc2.pix_size))), $
		                                prev_c2yf_out/((inc3.pix_size/inc2.pix_size))+inc3.crpix2-(inc3.crpix2/((inc3.pix_size/inc2.pix_size))), psym=1, color=3, /device
					delvarx, prev_c2res, prev_c2xf_out, prev_c2_yfout
					if keyword_set(debug) then pause
				endif
				
			endelse
			c2flag = 0
;			end
;		endcase
		c3flag = 1
		current_instr = 1
		end
	endcase

	if dets_check_c2 eq 1 then begin
                if keyword_set(map) then begin
			set_line_color
	                plots, c2res[0,*]/((inc3.pix_size/inc2.pix_size))+inc3.crpix1-(inc3.crpix1/((inc3.pix_size/inc2.pix_size))), $
                                c2res[1,*]/((inc3.pix_size/inc2.pix_size))+inc3.crpix2-(inc3.crpix2/((inc3.pix_size/inc2.pix_size))), psym=3, color=2
                        plots, c2xf_out/((inc3.pix_size/inc2.pix_size))+inc3.crpix1-(inc3.crpix1/((inc3.pix_size/inc2.pix_size))), $
                                c2yf_out/((inc3.pix_size/inc2.pix_size))+inc3.crpix2-(inc3.crpix2/((inc3.pix_size/inc2.pix_size))), psym=1, color=3
                endif else begin
			set_line_color
                        plots, c2res[0,*]/((inc3.pix_size/inc2.pix_size))+inc3.crpix1-(inc3.crpix1/((inc3.pix_size/inc2.pix_size))), $
                                c2res[1,*]/((inc3.pix_size/inc2.pix_size))+inc3.crpix2-(inc3.crpix2/((inc3.pix_size/inc2.pix_size))), psym=3, color=2, /device
                        plots, c2xf_out/((inc3.pix_size/inc2.pix_size))+inc3.crpix1-(inc3.crpix1/((inc3.pix_size/inc2.pix_size))), $
                                c2yf_out/((inc3.pix_size/inc2.pix_size))+inc3.crpix2-(inc3.crpix2/((inc3.pix_size/inc2.pix_size))), psym=1, color=3, /device
                endelse
		prev_c2res = c2res
		prev_c2xf_out = c2xf_out
		prev_c2yf_out = c2yf_out
        endif
	
	if dets_check_c3 eq 1 then begin
		if keyword_set(map) then begin
			set_line_color
                        plots, c3res[0,*], c3res[1,*], psym=3, color=2
                        plots, c3xf_out, c3yf_out, psym=1, color=3
                endif else begin
			set_line_color
                        plots, c3res[0,*], c3res[1,*], psym=3, color=2, /device
                        plots, c3xf_out, c3yf_out, psym=1, color=3, /device
                endelse
		prev_c3res = c3res
		prev_c3xf_out = c3xf_out
		prev_c3yf_out = c3yf_out
	endif

	if keyword_set(map) then begin
		if exist(inc2) then xyouts, 10,1000,'C2: '+inc2.date_obs, charsize=2
	        if exist(inc3) then xyouts, 10,970,'C3: '+inc3.date_obs, charsize=2
	endif else begin
       		if exist(inc2) then xyouts, 10,1000,'C2: '+inc2.date_obs, charsize=2, charthick=2, color=0, /device
       		if exist(inc3) then xyouts, 10,970,'C3: '+inc3.date_obs, charsize=2, charthick=2, color=0, /device
	endelse
	if ~keyword_set(map) then begin
		if exist(inc3) then draw_circle, inc3.xcen, inc3.ycen, inc3.rsun/inc3.pix_size, /device, color=0 else draw_circle, inc2.xcen, inc2.ycen, inc2.rsun/inc2.pix_size, /device, color=0
	endif

	date = strmid(file_basename(fls[i]),strpos(file_basename(fls[i]),'lasco_soho_')+20,8)+':'+$
		strmid(file_basename(fls[i]),strpos(file_basename(fls[i]),'lasco_soho_ ')+29+6)


	
	if i ne 0 AND instr ne 'c2' then x2png, out_dir+'/'+strmid(file_basename(fls[i]),strpos(file_basename(fls[i]),'lasco_soho_')+20,15)+'.png', /silent
	;save, imc3, f='temp.sav'

	mov_arr[*,*,i] = congrid(tvrd(),512,512)

	if keyword_set(debug) then pause

endfor

wr_movie, out_dir+'/movie', mov_arr, url='movie/', /delete

jump1:

end
