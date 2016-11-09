; Created	20140108	from run_automated_new.pro to have an alert for realtime single image CME detections.


;INPUTS:	fl		- the file to run the detections on, checking in realtime for a CME.
;		out_dir		- the output directory to save the detection output.


; OUTPUTS	pa_slice	- the position angle detection slice that goes into the detection stack for that day.
;		cme_alert	- returns a 1 if a CME has been detected (above the detection threshold) or a 0 otherwise.


;KEYWORDS:	-	old_data	if the data is the old format of dynamics_20100227_000603_c2_soho.fits.gz
;					(as opposed to newest format of c2_lasco_soho_dynamics_20110101_001141.fits.gz).



pro run_automated_realtime_alert, fl, out_dir, cme_alert, pa_slice, gail=gail, stereo=stereo, behind=behind, old_data=old_data, show=show, overwrite=overwrite

; SET DETECTION ALERT THRESHOLD (from detection mask scores etc)
detection_threshold = 3. ;probably too high - based on the normalised percentage score from masks (mask score in mask area).

; initialise
cme_alert = 0

scores = dblarr(n_elements(fl))

count = 0
pa_slice = dblarr(360)

; Assuming no model is input (case of running code on gail)
if ~keyword_set(gail) then loadct, 0

if ~file_exist(out_dir+'/scores.txt') then begin
	openw, lun, out_dir+'/scores.txt', /get_lun
	printf, lun, '# Detection_threshold: '+int2str(detection_threshold)
        printf, lun, '#     SCORE     DATE_TIME       INSTR'
	free_lun, lun
endif

if ~keyword_set(stereo) then begin
	C2_thr_inner = 2.2d
	C2_thr_outer = 6.d
	C3_thr_inner = 5.7d
	C3_thr_outer = 25.d
	str_count = 23
	if keyword_set(old_data) then begin
		C2_thr_inner = 2.2d
		C2_thr_outer = 5.95d
		C3_thr_inner = 5.95d
		C3_thr_outer = 19.5d
		str_count = 9 
	endif
endif else begin
	if keyword_set(behind) then C2_thr_inner = 4.5 else C2_thr_inner = 3d
	if keyword_set(behind) then C2_thr_outer = 14d else C2_thr_outer = 14d
	str_count = 23 ;reading cor2_a_stereo_dynamics_yyyymmdd_hhmmss.fits.gz
endelse

; Read files
da = readfits_corimp(fl[count],in)

if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then instr='C2'
if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then instr='C3'
if in.i4_instr eq 'COR2' || in.i4_instr eq 'cor2' then instr='COR2'
if ~keyword_set(gail) then print, 'instr: ', instr

;if count eq 0 AND ~keyword_set(gail) then begin
;	winx = in.naxis1
;	winy = in.naxis2
;       !p.multi = 0
;        window, xs=winx, ys=winy
;endif

if keyword_set(show) then plot_image, da
da_orig = da

; Set field-of-view limits.
if instr eq 'C2'then begin
	thr_inner = c2_thr_inner
        thr_outer = c2_thr_outer
endif
if instr eq 'C3' then begin
        thr_inner = c3_thr_inner
        thr_outer = c3_thr_outer
endif
if instr eq 'COR2' then begin
        thr_inner = c2_thr_inner
        thr_outer = c2_thr_outer
endif

; Have to remove NaNs
mask_nan = intarr(in.naxis1,in.naxis2)
mask_nan[*,*] = 1
mask_nan = rm_inner_corimp(mask_nan,in,thr=thr_inner)
mask_nan = rm_outer_corimp(mask_nan,in,thr=thr_outer)
fov = where(mask_nan eq 1)
temp = da[fov]
nans = replicate(!values.f_nan,in.naxis1,in.naxis2)
if where(finite(da[fov]) eq finite(nans[fov])) ne [-1] then begin
	temp[where(finite(da[fov]) eq finite(nans[fov]))] = median(da[fov])
	da[fov] = temp
