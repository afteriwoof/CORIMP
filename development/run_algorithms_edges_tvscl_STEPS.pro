; Created:	09-05-11 to see what the steps are for one individual file.

pro run_algorithms_edges_tvscl_STEPS, fl


mreadfits_corimp, fl, in, da

da = reflect_inner_outer(in, da)

canny_atrous2d, da, modgrad, alpgrad, rows=rows, columns=columns

da = da[96:1119,96:1119]
modgrad = modgrad[96:1119,96:1119,*]
alpgrad = alpgrad[96:1119,96:1119,*]
rows = rows[96:1119,96:1119,*]
columns = columns[96:1119,96:1119,*]

edges = wtmm(modgrad, rows, columns)

sz = size(da, /dim)

if in.i3_instr eq 'C2' then begin & $
	print, '%' & print, 'LASCO/C2' & $
	thr_inner = replicate(2.35,4) & $
	thr_outer = replicate(5.95,4) & $
endif
if in.i4_instr eq 'C3' then begin & $
	print, '%' & print, 'LASCO/C3' & $
	thr_inner = replicate(5.95,4) & $
	thr_outer = replicate(20,4) & $
endif

print, 'Removing inner/outer occulters'
for k=0,3 do begin & $
        modgrad[*,*,k+3]=rm_inner_corimp(modgrad[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
        alpgrad[*,*,k+3]=rm_inner_corimp(alpgrad[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
        modgrad[*,*,k+3]=rm_outer_corimp(modgrad[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
        alpgrad[*,*,k+3]=rm_outer_corimp(alpgrad[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
        rows[*,*,k+3] = rm_inner_corimp(rows[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
        rows[*,*,k+3] = rm_outer_corimp(rows[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
        columns[*,*,k+3]=rm_inner_corimp(columns[*,*,k+3],in,dr_px,thr=thr_inner[k]) & $
	columns[*,*,k+3]=rm_outer_corimp(columns[*,*,k+3],in,dr_px,thr=thr_outer[k]) & $
endfor

if in.i4_instr eq 'C3' then begin & $
	print, 'Removing the C3 pylon region of the modgrad and alpgrad images' & $
	restore,'c3pylonmask.sav' & $
 	for k=0,3 do begin & $
                modgrad[*,*,k+3] *= c3pylonmask & $
                alpgrad[*,*,k+3] *= c3pylonmask & $
        	rows[*,*,k+3] *= c3pylonmask & $
		columns[*,*,k+3] *= c3pylonmask & $
	endfor & $
endif

if in.i3_instr eq 'C2' then begin & $
        da = rm_inner_corimp(da, in, dr_px, thr=2.35) & $
        da = rm_outer_corimp(da, in, dr_px, thr=5.95) & $
endif
if in.i4_instr eq 'C3' then begin & $
        da = rm_inner_corimp(da, in, dr_px, thr=5.95) & $
        da = rm_outer_corimp(da, in, dr_px, thr=20) & $
        da *= c3pylonmask & $
        delvarx, c3pylonmask & $
endif

cme_detection_mask_corimp, in, da, modgrads[*,*,3:6], alpgrads[*,*,3:6], cme_mask, list, /show

multmods = modgrad[*,*,3]*modgrad[*,*,4]*modgrad[*,*,5]*modgrad[*,*,6]

if in.i3_instr eq 'C2' then max_cme_mask = 3
if in.i4_instr eq 'C3' then max_cme_mask = 1

cme_mask_thr = intarr(1024,1024)
cme_mask_thr[where(cme_mask gt max_cme_mask)] = cme_mask[where(cme_mask gt max_cme_mask)]

;If contours on cme_mask_thr split then more than one CME detection is possibly occuring.
; Loop over these and use run_algorithms2_edges_tvscl.pro

end
