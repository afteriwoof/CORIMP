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

cme_detection_mask_corimp, in, da, modgrad[*,*,2:6], alpgrad[*,*,2:6], circ_pol, list, cme_mask, cme_detect, cme_detection_frames & $;, /show & $

multmods = modgrad[*,*,2]*modgrad[*,*,3]*modgrad[*,*,4]*modgrad[*,*,5]*modgrad[*,*,6] & $

cme_mask_thr = cme_mask & $
cme_mask_thr[where(cme_mask_thr le max(cme_mask)/3.)] = 0 & $
multmask = multmods * cme_mask_thr & $
ind = where(multmask ne 0) & $
sz = size(multmask,/dim) & $
multmask_binary = dblarr(sz[0],sz[1]) & $
multmask_binary[ind] = 1 & $
contour, multmask_binary, lev=1, path_xy=xy, /path_data_coords & $

unwrap = polar(multmask, ave(xy[0,*]), ave(xy[1,*])) & $

kx1 = indgen(360) & $
ky1 = indgen(360) & $
kx = indgen(360) & $
ky = indgen(360) & $
count1 = 0 & $
count2 = 0 & $
for k=0,359 do begin & $
	find_outer_peak, smooth(unwrap[*,k], 4), loc & $
	if loc eq 0 then count1 += 1 & $
	if loc ne 0 then kx[k-count1] = loc & $
	ky[count2] = ky1[k] & $
	if loc ne 0 then count2 += 1 & $
endfor & $
kx = kx[0:(359-count1)] & $
ky = ky[0:(count2-1)] & $

polrec, kx, ky, x, y, /degrees & $

xf = x+ave(xy[0,*]) & $
yf = y+ave(xy[1,*]) & $

ellipse_mpfit_corimp, xf, yf, in, da, xf_out, yf_out, xe, ye & $;, /full_front & $
xf_out = (xf_out/in.cdelt1)+in.xcen & $
xe = (xe/in.cdelt1)+in.xcen & $
yf_out = (yf_out/in.cdelt2)+in.ycen & $
ye = (ye/in.cdelt2)+in.ycen & $

;loadct, 0 & $
;plot_image, sigrange(multmask, /use_all) & $
;set_line_color & $
;plots, x+ave(xy[0,*]), y+ave(xy[1,*]), psym=1, color=3 & $
;x2png, 'mod_points_ave'+int2str(count)+'.png' & $
;wait, 0.5 & $

loadct, 0 & $
plot_image, sigrange(da, /use_all) & $
set_line_color & $
plots, xe, ye, psym=-3, color=3 & $
x2png, 'da_ell'+int2str(count)+'.png' & $

loadct, 0 & $
plot_image, sigrange(da, /use_all) & $
set_line_color & $
plots, xf, yf, psym=1, color=4 & $
plots, xf_out, yf_out, psym=1, color=3 & $
plots, xe, ye, psym=-3, color=3 & $
x2png, 'da_points_ave'+int2str(count)+'.png' & $

;loadct, 0 & $
;plot_image, cme_mask & $
;set_line_color & $
;plots, x+ave(xy[0,*]), y+ave(xy[1,*]), psym=1, color=3 & $
;x2png, 'mask_points_ave'+int2str(count)+'.png' & $

count += 1 & $

endwhile
