; Created 10-02-11 from run_algorithms.pro to split out for different CMEs deteced in the one image.

; Last edited:  

;INPUTS:	fls - list of fits


pro run_algorithms2, in, da, count, multmods, cme_mask_thr, show=show, pauses=pauses

sz = size(da,/dim)

if keyword_set(show) then plot_image, multmods
if keyword_set(pauses) then pause
if keyword_set(show) then plot_image, cme_mask_thr
if keyword_set(pauses) then pause
multmask = multmods * cme_mask_thr & $
if keyword_set(show) then plot_image, multmask
if keyword_set(pauses) then pause
ind = where(multmask ne 0) & $
multmask_binary = dblarr(sz[0],sz[1]) & $
multmask_binary[ind] = 1 & $
if keyword_set(show) then plot_image, multmask_binary
if keyword_set(pauses) then pause

unwrap_binary = polar(multmask_binary, in.xcen, in.ycen) & $
if keyword_set(show) then plot_image, unwrap_binary
if keyword_set(pauses) then pause
contour,unwrap_binary,lev=1,path_xy=unwrap_binary_xy,/path_data_coords & $
rad_mask = intarr(sz[0],sz[1]) & $
rad_mask[*,*] = 1 & $
prof = total(unwrap_binary,1) & $
if max(prof) eq 0 then goto, jump2
mu = moment(prof[where(prof ne 0)],sdev=sdev) & $
ind = where(prof gt (mu[0]+1.5*sdev)) & $
if ind ne [-1] then begin & $
	ind = index_ends(ind,c) & $
	; Condition that if only one point lies above the threshold takes the points eitherside as segment.
	if c eq 2 then begin
		if ind[0] eq ind[1] then begin
			ind[0] = ind[0]-1
			if ind[0] lt 0 then ind[0] += 360
			ind[1] = (ind[1]+1) mod 360
		endif
	endif
	;for i=0,n_elements(ind)-1,2 do unwrap_binary[*,ind[i]:ind[i+1]]=0. & $
	countc = 0 & $
	rad_maskx = in.xcen & $
	rad_masky = in.ycen & $
	while countc lt c do begin & $
		polrec, max(unwrap_binary_xy[0,*])+8, ind[countc], radx, rady, /degrees & $
		rad_maskx = [rad_maskx, radx+in.xcen] & $
		rad_masky = [rad_masky, rady+in.ycen] & $
		countc += 1 & $
	endwhile & $
	radind = polyfillv(rad_maskx, rad_masky, sz[0], sz[1]) & $
	rad_mask[radind] = 0 & $
	print, '-----------------------------------'
	print, 'Removing radial segment as streamer'
	print, '-----------------------------------'
endif & $

jump2:

if keyword_set(show) then plot_image, rad_mask
if keyword_set(pauses) then pause

multmask_binary *= rad_mask & $
if keyword_set(show) then plot_image, multmask_binary
if keyword_set(pauses) then pause
contour, multmask_binary, lev=1, path_xy=xy, /path_data_coords & $
; Unwrap image about the average of the contours not including the streamer segment.
unwrap = polar(multmask, ave(xy[0,*]), ave(xy[1,*])) & $
if keyword_set(show) then plot_image, unwrap
if keyword_set(pauses) then pause

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

if keyword_set(show) then plots, kx, ky, psym=-1
if keyword_set(pauses) then pause
polrec, kx, ky, x, y, /degrees & $

if keyword_set(show) then plot_image, multmask

xf = x+ave(xy[0,*]) & $
yf = y+ave(xy[1,*]) & $
if keyword_set(show) then plots, xf, yf, psym=1
if keyword_set(pauses) then pause

; Check that the front points don't lie in the rad_mask streamer removed segment
countfs = 0
for k=0,n_elements(xf)-1 do begin
	if rad_mask[xf[k],yf[k]] eq 1 then countfs += 1
endfor
if countfs ne 0 then begin
	xfnew = dblarr(countfs)
	yfnew = dblarr(countfs)
	i = 0
	for k=0,n_elements(xf)-1 do begin
		if rad_mask[xf[k],yf[k]] eq 1 then begin
			xfnew[i] = xf[k]
			yfnew[i] = yf[k]
			i += 1
		endif
	endfor