endif

;Assign file date+time
in.filename = strmid(file_basename(fl[count]), str_count, 15)
if ~keyword_set(gail) then print, 'in.filename ', in.filename

; Correct for structure mistakes
if keyword_set(stereo) AND tag_exist(in,'instrume') eq 0 then begin
	in = add_tag(in, in.telescop, 'instrume')
	in.instrume = 'SECCHI'
endif

if tag_exist(in, 'xcen') eq 0 then begin
	in = add_tag(in, in.crpix1, 'xcen')
	in = add_tag(in, in.crpix2, 'ycen')
endif

if tag_exist(in, 'crpix1') eq 0 then begin
	in = add_tag(in, in.xcen, 'crpix1')
	in = add_tag(in, in.ycen, 'crpix2')
endif
if in.xcen le 0 then in.xcen = in.crpix1
if in.ycen le 0 then in.ycen = in.crpix2

; Reflect data in and out of occulted field-of-view.
if ~keyword_set(no_reflect) then begin
	if ~keyword_set(gail) then print, 'Reflecting data in/out of field-of-view.'
	da=reflect_inner_outer(in,da,thr_inner,thr_outer, stereo=stereo, behind=behind)
endif
if keyword_set(show) then plot_image, da

;Multiscale decomposition
canny_atrous2d, da, modgrad, alpgrad, rows=rows, columns=columns

if ~keyword_set(no_reflect) then begin
	da = da[96:1119, 96:1119]
	modgrad = modgrad[96:1119, 96:1119, *]
	alpgrad = alpgrad[96:1119, 96:1119, *]
	rows = rows[96:1119, 96:1119, *]
	columns = columns[96:1119, 96:1119, *]
endif

sz = size(da, /dim)

if ~keyword_set(gail) then print, 'Using scales 3, 4, 5, and 6 of decomposition.'

if ~keyword_set(gail) then print, 'Removing inner/outer occulters'
for k=0,3 do begin & $
	modgrad[*,*,k+3]=rm_inner_corimp(modgrad[*,*,k+3],in,dr_px,thr=thr_inner) & $
        alpgrad[*,*,k+3]=rm_inner_corimp(alpgrad[*,*,k+3],in,dr_px,thr=thr_inner) & $
        modgrad[*,*,k+3]=rm_outer_corimp(modgrad[*,*,k+3],in,dr_px,thr=thr_outer) & $
        alpgrad[*,*,k+3]=rm_outer_corimp(alpgrad[*,*,k+3],in,dr_px,thr=thr_outer) & $
        rows[*,*,k+3] = rm_inner_corimp(rows[*,*,k+3],in,dr_px,thr=thr_inner) & $
        rows[*,*,k+3] = rm_outer_corimp(rows[*,*,k+3],in,dr_px,thr=thr_outer) & $
        columns[*,*,k+3]=rm_inner_corimp(columns[*,*,k+3],in,dr_px,thr=thr_inner) & $
        columns[*,*,k+3]=rm_outer_corimp(columns[*,*,k+3],in,dr_px,thr=thr_outer) & $
endfor

; Not removing pylon because of cases when SOHO is in keyhole!

da = rm_inner_corimp(da, in, dr_px, thr=thr_inner)
da = rm_outer_corimp(da, in, dr_px, thr=thr_outer)
if keyword_set(show) then plot_image, da
;if in.instrume eq 'SWAP' then da = da_orig

;Non-maxima suppression
edges = wtmm(modgrad[*,*,3:6], rows[*,*,3:6], columns[*,*,3:6])
if keyword_set(show) then plot_image, edges[*,*,2]

if ~keyword_set(non_dynamic) then begin
	if ~keyword_set(gail) then print, 'Running cme_detection_mask_corimp_dynamic_thr.pro'
	; this code specifies the sdev_factor and the no_contours
	cme_detection_mask_corimp_dynamic_thr, in, da, modgrad[*,*,3:6], alpgrad[*,*,3:6], cme_mask, show=show
