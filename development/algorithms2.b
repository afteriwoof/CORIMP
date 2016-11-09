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

multmods = modgrad[*,*,2]*modgrad[*,*,3]*modgrad[*,*,4]*modgrad[*,*,5]*modgrad[*,*,6] & $

cme_mask_thr = cme_mask & $
cme_mask_thr[where(cme_mask_thr le max(cme_mask)/3.)] = 0 & $
multmask = multmods * cme_mask_thr & $

unwrap = polar(multmask, in.xcen, in.ycen) & $

kx = indgen(360) & $
ky = indgen(360) & $

for k=0,359 do begin & $
	find_outer_peak, smooth(unwrap[*,k], 4), loc & $
	kx[k] = loc & $
endfor & $

polrec, kx, ky, x, y, /degrees & $
loadct, 0 & $
plot_image, sigrange(multmask, /use_all) & $
set_line_color & $
plots, x+in.xcen, y+in.ycen, psym=1, color=3 & $
x2png, 'mod_points'+int2str(count)+'.png' & $
wait, 0.5 & $

loadct, 0 & $
plot_image, cme_mask & $
set_line_color & $
plots, x+in.xcen, y+in.ycen, psym=1, color=3 & $
x2png, 'mask_points'+int2str(count)+'.png' & $

count += 1 & $

endwhile
