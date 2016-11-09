; Created	23-03-11	to remove the regions in pa_total that are too small

;	1)	detections that lie within two time steps of each other are grouped
;	2)	detections that span <7deg and don't have adjoining detections within 7deg are discraded
;	3)NOT DONE:	remaining detections that have not been grouped with at least two other detections are discarded

; Last edited:	02-09-11	to better clean the pa_total according to the criteria:
;		07-09-11


pro clean_pa_total, pa_total, thr ;thr being the allowed maximum angular width

sz = size(pa_total,/dim)
; padding image
pa_mask = intarr(sz[0]+14,sz[1]+14)
pa_mask[7:sz[0]+7-1, 7:sz[1]+7-1] = pa_total
pa_mask[where(pa_mask gt 0)] = 1 ;binary
pa_mask_orig = pa_mask

; This hit and miss formulation gets ride of detections that span <7deg and don't lie within 7deg of others.

; First check for those that are <7deg
hit = [1,0]
;matches = intarr(sz[0]+14, sz[1]+14)

miss = intarr(9,3)
miss[*,*] = 1
miss[1:7,1] = 0

matches = morph_hitormiss(pa_mask, hit, miss)
matches = dilate(matches, hit)

ind = where(matches gt 0)
; don't need to take inds from pixels beside each other
new_ind = ind[0]
for k=1,n_elements(ind)-1 do begin & $
	if ind[k]-ind[k-1] gt 1 then new_ind = [new_ind, ind[k]] & $
endfor

;if ind eq [-1] then goto, jump_end

init = morph_cc(pa_mask, ind[0])

for k=1,n_elements(ind)-1 do init += morph_cc(pa_mask, ind[k])

init[where(init gt 0)] = 1

; Now dilate init by 7deg and add back onto original minus init

pa_mask -= init

init = dilate(pa_mask+init, replicate(1,14))

; Now check init for those that lie within 7deg of neighbours

keep_final = intarr(sz[0]+14,sz[1]+14)
keep = morph_cc(init,new_ind[0])
for k=1,n_elements(new_ind)-1 do begin & $
	keep_new = morph_cc(init,new_ind[k]) & $
	if max(keep_new+keep) ge 2 then keep_final += keep_new & $
	if max(keep_new+keep) lt 2 then begin & $
		keep += keep_new & $
		keep[where(keep gt 0)] = 1 & $
	endif & $
endfor

keep_final[where(keep_final gt 0)] = 1

pa_mask_vert = pa_mask + keep_final
pa_mask_vert[where(pa_mask_vert gt 0)] = 1

pa_mask += (pa_mask_orig * keep_final)

; Now to check the clean up doesn't remove the bits that are part of groupings vertically

dil_str = intarr(1,7) + 1
dil_init = dilate(pa_mask_vert, dil_str);pa_mask, dil_str)
erode_str = intarr(1,8) + 1
erode_init = erode(dil_init, erode_str)
vertical_mask = morph_cc(dil_init, where(erode_init gt 0))

pa_mask *= vertical_mask
pa_mask[where(pa_mask gt 0)] = 1
pa_total *= pa_mask[7:sz[0]+7-1,7:sz[1]+7-1]



jump_end:

end