endif

if ~keyword_set(gail) then print, 'Multiplying the modgrads 3 to 6 together: multmods'
multmods = modgrad[*,*,3]*modgrad[*,*,4]*modgrad[*,*,5]*modgrad[*,*,6]
if keyword_set(show) then plot_image, multmods

;Save the detection mask
if ~keyword_set(gail) then print, 'Saving CME mask (before removing lower scoring regions).'
if ~dir_exist(out_dir+'/cme_masks') then spawn, 'mkdir -p '+out_dir+'/cme_masks'
; only save out the index arrays of the non-zeros in the cme_mask
cme_mask_str = cme_mask_inds(cme_mask)
help,cme_mask_str
; Check the detection alert score
if size(cme_mask_str,/tname) eq 'STRUCT' then score = cme_mask_alert(da, cme_mask_str) else score = 0
; ALERT?
if ~keyword_set(gail) then print, 'Score: ', score, ' detection_threshold: ', detection_threshold
openu, lun, out_dir+'/scores.txt', /get_lun, /append
if score lt detection_threshold then printf, lun, score, in.filename, instr, f='(D,1x,A,1x,A)'
if score ge detection_threshold then printf, lun, score, in.filename, instr, '*', f='(D,1x,A,1x,A,1x,A)'
free_lun, lun
if score ge detection_threshold then begin
	if ~keyword_set(gail) then begin
		print, ' '
        	print, '---------------------------'
        	print, '|   CME DETECTION ALERT   |'
        	print, '---------------------------'
        	print, ' '
        endif
	;------------
        cme_alert = 1
        ;------------
	if ~file_exist(out_dir+'/CME_alerts.txt') then begin
		openw, lun, out_dir+'/CME_alerts.txt', /get_lun
		printf, lun, '# Detection_threshold: '+int2str(detection_threshold)
		printf, lun, '#     SCORE     DATE_TIME       INSTR'
		free_lun, lun
	endif
	openu, lun, out_dir+'/CME_alerts.txt', /get_lun, /append
	printf, lun, score, in.filename, instr, f='(D,1x,A,1x,A)'
	free_lun, lun
endif
scores[count] = score
	
case 1 of 
	instr eq 'C2': save, cme_mask_str, f=out_dir+'/cme_masks/CME_mask_str_C2_'+in.filename+'.sav'
	instr eq 'C3': save, cme_mask_str, f=out_dir+'/cme_masks/CME_mask_str_C3_'+in.filename+'.sav'
	instr eq 'COR2': save, cme_mask_str, f=out_dir+'/cme_masks/CME_mask_str_cor2_'+in.filename+'.sav'
endcase

;****************
; Thresholding what level of mask to include.
max_cme_mask = 0
if ~keyword_set(gail) then begin
	print, ' '
	print, '---------------------------------------'
	print, 'Threshold for CME detections is set as:'
	print, 'max_cme_mask ', max_cme_mask
	print, '---------------------------------------'
	print, ' '
endif
;****************


if max(cme_mask) gt max_cme_mask then begin
	if ~keyword_set(gail) then print, 'max(cme_mask) gt max_cme_mask: ', max(cme_mask), ' gt ', max_cme_mask
	cme_mask_thr = intarr(sz[0], sz[1])
	cme_mask_thr[where(cme_mask gt max_cme_mask)] = cme_mask[where(cme_mask gt max_cme_mask)]
	if ~keyword_set(gail) then print, 'CME DETECTED'
