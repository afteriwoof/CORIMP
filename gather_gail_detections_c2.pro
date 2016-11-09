;Created	2014-01-27	from gather_gail_detections_inset_all.pro to produce only the C2 detection images.

; Last edited:	
;	

; INPUTS	fls_in		-	the list of fits files used in the detections.
;		dets_fls_in	-	the list of dets_*.sav
;		datetimes	-	the edited yyyymmdd_hhmmss list read in from the /cme_profs/*txt files.


pro gather_gail_detections_c2, fls_in, dets_fls_in, datetimes, angs_in, angs_clean_in, out_dir, map=map, old_data=old_data, debug=debug

angs_clean = angs_clean_in
angs = angs_in

if keyword_set(debug) then print, '***CODE: gather_gail_detections_c2.pro'

!p.charsize=1
!p.charthick=1
!p.thick=1

str_count = 23
fls = sort_fls(fls_in)
dets_fls = dets_fls_in

C2_thr_inner = 2.2d
C2_thr_outer = 5.95d

in_times = strmid(file_basename(fls), str_count, 15)
dets_times = strmid(file_basename(dets_fls), 5, 15)

fls_start = where(in_times eq min(datetimes))
fls_end = where(in_times eq max(datetimes))

if fls_start eq [-1] || fls_end eq [-1] then begin
	print, 'fls_start: ', fls_start
	print, 'fls_end: ', fls_end
	help, in_times, datetimes, fls
	stop
endif

fls = fls[fls_start:fls_end]
in_times = strmid(file_basename(fls), str_count, 15)

if exist(c2_fls) then delvarx, c2_fls

; prep the files for scaling the images
str_cor = 0 
for i=0,n_elements(fls)-1 do begin & $
	test_fl = strmid(file_basename(fls[i]),str_cor,2) & $
	if test_fl eq 'c2' then begin
		if exist(c2_fls) then c2_fls = [c2_fls,i] else c2_fls = i & $
	endif
endfor

if ~exist(c2_fls) then goto, jump1
mreadfits_corimp,fls[c2_fls],in_c2,da_c2, /quiet
mreadfits_corimp, fls, in, da, /quiet

if n_elements(out_dir) eq 0 then out_dir='.'

; in case it crosses 0/360 line
angs = (angs+90) mod 360 ;shifting to solar north
angs_clean = (angs_clean+90) mod 360 ;shifting to solar north
if min(angs) le 1 AND max(angs) ge 359 then begin
	ind_min = min(where(angs eq min(angs)))
	ind_max = max(where(angs eq max(angs)))
	new_angs = [angs[ind_min:n_elements(angs)-1],angs[0:ind_max]]
	min_angs = angs[0]
        max_angs = angs[n_elements(angs)-1]
	angs = new_angs
endif else begin
	min_angs = min(angs)
        max_angs = max(angs)
endelse
polrec, 515, min_angs, x1_wide, y1_wide, /degrees
polrec, 515, max_angs, x2_wide, y2_wide, /degrees

; Do the same for the clean angs to plot the better angular width on the images
if min(angs_clean) le 1 AND max(angs_clean) ge 359 then begin
        ind_min_c = min(where(angs_clean eq min(angs_clean)))
        ind_max_c = max(where(angs_clean eq max(angs_clean)))
        new_angs_c = [angs_clean[ind_min_c:n_elements(angs_clean)-1],angs_clean[0:ind_max_c]]
	min_angs_c = angs_clean[0]
        max_angs_c = angs_clean[n_elements(angs_clean)-1]
        angs_clean = new_angs_c
	delvarx, new_angs_c
endif else begin
	min_angs_c = min(angs_clean)
        max_angs_c = max(angs_clean)
endelse
polrec, 515, min_angs_c, x1, y1, /degrees
polrec, 515, max_angs_c, x2, y2, /degrees

; initialise movie array
mov_arr_c2_512 = dblarr(512,512,n_elements(c2_fls))
mov_arr_c2 = dblarr(1024,1024,n_elements(c2_fls))

count=0
c2flag = 0
c2_replot = 0

; Get the masked off region of the congrid-ed c2 image ready for insetting to c3
imc2 = da_c2[*,*,0]
inc2 = in_c2[0]
temp_mask = bytarr(size(imc2,/dim))
temp_mask[*,*] = 1
temp_mask = rm_inner_corimp(temp_mask, inc2, thr=2.2, fill=0)
temp_mask = rm_outer_corimp(temp_mask, inc2, thr=6., fill=0)


for i=0,n_elements(fls)-1 do begin

	instr = strmid(file_basename(fls[i]),0,2)
	if keyword_set(debug) then begin
		print, '********  i: ', i, '  ********'
		print, 'fls[i] ', fls[i]
                print, 'instr: ', instr
        endif

	; making sure it's not just a case-sensitive error
	if instr eq 'C2' then instr='c2'

	if in[i].xcen le 0 then in[i].xcen=in[i].crpix1
	if in[i].ycen le 0 then in[i].ycen=in[i].crpix2
	
	loadct, 0
	test = where(dets_times eq in_times[i])
	if test ne [-1] then begin
		dets_instr = strmid(file_basename(dets_fls[test]),21,2)
		if dets_instr eq 'C2' then begin
                        restore, dets_fls[where(dets_times eq in_times[i])]
                        c2res = dets.edges
                        c2xf_out = dets.front[0,*]
                        c2yf_out = dets.front[1,*]
		endif
	endif 

	if instr eq 'c2' then begin
		if keyword_set(debug) then print, 'instr is C2'
		; code the inset of C2 into the C3 image
		inc2 = in[i]
		imc2 = da[*,*,i]
		;if ~keyword_set(old_data) then imc2 = (imc2>10000.)<50000.
		imc2 = (imc2>100.)<60000.
		if max(imc2) gt min(imc2) then imc2 = hist_equal(imc2, percent=0.1)
		get_ht_pa_2d_corimp, inc2.naxis1, inc2.naxis2, inc2.crpix1, inc2.crpix2, pix_size=inc2.pix_size/inc2.rsun, x, y,ht,pa
		fov = where(ht ge C2_thr_inner and ht lt C2_thr_outer, comp=nfov)
		;imc2[nfov] = mean(imc2[fov],/nan)
		imc2[nfov] = max(imc2)
		;imc2 = fmedian(imc2,6,6)
		tv, imc2
		;if keyword_set(debug) then pause

		set_line_color
                if exist(c2res) then plots, c2res[0,*], c2res[1,*], psym=3, color=2, /device
                if exist(c2xf_out) then plots, c2xf_out, c2yf_out, psym=1, color=3, /device
        	plots, [in[i].crpix1,in[i].crpix1+x1], [in[i].crpix2, in[i].crpix2+y1], line=0, color=5, thick=2, /device
                plots, [in[i].crpix1,in[i].crpix1+x2], [in[i].crpix2, in[i].crpix2+y2], line=0, color=5, thick=2, /device
		plots, [in[i].crpix1,in[i].crpix1+x1_wide], [in[i].crpix2, in[i].crpix2+y1_wide], line=5, color=5, thick=2, /device
                plots, [in[i].crpix1,in[i].crpix1+x2_wide], [in[i].crpix2, in[i].crpix2+y2_wide], line=5, color=5, thick=2, /device
	
      		if exist(inc2) then xyouts, 10,1000,'C2: '+inc2.date_obs, charsize=2, charthick=2, color=0, /device
		draw_circle, inc2.xcen, inc2.ycen, inc2.rsun/inc2.pix_size, /device, color=0
	
		date = strmid(file_basename(fls[i]),strpos(file_basename(fls[i]),'lasco_soho_')+20,8)+':'+$
			strmid(file_basename(fls[i]),strpos(file_basename(fls[i]),'lasco_soho_ ')+29+6)
	
		x2png, out_dir+'/c2/'+strmid(file_basename(fls[i]),strpos(file_basename(fls[i]),'lasco_soho_')+20,15)+'.png', /silent
		;save, imc3, f='temp.sav'
		
		mov_arr_c2[*,*,count] = tvrd()
		mov_arr_c2_512[*,*,count] = congrid(tvrd(),512,512)
		
		count += 1
	endif
	;if keyword_set(debug) then pause

endfor

wr_movie, out_dir+'/movie_c2_512', mov_arr_c2_512, url='movie_c2_512/', /delete
wr_movie, out_dir+'/movie_c2', mov_arr_c2, url='movie_c2/', /delete

; Convert pngs to the frames in the wr_movie so that color is included.
png_fls = file_search(out_dir+'/c2/*png')
sz = n_elements(png_fls)
if sz ge 100 then cnts=['00','0',''] else cnts=['0','']
for i=0,sz-1 do begin
        if i lt 10 then spawn, 'convert '+png_fls[i]+' '+out_dir+'/movie_c2/frame'+cnts[0]+int2str(i)+'.gif'
        if i ge 10 AND i lt 100 then spawn, 'convert '+png_fls[i]+' '+out_dir+'/movie_c2/frame'+cnts[1]+int2str(i)+'.gif'
        if i ge 100 then spawn, 'convert '+png_fls[i]+' '+out_dir+'/movie_c2/frame'+cnts[2]+int2str(i)+'.gif'
endfor


jump1:

end
