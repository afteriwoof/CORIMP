;fls = file_search('*.fts')

count = 0

while count lt n_elements(fls) do begin & $

mreadfits_corimp, fls[count], in, da & $

canny_atrous2d, da, modgrad, alpgrad & $

thr_inner = [2.45,2.43,2.41,2.39,2.37] & $
thr_outer = [5.68,5.72,5.76,5.80,5.84] & $

for k=0,4 do modgrad[*,*,k]=rm_inner_corimp(modgrad[*,*,k],in,dr_px,thr=thr_inner[k]) & $
for k=0,4 do alpgrad[*,*,k]=rm_inner_corimp(alpgrad[*,*,k],in,dr_px,thr=thr_inner[k]) & $
for k=0,4 do modgrad[*,*,k]=rm_outer_corimp(modgrad[*,*,k],in,dr_px,thr=thr_outer[k]) & $
for k=0,4 do alpgrad[*,*,k]=rm_outer_corimp(alpgrad[*,*,k],in,dr_px,thr=thr_outer[k]) & $

cme_detection_mask_corimp, in, da, modgrad[*,*,2:6], alpgrad[*,*,2:6], circ_pol, list, cme_mask, cme_detect, cme_detection_frames & $ ;, /show & $

;save, cme_detection_frames, f='cme_detection_frames'+int2str(count)+'.sav' & $

save, modgrad, f='modgrad'+int2str(count)+'.sav' & $
save, alpgrad, f='alpgrad'+int2str(count)+'.sav' & $

;save, cme_mask, f='cme_mask'+int2str(count)+'.sav' & $

if count eq 0 then begin & $
	openw, lun, /get_lun, 'list.txt', error=err & $
	printf, lun, 'rows: ', n_elements(fls) & $
	printf, lun, list & $
	free_lun, lun & $
endif else begin & $
	openu, lun, 'list.txt', /append & $
	printf, lun, list & $
	free_lun, lun & $
endelse & $

count += 1 & $

endwhile
