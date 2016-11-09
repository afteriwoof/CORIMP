; Created 08-02-11 from algorithms5.b because it got too long.

; Last edited: 	09-02-11	to include the occulter flank points and stop ellipse fit running off! 
;		10-02-11	to split into run_algorithms2.pro for working on multiple CMEs in one image.
;		16-02-11	to include morph_close operator when defining how many CMEs are detected.

;INPUTS:	fls - list of fits


pro run_algorithms, fls, saves0=saves0, show=show, pauses=pauses, no_png=no_png

count = 0

while count lt n_elements(fls) do begin & $

if keyword_set(saves0) then goto, save_jump

print, '*****************************************************'
print, 'Reading file ',count,' of ',n_elements(fls)
print, fls[count]
mreadfits_corimp, fls[count], in, da & $

sz = size(da, /dim)

canny_atrous2d, da, modgrad, alpgrad & $

if in.i3_instr eq 'C2' then begin
	print, 'LASCO/C2'
	thr_inner = [2.65,2.55,2.45,2.4] & $
	thr_outer = [5.60,5.70,5.80,5.85] & $
endif

if in.i4_instr eq 'C3' then begin
	print, 'LASCO/C3'
	thr_inner = [8,7,6.5,6.25]
	thr_outer = [18,19,19.5,19.75]
endif

print, '-----------------------------------------------------'

