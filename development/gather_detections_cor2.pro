; Created:	2013-05-16	to gather the detections for the cor2 images.

; Last edited:	2013-07-16	to finalise the code for working with newly processed cor2 images.
;	

; INPUTS	fls_in		-	the list of fits files used in the detections.
;		dets_fls_in	-	the list of dets_*.sav
;		datetimes	-	the edited yyyymmdd_hhmmss list read in from the /cme_profs/*txt files.


pro gather_detections_cor2, fls_in, dets_fls_in, datetimes, angs, out_dir, map=map, old_data=old_data, debug=debug, behind=behind

!p.charsize=1
!p.charthick=1
!p.thick=1

str_count = 23
fls = fls_in
dets_fls = dets_fls_in

if keyword_set(behind) then cor2_thr_inner = 4.5 else cor2_thr_inner = 3d
if keyword_set(behind) then cor2_thr_outer = 14d else cor2_thr_outer = 14d

in_times = strmid(file_basename(fls), str_count, 15)
dets_times = strmid(file_basename(dets_fls), 5, 15)

fls_start = where(in_times eq min(datetimes))
fls_end = where(in_times eq max(datetimes))
fls = fls[fls_start:fls_end]
in_times = strmid(file_basename(fls), str_count, 15)

mreadfits_corimp, fls, hdrs, da, /quiet

if n_elements(out_dir) eq 0 then out_dir='.'

; in case it crosses 0/360 line
if keyword_set(debug) then begin
	;print, 'angs', angs
	print, 'pmm, angs (initial) '
	pmm, angs
endif
;angs = (angs+90) mod 360 ;shifting to solar north
if keyword_set(debug) then begin
	print, 'pmm, angs (shifted) '
	pmm, angs
endif

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
polrec, 515, ((min_angs+90) mod 360), x1, y1, /degrees
polrec, 515, ((max_angs+90) mod 360), x2, y2, /degrees
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


for i=0,n_elements(fls)-1 do begin

	if keyword_set(debug) then print, '********  i: ', i, '  ********'
	instr = 'cor2'

	if hdrs[i].xcen le 0 then hdrs[i].xcen=hdrs[i].crpix1
	if hdrs[i].ycen le 0 then hdrs[i].ycen=hdrs[i].crpix2
	
	loadct, 0
	test = where(dets_times eq in_times[i])
	if test ne [-1] then begin
		dets_check = 1
                restore, dets_fls[where(dets_times eq in_times[i])]
                res = dets.edges
                xf_out = dets.front[0,*]
                yf_out = dets.front[1,*]
	endif else begin
		dets_check = 0
	endelse

	in = hdrs[i]
	im = da[*,*,i]
	;if ~keyword_set(old_data) then imc3 = (imc3>10000.)<50000.
	if ~keyword_set(old_data) then im = (temporary(im)>100.)<60000.
	im = hist_equal(temporary(im),percent=0.1)
	get_ht_pa_2d_corimp, in.naxis1, in.naxis2, in.crpix1, in.crpix2, pix_size=in.pix_size/in.rsun, x, y,ht,pa
	fov = where(ht ge cor2_thr_inner and ht lt cor2_thr_outer, comp=nfov)
	;im[nfov] = mean(temporary(im[fov]),/nan)
	im[nfov] = max(im)
	if keyword_set(map) then begin
		index2map, in, im, map
		plot_map,map,/limb,/notit
	endif else begin
		tv, im
		;save, im, f='temp_im.sav'
		if keyword_set(debug) then pause
		set_line_color
                plots, [in.crpix1,in.crpix1+x1], [in.crpix2, in.crpix2+y1], line=0, color=5, thick=2, /device
                plots, [in.crpix1,in.crpix1+x2], [in.crpix2, in.crpix2+y2], line=0, color=5, thick=2, /device
		if keyword_set(debug) then pause
	endelse

	if dets_check eq 1 then begin
                if keyword_set(map) then begin
			set_line_color
	                plots, res[0,*]/((in.pix_size/in.pix_size))+in.crpix1-(in.crpix1/((in.pix_size/in.pix_size))), $
                        res[1,*]/((in.pix_size/in.pix_size))+in.crpix2-(in.crpix2/((in.pix_size/in.pix_size))), psym=3, color=2
                        plots, xf_out/((in.pix_size/in.pix_size))+in.crpix1-(in.crpix1/((in.pix_size/in.pix_size))), $
                        yf_out/((in.pix_size/in.pix_size))+in.crpix2-(in.crpix2/((in.pix_size/in.pix_size))), psym=1, color=3
                endif else begin
			set_line_color
                        plots, res[0,*]/((in.pix_size/in.pix_size))+in.crpix1-(in.crpix1/((in.pix_size/in.pix_size))), $
                        res[1,*]/((in.pix_size/in.pix_size))+in.crpix2-(in.crpix2/((in.pix_size/in.pix_size))), psym=3, color=2, /device
                        plots, xf_out/((in.pix_size/in.pix_size))+in.crpix1-(in.crpix1/((in.pix_size/in.pix_size))), $
                        yf_out/((in.pix_size/in.pix_size))+in.crpix2-(in.crpix2/((in.pix_size/in.pix_size))), psym=1, color=3, /device
                endelse
        endif
	
	if keyword_set(map) then begin
		xyouts, 10,1000,'COR2: '+in.date_obs, charsize=2
	endif else begin
       		xyouts, 10,1000,'COR2: '+in.date_obs, charsize=2, charthick=2, color=0, /device
	endelse
	if ~keyword_set(map) then draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size, /device, color=0 $
		else draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size, /device, color=0

	date = strmid(file_basename(fls[i]),23,8)+':'+$
		strmid(file_basename(fls[i]),32,6)
	
	if i ne 0 then x2png, out_dir+'/'+strmid(file_basename(fls[i]),23,15)+'.png', /silent
	;save, imc3, f='temp.sav'

	mov_arr[*,*,i] = congrid(tvrd(),512,512)

	if keyword_set(debug) then pause

endfor

wr_movie, out_dir+'/movie', mov_arr, url='movie/', /delete

jump1:

end