endif else begin
	if ~keyword_set(gail) then begin
		loadct, 0
		tvscl, da
		legend, 'No CME detected', charsize=2
		draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size, /device
		xyouts, 395, 990, in.date_obs, charsize=2, /device
		if ~keyword_set(no_png) then begin
			if ~dir_exist(out_dir+'/cme_pngs') then spawn, 'mkdir -p '+out_dir+'/cme_pngs'
			if instr eq 'C2' then x2png, out_dir+'/cme_pngs/CME_front_edges_C2_'+in.filename+'.png'
			if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then x2png, out_dir+'/cme_pngs/CME_front_edges_C3_'+in.filename+'.png'
		endif
	endif
	;------------
	cme_alert = 0
	;------------
	;plots_list = count
	goto, jump2
endelse

if ~keyword_set(gail) then begin
        loadct, 0
        tvscl, da
        draw_circle, in.xcen, in.ycen, in.rsun/in.pix_size, /device
        xyouts, 395, 990, in.date_obs, charsize=2, /device
endif

; Running run_automated2_new.pro
if ~keyword_set(gail) then print, 'Running run_automated2_new.pro with cme_mask_thr'
run_automated2_new, fl[count], in, da, multmods, cme_mask_thr, edges, out_dir, pa, heights, fail, gail=gail

if fail eq 0 then begin
	; Need to enter the maximum height along each angle since there can be many heights when angles are rounded
	for pa_i=0,n_elements(pa)-1 do begin
		pa_check = (round(pa))[pa_i] mod 360
		pa_slice[pa_check, count] = max(heights[where(round(pa) eq pa_check)])
	endfor
	;pa_slice[round(pa), count] = heights
	if n_elements(plots_list) eq 0 then plots_list = count else plots_list = [plots_list, count]
endif else begin
	if ~keyword_set(gail) then legend, 'No CME detected', charsize=2
	;plots_list = count
endelse

if ~keyword_set(gail) then begin
	legend, in.filename, /bottom, /right, box=0, charsize=2
	if cme_alert eq 1 then legend, 'CME ALERT ', /bottom, /left, charsize=2
endif

if ~keyword_set(no_png) && ~keyword_set(gail) then begin
	if ~dir_exist(out_dir+'/cme_pngs') then spawn, 'mkdir -p '+out_dir+'/cme_pngs'
	if instr eq 'C2' then x2png, out_dir+'/cme_pngs/CME_front_edges_C2_'+in.filename+'.png'
	if instr eq 'C3' then x2png, out_dir+'/cme_pngs/CME_front_edges_C3_'+in.filename+'.png'
	if instr eq 'COR2' then x2png, out_dir+'/cme_pngs/CME_front_edges_COR2_'+in.filename+'.png'
endif

jump2:

count += 1

delvarx, alpgrad, cme_mask, cme_mask_thr, columns, da, dr_px, edges, fail, heights
delvarx, k, max_cme_mask, modgrad, multmods, pa, rows, sz, thr_inner, thr_outer

;if cme_alert eq 1 then pause

;Shifting pa_slice so that it starts at solar north.
if ~keyword_set(gail) then print, 'Shifting pa_slice so that it starts at solar north.'
temp = pa_slice
temp[0:269,*] = pa_slice[90:359,*]
temp[270:359,*] = pa_slice[0:89,*]
pa_slice = temp
delvarx, temp

if ~dir_exist(out_dir+'/pa_slices') then spawn, 'mkdir -p '+out_dir+'/pa_slices'
if ~keyword_set(gail) then print, 'Saving pa_slice: ', out_dir+'/pa_slice_'+instr+'_'+in.filename+'.sav'
save, pa_slice, f=out_dir+'/pa_slices/pa_slice_'+instr+'_'+in.filename+'.sav'

if ~dir_exist(out_dir+'/cme_scores') then spawn, 'mkdir -p '+out_dir+'/cme_scores'
save, scores, f=out_dir+'/cme_scores/scores_'+instr+'_'+in.filename+'.sav'

; Email alert
;if cme_alert eq 1 then spawn, 'echo "CORIMP CME Alert '+instr+' '+in.filename+'" | mail -s "CORIMP CME ALERT 1" jbyrne6+corimp@gmail.com'


end