for k=0,3 do modgrad[*,*,k+3]=rm_inner_corimp(modgrad[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
for k=0,3 do alpgrad[*,*,k+3]=rm_inner_corimp(alpgrad[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
for k=0,3 do modgrad[*,*,k+3]=rm_outer_corimp(modgrad[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
for k=0,3 do alpgrad[*,*,k+3]=rm_outer_corimp(alpgrad[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $


cme_detection_mask_corimp, in, da, modgrad[*,*,3:6], alpgrad[*,*,3:6], circ_pol, list, cme_mask, cme_detect, cme_detection_frames & $;, /show & $

multmods = modgrad[*,*,3]*modgrad[*,*,4]*modgrad[*,*,5]*modgrad[*,*,6] & $

; Thresholding what level of masks to include
;cme_mask_thr = cme_mask & $
;cme_mask_thr[where(cme_mask_thr le max(cme_mask)/3.)] = 0 & $
if in.i3_instr eq 'C2' then max_cme_mask = 5
if in.i4_instr eq 'C3' then max_cme_mask = 3

if max(cme_mask) gt max_cme_mask then begin
	cme_mask_thr = dblarr(sz[0],sz[1])
	cme_mask_thr[where(cme_mask gt max_cme_mask)] = cme_mask[where(cme_mask gt max_cme_mask)]
endif else begin
	loadct, 0
	plot_image, sigrange(da,/use_all)
	legend, 'No CME detected', charsize=2
        if ~keyword_set(no_png) then if in.i4_instr eq 'C3' then x2png, 'CME_front_ell_C3_'+int2str(count)+'.png'
        if ~keyword_set(no_png) then if in.i3_instr eq 'C2' then x2png, 'CME_front_ell_C2_'+int2str(count)+'.png'
	goto, jump2
endelse

; Saving programming time: delete later and delete semicolons down to here.
save, in, da, cme_mask_thr, sz, multmods, f='saves0.sav'
;stop
save_jump:
if keyword_set(saves0) then restore,'saves0.sav',/ver

; If contours on cme_mask_thr split then more than one CME detection is possibly occuring.
se = intarr(10,10)
se[*,*] = 1
cme_mask_dil = dilate(cme_mask_thr,se)
if keyword_set(show) then plot_image, cme_mask_dil & print, 'cme_mask_dil'
if keyword_set(show) then contour,cme_mask_dil,lev=1,/over,color=3
if keyword_set(pauses) then pause
contour,cme_mask_dil,lev=1,path_xy=xy,path_info=info,/path_data_coords
region_check = dblarr(sz[0],sz[1])
region_check_unique = dblarr(sz[0],sz[1])
prev_instance = 1 ;starting the measure of previous multiple detections at 1 since minimum for multiple detection has to be 2
cme_count = 1 ;how many CMEs are detected in the image - starts at one obviously.
cme_count_contour = intarr(n_elements(info)) ;which of the contoured regions corresponds to the detected CMEs

; Loop over all contoured regions of interest
for contour_count=0,n_elements(info)-1 do begin

	print, 'contour_count: ', contour_count
	if contour_count ne 0 then region_check[where(region_check gt 0)]=1 ; set all previous regions to same value of 1 (so 1+1 means overlap).
	
	region_x = xy[0,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
	region_y = xy[1,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
	region_ind = polyfillv(region_x, region_y, sz[0], sz[1])
	;print,'pmm region check before' & pmm, region_check
	region_check[region_ind] += 1
	;print,'pmm region check after' & pmm, region_check
	; region_check_unique is this specific region currently of interest
	region_check_unique[*,*] = 0
	region_check_unique[region_ind] = 1
	se = intarr(2,2)
	se[*,*] = 1
	if contour_count eq 0 then region_check = dilate(region_check,se) ; dilated slightly just to remove too small-scale noisy contours not of interest
	if keyword_set(show) then plot_image, region_check & print, 'plot_image, region_check'
	if keyword_set(pauses) then pause
	if keyword_set(show) then plot_image, region_check_unique & print, 'plot_image, region_check_unique'
	if keyword_set(pauses) then pause
	; if it's the first case of CME detection then no need to check dilation overlap so jump to end at jump1
	if max(region_check) gt 1 || contour_count eq 0 then goto, jump1
	
	; How much to dilate by for seperate CME regions:
	se = intarr(50,50)
	print, 'cme_count_contour ', cme_count_contour
	se[*,*] = 1	
	; How many regions before compared to after dilating - same means there are separate CMEs!
	if keyword_set(show) then contour, region_check, lev=1, /over, color=3
	contour, region_check, lev=1, path_info=info_before,/path_data_coords
	if keyword_set(pauses) then pause
	region_check_dilated = dilate(region_check, se)
	if keyword_set(show) then plot_image, region_check_dilated & print, 'plot_image, region_check_dilated'
	if keyword_set(pauses) then pause
	region_check_dilated = morph_close(region_check_dilated,replicate(1,40,40))
	if keyword_set(show) then plot_image, region_check_dilated & print, 'plot_image, morph_close(region_check_dilated)'
	if keyword_set(pauses) then pause
	if keyword_set(show) then contour, region_check_dilated, lev=1, /over, color=3
	contour, region_check_dilated, lev=1, path_info=info_after,/path_data_coords
	print, 'before: ', n_elements(info_before), 'after: ', n_elements(info_after)
	if keyword_set(pauses) then pause
	if n_elements(info_before) ge n_elements(info_after) && n_elements(info_after) gt 1 && n_elements(info_before) ne prev_instance then begin
		print, '------------------------------'
		print, '--- Multiple CMEs detected ---'
		print, '------------------------------'
	; HAVE TO PROPERLY FIND A WAY TO FLAG WHICH CONTOURS GO WITH WHICH CME!!!!!		
		cme_count_contour[cme_count] = contour_count
		cme_count = n_elements(info_after)
		prev_instance = n_elements(info_before)
	endif	

	jump1:
	
	;print, 'cme_count ', cme_count
;	print, 'jump1 down'
;	plot_image, cme_mask_thr
	;pause
;	plot_image,region_check_unique
	;pause
;	plot_image,cme_mask_thr*region_check_unique
	;pause
	
endfor

;print, 'cme_count ', cme_count
;print, 'cme_count_contour ', cme_count_contour

region_check_unique = dblarr(sz[0],sz[1])
count_unique = 0

print, 'No. of CMEs detected: ', cme_count

if cme_count gt 1 then begin

	for contour_count=0,cme_count-1 do begin

		region_x = xy[0,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
	        region_y = xy[1,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
	        region_ind = polyfillv(region_x, region_y, sz[0], sz[1])
		region_check_unique[*,*] = 0
	        region_check_unique[region_ind] = 1
		cme_mask_thr_unique = cme_mask_thr * region_check_unique
	
		;print, 'cme_count ',cme_count
		;print, 'contour_cout ', contour_count
		if keyword_set(show) then plot_image, cme_mask_thr & print, 'plot_image, cme_mask_thr'
		if keyword_set(pauses) then pause
		if keyword_set(show) then plot_image, region_check_unique & print, 'plot_image, region_check_unique'
		if keyword_set(pauses) then pause
		if keyword_set(show) then plot_image, cme_mask_thr_unique & print, 'plot_image, cme_mask_thr_unique'
		if keyword_set(pauses) then pause
	
		save, in, da, count, multmods, cme_mask_thr_unique, f='temp.sav'
		print, 'Running run_algorithms2.pro with cme_mask_thr_unique'
		if ~keyword_set(show) then run_algorithms2, in, da, count, multmods, cme_mask_thr_unique
		if keyword_set(show) && keyword_set(pauses) then run_algorithms2, in, da, count, multmods, cme_mask_thr_unique, /show, /pauses
		if keyword_set(show) && ~keyword_set(pauses) then run_algorithms2,in,da,count,multmods,cme_mask_thr_unique,/show
	
		if ~keyword_set(no_png) then if in.i4_instr eq 'C3' then x2png, 'CME_front_ell_C3_'+int2str(count)+'_'+int2str(count_unique)+'.png'
		if ~keyword_set(no_png) then if in.i3_instr eq 'C2' then x2png, 'CME_front_ell_C2_'+int2str(count)+'_'+int2str(count_unique)+'.png'
		count_unique += 1
	
	endfor

endif else begin

	if keyword_set(show) then plot_image, cme_mask_thr & print, 'plot_image, cme_mask_thr'
	if keyword_set(pauses) then pause	
	print, 'Running run_algorithms2.pro with cme_mask_thr'

	if ~keyword_set(show) then run_algorithms2,in,da,count,multmods,cme_mask_thr
	if keyword_set(show) && keyword_set(pauses) then run_algorithms2, in, da, count, multmods, cme_mask_thr, /show, /pauses
	if keyword_set(show) && ~keyword_set(pauses) then run_algorithms2,in,da,count,multmods,cme_mask_thr,/show

	if ~keyword_set(no_png) then if in.i4_instr eq 'C3' then x2png, 'CME_front_ell_C3_'+int2str(count)+'.png'
	if ~keyword_set(no_png) then if in.i3_instr eq 'C2' then x2png, 'CME_front_ell_C2_'+int2str(count)+'.png'

endelse

jump2:

count += 1

endwhile

end
