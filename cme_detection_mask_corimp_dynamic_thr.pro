; Created 28-07-11 from cme_detection_mask_corimp.pro to use a dynamic threshold in the moment threshold of the modgrad (c.f. test_contour_thresholds.pro). 

; Last Edited: 	28-01-11 	to include the cme_detection_frames output.
;		10-05-11	cleaned up repetition.
;		05-07-11	added keyword loud.

; Best to read in NRGF data

; One image detection 

; Using the code cme_detection_contours2_one_image.pro but without doing the polar unwrapping.

; Taken from cme_detection_nonpol.pro and edited to now try creating a mask of the detected CME.

pro cme_detection_mask_corimp_dynamic_thr, in, da, modgrad, alpgrad, cme_mask, list, circ_pol, cme_detect, cme_detection_frames, show=show, no_wait=no_wait, loud=loud


sz = size(da, /dim)
sz_mod = size(modgrad, /dim)
;!p.multi=[0,2,1]
winx=in.naxis1
winy=in.naxis2
if keyword_set(show) then window, xs=winx, ys=winy
;sdev_factor is to be set at 1.5 usually
sdev_factor = 1.5
no_contours = 25
if keyword_set(loud) then begin
print, '***' & print, 'sdev_factor: ', sdev_factor & print, 'no_contours: ', no_contours & print, '***'
endif
new_contours = no_contours
circ_pol = fltarr(180, no_contours,sz_mod[2])
circ_pol_norm = circ_pol
if keyword_set(show) then begin
	cme_detect = dblarr(winx,winy,no_contours*sz_mod[2])
	cme_detection_frames = dblarr(winx,winy,(no_contours+1)*sz_mod[2])
	print, (no_contours+1)*sz_mod[2]
	frames_count=0
endif
count = -1
list = bytarr(sz_mod[2]) ;where list entry is 1 the corresponding image contains a CME
cme_mask = bytarr(sz_mod[0], sz_mod[1])

for s=0,sz_mod[2]-1 do begin
; for each scale in the decomp.	
	
	;mag_chain, modgrad, magchains
	;xstepper, magchains, xs=700
	
;	alp1 = rm_inner_corimp(alpgrad[*,*,s], in, dr_px, thr=2.35)
	;alp1 = rm_outer(alp1, in, dr_px, thr=6.0)
