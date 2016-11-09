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

unwrap_binary = polar(multmask_binary, in.xcen, in.ycen) & $
contour,unwrap_binary,lev=1,path_xy=unwrap_binary_xy,/path_data_coords & $
prof = total(unwrap_binary,1) & $
mu = moment(prof[where(prof ne 0)],sdev=sdev) & $
rad_mask = intarr(sz[0],sz[1]) & $
rad_mask[*,*] = 1 & $
ind = where(prof gt (mu[0]+1.5*sdev)) & $
if ind ne [-1] then begin & $
	ind = index_ends(ind,c) & $
	;for i=0,n_elements(ind)-1,2 do unwrap_binary[*,ind[i]:ind[i+1]]=0. & $
	countc = 0 & $
	rad_maskx = in.xcen & $
	rad_masky = in.ycen & $
	while countc lt c do begin & $
		polrec, max(unwrap_binary_xy[0,*]), ind[countc], radx, rady, /degrees & $
		rad_maskx = [rad_maskx, radx+in.xcen] & $
		rad_masky = [rad_masky, rady+in.ycen] & $
		countc += 1 & $
	endwhile & $
	radind = polyfillv(rad_maskx, rad_masky, sz[0], sz[1]) & $
	rad_mask[radind] = 0 & $
	plot_image, rad_mask & $
endif & $

multmask *= rad_mask & $
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

;recpol,xf_out[0]-in.xcen,yf_out[0]-in.ycen,flank1r,flank1a,/degrees & $
;polrec,200,flank1a,flank1x,flank1y,/degrees & $
;recpol,xf_out[n_elements(xf_out)-1]-in.xcen,yf_out[n_elements(yf_out)-1]-in.ycen,flank2r,flank2a,/degrees & $
;polrec,200,flank2a,flank2x,flank2y,/degrees & $

loadct, 0 & $
plot_image, sigrange(da, /use_all) & $
set_line_color & $
plots, xf, yf, psym=1, color=4 & $
plots, xf_out, yf_out, psym=1, color=3 & $
;plots, flank1x+in.xcen, flank1y+in.ycen, psym=2, color=6 & $
;plots, flank2x+in.xcen, flank2y+in.ycen, psym=2, color=6 & $
plots, xe, ye, psym=-3, color=3 & $
x2png, 'da_points_ave'+int2str(count)+'.png' & $

count += 1 & $

endwhile
