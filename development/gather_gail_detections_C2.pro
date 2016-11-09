;Created	2012-07-20	to take in only the C2 detections.

; INPUTS	fls		-	the list of fits files used in the detections.
;		dets_fls	-	the list of dets_*.sav


pro gather_gail_detections_C2, c2_fls, dets_fls_in, out_dir, map=map


fls_in = c2_fls
dets_fls = dets_fls_in

if n_elements(fls_in) ne n_elements(dets_fls) then begin & $
        print, 'Number of files do not match dets_fls' & $
        in_times = strmid(file_basename(fls_in), 9, 15) & $
        dets_times = strmid(file_basename(dets_fls), 5, 15) & $
        fls_loc = where(in_times eq dets_times[0]) & $
        for i=1,n_elements(dets_times)-1 do begin & $
                fls_loc = [fls_loc, where(in_times eq dets_times[i])] & $
        endfor & $
        fls_in = fls_in[fls_loc] & $
endif

mreadfits_corimp,c2_fls,in,da

mu_c2 = moment(da[where(da gt 0)],sdev=sdev)

if n_elements(out_dir) eq 0 then out_dir='.'

window, xs=1024, ys=1024

;restore,'c2mask.sav'

count=0
c2flag = 0

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

	inc2 = in[i]
	imc2 = da[*,*,i]
	get_ht_pa_2d_corimp, inc2.naxis1, inc2.naxis2, inc2.crpix1, inc2.crpix2, pix_size=inc2.pix_size/inc2.rsun, x, y,ht,pa
	fov = where(ht ge 2.2 and ht lt 5.95, comp=nfov)
	imc2[nfov] = mean(imc2[fov],/nan)
	imc2 = hist_equal(imc2, percent=0.01)
	imc2[nfov] = max(imc2)
	;imc2 = fmedian(imc2,6,6)
	tv, imc2
	dac2 = da[*,*,i]
	inc2 = in[i]
	set_line_color
	if keyword_set(map) then begin
		plots, res[0,*], res[1,*], psym=3, color=2
	        plots, xf_out, yf_out, psym=1, color=3
	endif else begin
		plots, res[0,*], res[1,*], psym=3, color=2, /device
		plots, xf_out, yf_out, psym=1, color=3, /device
	endelse

	if keyword_set(map) then begin
		if exist(inc2) then xyouts, 10,1000,'C2: '+inc2.date_obs, charsize=2
	endif else begin
       		if exist(inc2) then xyouts, 10,1000,'C2: '+inc2.date_obs, charsize=2, color=0, /device
	endelse
	if ~keyword_set(map) then begin
		draw_circle, inc2.xcen, inc2.ycen, inc2.rsun/inc2.pix_size, /device, color=0
	endif
	
	date = strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+5,8)+':'+$
		strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+14,6)

	x2png, out_dir+'/'+strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+5,8)+'_'+$
			strmid(file_basename(dets_fls[i]),strpos(file_basename(dets_fls[i]),'dets_')+14,6)+'_C2.png'


endfor


end
