; Taking out the middle bit of multiple CMEs detected in run_algorithms_edges_tvscl.pro

;Created:	12-05-11

;INPUTS:	cme_mask_dil

;OUTPUTS:	

pro multiple_cmes_steps, cme_mask_thr, cme_count, region_check, region_check_unique, show=show

sz = [1024,1024]

cme_mask_dil = dilate(cme_mask_thr, replicate(1,11,11))

contour, cme_mask_dil, lev=1, path_xy=xy, path_info=info, /path_data_coords

region_check = intarr(sz[0],sz[1])
region_check_unique = intarr(sz[0],sz[1])

cme_count = 1 ;how many cmes are detected in the image - starts at one.

; want to initialise the variables that will contain the incidents where more than one contour makes up a single CME.
flag_count = 0

for contour_count=0,n_elements(info)-1 do begin

	print, 'contour_count: ', contour_count
	
	if contour_count ne 0 then region_check[where(region_check gt 0)]=1 ; set all previous regions to same value of 1 (so 1+1 means overlap)

	region_x = xy[0,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
	region_y = xy[1,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
	region_ind = polyfillv(region_x,region_y,sz[0],sz[1])
	region_check[region_ind] += 1
	region_check_unique[*,*] = 0
	region_check_unique[region_ind] = 1

	if keyword_set(show) then begin
		tvscl, region_check
		print, 'tvscl, region_check'
		pause
		tvscl, region_check_unique
		print, 'tvscl, region_check_unique'
		pause
	endif
	
	; If it's the first case of CME detection then no need to check dilation overlap so jump to end at jump1.
	if max(region_check) gt 1 || contour_count eq 0 then goto, jump1

	if keyword_set(show) then contour, region_check, lev=1, /over, color=3
	contour, region_check, lev=1, path_info=info_before, /path_data_coords
	print, 'n_elements(info_before): ', n_elements(info_before)
		
	region_check_dilated = dilate(region_check, replicate(1,51,51))
	region_check_unique_dil = dilate(region_check_unique, replicate(1,51,51))
	region_check_unique_dil = morph_close(region_check_unique_dil, replicate(1,41,41))
	region_check_unique_dil_ind = where(region_check_unique_dil gt 0)
	region_check_dilated[region_check_unique_dil_ind] = 1
	delvarx, region_check_unique_dil_ind
	if keyword_set(show) then begin
		tvscl, region_check_dilated
		print, 'tvscl, region_check_dilated'
		pause
	endif

	contour, region_check_dilated, lev=1, path_info=info_after, /path_data_coords
	print, 'n_elements(info_after): ', n_elements(info_after)

	print, 'cme_count before: ', cme_count

	if n_elements(info_after) ne cme_count then begin
		print, '********************'
		print, 'Multiple CMEs detected'
		print, '********************'
		cme_count = n_elements(info_after)
		print, 'cme_count after: ', cme_count
	endif else begin
		print, '********************'
		print, 'Part of the same CME'
		print, '********************'
		if flag_count eq 0 then flag_multiples = contour_count else flag_multiples = [flag_multiples,contour_count]
		flag_count += 1
	endelse
	
	if keyword_set(show) then pause

	jump1:

endfor

print, 'flag_multiples: ', flag_multiples

;**********

print, '-------------------------------------'
print, 'Number of CMEs detected: ', cme_count
print, '-------------------------------------'

region_check_unique = intarr(sz[0],sz[1])

if cme_count gt 1 then begin

	for contour_count=0,n_elements(info)-1 do begin

		region_x = xy[0,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
		region_y = xy[1,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
		region_ind = polyfillv(region_x, region_y, sz[0], sz[1])
		region_check_unique[*,*] = 0
		region_check_unique[region_ind] = 1
		cme_mask_thr_unique = cme_mask_thr * region_check_unique

		tvscl, region_check_unique
		print, 'tvscl, region_check_unique'
		pause
		
		region_check_unique_dil = dilate(region_check_unique, replicate(1,51,51))
		tvscl, region_check_unique_dil
		print, 'tvscl, region_check_unique_dil'
		pause

		; Check if any of the flag_multiples countours overlaps this one so they can be grouped:
		for i=0,n_elements(flag_multiples)-1 do begin
			test_region = intarr(sz[0],sz[1])
			print, 'i: ', i
			print, 'flag_multiples: ', flag_multiples
			print, 'flag_multiples[i]: ', flag_multiples[i]
			test_region_x = xy[0,info[flag_multiples[i]].offset:(info[flag_multiples[i]].offset+info[flag_multiples[i]].n-1)]
			test_region_y = xy[1,info[flag_multiples[i]].offset:(info[flag_multiples[i]].offset+info[flag_multiples[i]].n-1)]
			test_region_ind = polyfillv(test_region_x, test_region_y, sz[0], sz[1])
			test_region[test_region_ind] = 1
			tvscl, test_region
			print, 'tvscl, test_region'
			pause
			test_region_dil = dilate(test_region, replicate(1,51,51))
			tvscl, test_region_dil
			print, 'tvscl, test_region_dil'
			pause
			tvscl, test_region_dil + region_check_unique_dil
			print, 'tvscl, test_region_dil + region_check_unique_dil'
			print, 'max: ', max(test_region_dil + region_check_unique_dil)
			pause
			if max(region_check_unique_dil + test_region_dil) gt 1 then begin
				tvscl, cme_mask_thr_unique + test_region*cme_mask_thr
				print, 'tvscl, cme_mask_thr_unique + test_region*cme_mask_thr'
				pause
				mask_group = cme_mask_thr_unique + test_region*cme_mask_thr
			endif else begin
				mask_group = cme_mask_thr_unique
			endelse
		endfor

		print, 'This is the input to be used for run_algorithms2_edges_tvscl.pro'
		tvscl, mask_group
		print, 'tvscl, mask_group'
		pause

	endfor

endif

end