;	mod1 = rm_inner_corimp(modgrad[*,*,s], in, dr_px, thr=2.35)
	;mod1 = rm_outer(mod1, in, dr_px, thr=6.0)
	mod1 = modgrad[*,*,s]
	alp1 = alpgrad[*,*,s]
	nonzero_inds = where(mod1 gt 0)

	;*********
	; Including dynamic thresholding as per test_contour_thresholds.pro
	temp = mod1
	test_contour_thresholds, temp, sdev_factor, no_contours, err, mask1, mu, sdev
	if err eq 1 then goto, jump2
	if keyword_set(show) then begin
		plot_image, mask1
		print, 'plot_image, mask1'
		;pause
	endif
	ind1 = where(mask1 eq 1)
	temp[ind1] = 0	
	test_contour_thresholds, temp, sdev_factor, no_contours, err, mask2, mu, sdev
	if err eq 1 then goto, jump2
	if keyword_set(show) then begin
		plot_image, mask2
		print, 'plot_image, mask2'
		;pause
	endif
	ind2 = where(mask2 eq 1)
	ind21 = where((mask2-mask1) eq 1)
	temp[ind2] = 0
	test_contour_thresholds, temp, sdev_factor, no_contours, err, mask3, mu3, sdev3
	if err eq 1 then goto, jump2
	if keyword_set(show) then begin
		plot_image, mask3
		print, 'plot_image, mask3'
		;pause
	endif
	ind3 = where(mask3 eq 1)
	ind32 = where((mask3-mask2) eq 1, cnt)
	if cnt ne 0 then temp[ind32] = 0
	while n_elements(ind32) gt n_elements(ind21) do begin
		mu = mu3
		sdev = sdev3
		test_contour_thresholds, temp, sdev_factor, no_contours, mask, mu3, sdev3
		if keyword_set(show) then begin
			plot_image, mask
			print, 'plot_image, mask'
			;pause
		endif
		temp_ind = where(mask eq 1, cnt)
		if cnt ne 0 then temp[temp_ind] = 0
		ind = where((mask-mask3) eq 1)
		ind21 = ind32
		ind32 = ind
	endwhile
	delvarx, temp, ind1, ind2, ind21, ind32, mask1, mask2, mask3, mu3, sdev3	
	
	jump2:
	
	;*********
	; so the final resulting dynamic threshold is:
	thresh = mu[0]+sdev_factor*sdev
	if keyword_set(show) then begin
		plot_image, mod1
		contour, mod1, lev=thresh, /over, closed=0
		;pause
	endif
	contour, mod1, lev=thresh, path_xy=xy, path_info=info, /path_data_coords, closed=0
	if keyword_set(show) then window, xs=winx, ys=winy
	while size(info, /dim) lt new_contours do new_contours-=1
	for c=0,new_contours-1 do begin
		x = xy[0,info[c].offset:(info[c].offset+info[c].n-1)]
		y = xy[1,info[c].offset:(info[c].offset+info[c].n-1)]	
		ind = polyfillv(x, y, sz_mod[0], sz_mod[1])
		if keyword_set(show) then thresh_mask_show = dblarr(sz_mod[0], sz_mod[1]) + 0.1
		thresh_mask = dblarr(sz_mod[0], sz_mod[1])
		if ind ne [-1] then begin
			if keyword_set(show) then thresh_mask_show[ind] = 1
			thresh_mask[ind] = 1
		endif else begin
			if keyword_set(loud) then print, 'ind eq -1'
		endelse
		alp1_thr = alp1*thresh_mask
		mod1_thr = mod1*thresh_mask
		;loadct, 0
		if keyword_set(show) then begin
			loadct,0
			plot_image, sigrange(mod1*thresh_mask_show), tit='Scale'+string(s)+'    Contour'+string(c)
			set_line_color
			contour, thresh_mask_show, lev=1, /over, color=3, closed=0
			if ~keyword_set(no_wait) then wait, 0.5
			cme_detection_frames[*,*,frames_count] = tvrd()
			frames_count+=1
		endif

		ind_mod1_thr = where(mod1_thr ne 0)
		if ind_mod1_thr ne [-1] then res = array_indices(mod1_thr, ind_mod1_thr) else goto, jump1
		sz_res = size(res,/dim)
		if n_elements(sz_res) gt 1 then begin
			for i=0L,sz_res[1]-1 do begin
				if mod1_thr[res[0,i],res[1,i]] ne 0 then circ_pol[(alp1_thr[res[0,i],res[1,i]] mod 180),c,s]+=1
			endfor
		endif else begin
			goto, jump1
		endelse
		; Making the movie of the rows now to see how the angle changes across image.
		;total_mu = 0.
		;indiv_mu = fltarr(sz_mod[1])
		;for j=0,sz_mod[1]-1 do begin
			;alp_row = alp1_thr[*,j]
			;mod_row = mod1_thr[*,j]
		 	;indiv_mu[j] = mean(alp_row)
		        ;total_mu += indiv_mu[j]
			;window, xs=600, ys=800
			;plot_image, mod_pol, xtit = indiv_mu[j]
			;plots,[0,sz_mod[0]-1], [j,j]
			;plot, alp_pol[*,j], xtickname=[" "," "," "," "," "]
			;place_arrow = 50
		;	for i=0,sz_mod[0]-1 do begin
		;		if mod1_thr[i,j] ne 0 then begin
		;			circ_pol[(alp1_thr[i,j] mod 180), c, s] += 1
					;if keyword_set(show) then begin
					;	arrow2, place_arrow, 40, alp1_thr[i,j], mod1_thr[i,j]*400, /angle, hsize=3, thick=1
					;	arrow2, 400, 40, alp1_thr[i,j], mod1_thr[i,j]*400, /angle, hsize=3, thick=1
					;	place_arrow+=1
					;endif
		;		endif
		;	endfor
		;endfor
		circ_pol[*,c,s] = circ_pol[*,c,s] / max(circ_pol[*,c,s])
		;plot, circ_pol[*,c,s], color=c+1
		; centre circ_pol on its maximum at coord 90
		circ_pol1 = circ_pol[*,c,s]
		temp=dblarr(180)
		tip = (where(circ_pol[*,c,s] eq 1))[0]
		if tip eq 90 then temp=circ_pol1
		if tip gt 90 then begin
			temp[0:90]=circ_pol1[(tip-90):tip]
			for i=91,179 do temp[i]=circ_pol1[((tip+(i-90)) mod 180)]
		endif
		if tip lt 90 then begin
			for i=0,90 do temp[i]=circ_pol1[(90+tip+i) mod 180]
			temp[91:179]=circ_pol1[(tip+1):(tip+90)-1]
		endif
		med_temp = median(temp)
		if keyword_set(show) then begin
			plot, temp, xr=[0,180], /xs, ytit=med_temp;, color=c+1
			;plots, [0,180], [med_temp, med_temp], line=1
			horline, med_temp
			if ~keyword_set(no_wait) then wait, 0.5
		endif
		circ_pol[*,c,s]=temp
		
		if med_temp gt 0.20 then begin
			list[s] = 3
			if keyword_set(show) then begin
				 legend, '*** CME DETECTED ***', charsize=2 ;, /bottom
				; need !p.color = 0 to show up legend on clear.
				plots, x, y, psym=3, color=3
				if ~keyword_set(no_wait) then wait, 0.5
			endif
			if keyword_set(loud) then begin
				print, '***** CME DETECTED *****' & print, 'contour: ', c, ' at scale: ', s
			endif
			cme_mask += 3*thresh_mask
		endif
		if med_temp gt 0.1 and med_temp le 0.2 then begin
			list[s] = 2
			if keyword_set(show) then begin
				legend, 'CME and/or streamer?', charsize=2
				plots, x, y, psym=3, color=4
				if ~keyword_set(no_wait) then wait, 0.5
			endif
			cme_mask += 2*thresh_mask
			if keyword_set(loud) then begin
				print, ' CME (and/or streamer) Detected' & print, 'contour: ', c, ' at scale: ', s
			endif
		endif
		if med_temp gt 0.05 and med_temp le 0.1 then begin
			list[s] = 1
			if keyword_set(show) then begin
				legend, 'Weak CME? or streamer.', charsize=2
				plots, x, y, psym=3, color=5
				if ~keyword_set(no_wait) then wait, 0.5	
			endif
			cme_mask += thresh_mask
			if keyword_set(loud) then begin
				print, ' possible weak CME detected' & print, 'contour: ', c, ' at scale: ', s
			endif
		endif
		
		jump1:
		
		count += 1
		
		if keyword_set(show) then begin
			cme_detect[*,*,count] = tvrd()
		endif
	
	endfor
	
	if keyword_set(show) then begin
		print, 'Final frame:'		
		loadct,0
		plot_image, cme_mask*sigrange(mod1)
                if ~keyword_set(no_wait) then wait, 0.5
		cme_detection_frames[*,*,frames_count] = tvrd()
                frames_count+=1
	endif

endfor

; Eroding the cme_mask due to the streak effects of the lower scales of decomposition
if keyword_set(loud) then print, 'Eroding the cme_mask due to the streak effects of the lower scales of decomposition.'
se = replicate(1,5,5)
cme_mask_erode = erode(cme_mask, se)
cme_mask *= cme_mask_erode

if keyword_set(show) then begin
	plot_image, cme_mask, tit='CME_mask'
	print, 'plot_image, cme_mask, tit=CME_mask'
;	pause
endif	

;wr_movie, 'cme_detect', cme_detect	
end