endif

xf = xfnew
yf = yfnew
delvarx, xfnew, yfnew
if keyword_set(show) then plots, xf, yf, psym=2
if keyword_set(pauses) then pause

; gives out only the front points for use fitting ellipse (unless /full_front specified).
ellipse_mpfit_corimp, xf, yf, in, da, xf_out, yf_out, xe, ye, error & $;, /full_front & $

if error eq 1 then goto, jump1

xf_out = (xf_out/in.cdelt1)+in.xcen & $
xe = (xe/in.cdelt1)+in.xcen & $
yf_out = (yf_out/in.cdelt2)+in.ycen & $
ye = (ye/in.cdelt2)+in.ycen & $

if keyword_set(show) then plots, xe, ye, psym=-3, color=4
if keyword_set(pauses) then pause

recpol,xf_out[0]-in.xcen,yf_out[0]-in.ycen,flank1r,flank1a,/degrees & $
recpol,xf_out[n_elements(xf_out)-1]-in.xcen,yf_out[n_elements(yf_out)-1]-in.ycen,flank2r,flank2a,/degrees & $
; Case where CME crosses 0/360 line
if abs(flank1a-flank2a) gt 350 then begin
	print, '----------------------------------'
	print, 'Case where flanks cross 0/360 line'
	print, '----------------------------------'
	recpol, xf_out-in.xcen, yf_out-in.ycen, rf_out, af_out, /degrees
	af_out = (af_out+180) mod 360
	flank1a = (min(af_out)+180) mod 360
	flank2a = (max(af_out)+180) mod 360
endif
	
if in.i3_instr eq 'C2' then begin
	polrec,200,flank1a,flank1x,flank1y,/degrees & $
	polrec,200,flank2a,flank2x,flank2y,/degrees & $
endif
if in.i4_instr eq 'C3' then begin
	polrec,110,flank1a,flank1x,flank1y,/degrees
	polrec,110,flank2a,flank2x,flank2y,/degrees
endif

	flank1x += in.xcen & $
	flank1y += in.ycen & $
	flank2x += in.xcen & $
	flank2y += in.ycen & $

	xf_out_new = [flank1x, xf_out, flank2x]
	yf_out_new = [flank1y, yf_out, flank2y]

	if keyword_set(show) then plot_image, multmask
	if keyword_set(show) then plots, xf_out_new, yf_out_new, psym=1, color=2
	if keyword_set(pauses) then pause
	
	ellipse_mpfit_corimp, xf_out_new, yf_out_new, in, da, xf_out, yf_out, xe, ye, /full_front
	xf_out = (xf_out/in.cdelt1)+in.xcen & $
	xe = (xe/in.cdelt1)+in.xcen & $
	yf_out = (yf_out/in.cdelt2)+in.ycen & $
	ye = (ye/in.cdelt2)+in.ycen & $

	if keyword_set(show) then plots, xf_out, yf_out, psym=1, color=4
	if keyword_set(show) then plots, xe, ye, psym=-3, color=4
	if keyword_set(pauses) then pause
;endif

jump1:

loadct, 0 & $
plot_image, sigrange(da, /use_all) & $
set_line_color & $
if keyword_set(show) && error ne 1 then begin
	plots, flank1x, flank1y, psym=2, color=4 & $
	plots, flank2x, flank2y, psym=2, color=4 & $
	plots, xf, yf, psym=1, color=4 & $
	if keyword_set(pauses) then pause
endif
loadct, 0
plot_image, sigrange(da, /use_all)
if error ne 1 then begin
	set_line_color
	plots, xf_out, yf_out, psym=1, color=3 & $
	plots, flank1x, flank1y, psym=4, color=5
	plots, flank2x, flank2y, psym=4, color=5
	plots, xe, ye, psym=-3, color=3 & $
	save, xf_out, yf_out, f='front_xy.sav'
endif else begin
	set_line_color
	print, '-----------------'
	print, 'Ellipse fit fails'
	print, '-----------------'
	plots, xf, yf, psym=1, color=6
	legend, 'Ellipse fit fails', charsize=2
endelse
;x2png, 'da_points_ave'+int2str(count)+'.png' & $


end
