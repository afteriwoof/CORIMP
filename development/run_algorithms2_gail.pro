; Created 09-03-11 from run_algorithms2_edges_tvscl.pro to run on gail.

; Last edited:  

;INPUTS:	fls - list of fits


pro run_algorithms2_gail, in, da, count, multmods, cme_mask_thr, edges, contour_count, show=show, pauses=pauses

sz = size(da,/dim)

countc = 0 ;initialising for the removing radial segement part of code.

error_full = 0 ; intialising
 
fail = 0 ; flagging when detection fails for jump3.

if keyword_set(show) then tvscl, multmods
if keyword_set(pauses) then pause
if keyword_set(show) then tvscl, cme_mask_thr
if keyword_set(pauses) then pause
multmask = multmods * cme_mask_thr & $
if keyword_set(show) then begin
	tvscl, sigrange(multmask)
	print, 'tvscl, sigrange(multmask)'
	if keyword_set(pauses) then pause
endif
ind = where(multmask ne 0) & $
if ind eq [-1] then begin
	fail = 1
	goto, jump3
endif

multmask_binary = dblarr(sz[0],sz[1]) & $
multmask_binary[ind] = 1 & $
if keyword_set(show) then begin
	tvscl, multmask_binary
	print, 'tvscl, multmask_binary'
	if keyword_set(pauses) then pause
endif

print, 'Currently using edges[*,*,2] from wtmm, corresponding to array entry scale 5 of the canny_atrous'
if keyword_set(show) then begin
	tvscl, multmask_binary*edges[*,*,2]
	print, 'tvscl, multmask_binary*edges[*,*,2]'
	if keyword_set(pauses) then pause
endif
unwrap_binary = polar(multmask_binary, in.xcen, in.ycen) & $
if keyword_set(show) then begin
	tvscl, unwrap_binary
	print, 'tvscl, unwrap_binary'
	if keyword_set(pauses) then pause
endif
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
	rad_maskx = in.xcen & $
	rad_masky = in.ycen & $
	radxs = dblarr(c)
	radys = dblarr(c)
	while countc lt c do begin & $
		polrec, max(unwrap_binary_xy[0,*])+8, ind[countc], radx, rady, /degrees & $
		rad_maskx = [rad_maskx, radx+in.xcen] & $
		rad_masky = [rad_masky, rady+in.ycen] & $
		radxs[countc] = radx
		radys[countc] = rady
		countc += 1 & $
	endwhile & $
	radind = polyfillv(rad_maskx, rad_masky, sz[0], sz[1]) & $
	rad_mask[radind] = 0 & $
	print, '-----------------------------------'
	print, 'Removing radial segment as streamer'
	print, '-----------------------------------'
endif & $

jump2:

if keyword_set(show) then tvscl, rad_mask
if keyword_set(pauses) then pause

; New mask wtih radial streamer segment removed
multmask_binary *= rad_mask & $
if keyword_set(show) then begin
	tvscl, multmask_binary
	print, 'tvscl, multmask_binary (radial segment removed?)'
	if keyword_set(pauses) then pause
endif

contour, multmask_binary, lev=1, path_xy=xy, /path_data_coords & $
; If the contour returns nothing then the detection fails --> jump3
if n_elements(xy) eq 0 then begin
	fail = 1
	goto, jump3
endif

if keyword_set(show) then begin
	tvscl, sigrange(multmask)
	print, 'tvscl, sigrange(multmask)'
	if keyword_set(pauses) then pause
endif
; Bringing in old the edges detected by WTMM
multmask *= edges[*,*,2]
if keyword_set(show) then begin
	tvscl, sigrange(multmask)
	print, 'tvscl, sigrange(multmask*edges[*,*,2])'
	if keyword_set(pauses) then pause
endif

ind = where(multmask gt 0)
if ind eq [-1] then begin
	fail = 1
	goto, jump3
endif

res = array_indices(multmask,ind)

; Unwrap image about the average of the contours not including the streamer segment.
unwrap = polar(multmask, ave(xy[0,*]), ave(xy[1,*])) & $

if max(unwrap) eq 0 then begin
	fail = 1
	goto, jump3
endif

if keyword_set(show) then begin
	tvscl, sigrange(unwrap)
	print, 'tvscl, unwrap (the unwrapped multmask of the edges)'
	if keyword_set(pauses) then pause
endif

kx1 = indgen(360) & $
ky1 = indgen(360) & $
kx = indgen(360) & $
ky = indgen(360) & $
count1 = 0 & $
count2 = 0 & $
for k=0,359 do begin & $
	find_outer_peak_edges, unwrap[*,k], loc & $
	if loc eq 0 then count1 += 1 & $
	if loc ne 0 then kx[k-count1] = loc & $
	ky[count2] = ky1[k] & $
	if loc ne 0 then count2 += 1 & $
endfor & $

kx = kx[0:(359-count1)] & $
ky = ky[0:(count2-1)] & $

if keyword_set(show) then plots, kx, ky, psym=1, /device
if keyword_set(pauses) then pause
polrec, kx, ky, x, y, /degrees & $

if keyword_set(show) then begin
	tvscl, sigrange(multmask)
	print, 'tvscl, sigrange(multmask)'
	if keyword_set(pauses) then pause
endif

xf = x+ave(xy[0,*]) & $
yf = y+ave(xy[1,*]) & $
if keyword_set(show) then plots, xf, yf, psym=1, /device
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
if keyword_set(show) then plots, xf, yf, psym=2, /device
if keyword_set(pauses) then pause

; Renaming the header for changing its parameters.
in_readin = in

; obtaining the ellipse fit for the full_front for comparison (without having to close the flanks).
ellipse_mpfit_corimp, xf, yf, in_readin, da, xf_out_full, yf_out_full, xe_full, ye_full, error_full, p_full, /full_front
if error_full ne 1 then begin
	xe_full = (xe_full/in.cdelt1)+in.xcen
	ye_full = (ye_full/in.cdelt2)+in.ycen
endif

; gives out only the front points for use fitting ellipse (unless /full_front specified).
ellipse_mpfit_corimp, xf, yf, in_readin, da, xf_out, yf_out, xe, ye, error, p & $;, /full_front & $

if error eq 1 then goto, jump1

xf_out = (xf_out/in.cdelt1)+in.xcen & $
xe = (xe/in.cdelt1)+in.xcen & $
yf_out = (yf_out/in.cdelt2)+in.ycen & $
ye = (ye/in.cdelt2)+in.ycen & $

xe_noflanks = xe
ye_noflanks = ye
p_noflanks = p

if keyword_set(show) then begin
	set_line_color
	plots, xe, ye, psym=-3, color=4, /device
	if keyword_set(pauses) then pause
endif

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

	xf_new = [flank1x, xf_out, flank2x]
	yf_new = [flank1y, yf_out, flank2y]

	if keyword_set(show) then begin
		tvscl, sigrange(multmask)
		plots, xf_new, yf_new, psym=1, color=2, /device
		print, 'tvscl, multmask & plots, xf_new, yf_new, psym=1, color=2, /device'
		if keyword_set(pauses) then pause
	endif

	ellipse_mpfit_corimp, xf_new, yf_new, in_readin, da, xf_out_new, yf_out_new, xe, ye, error_out_new, p, /full_front
	xf_out_new = (xf_out_new/in.cdelt1)+in.xcen & $
	xe = (xe/in.cdelt1)+in.xcen & $
	yf_out_new = (yf_out_new/in.cdelt2)+in.ycen & $
	ye = (ye/in.cdelt2)+in.ycen & $

	if keyword_set(show) then begin
		plots, xf_out_new, yf_out_new, psym=1, color=4, /device
		plots, xe, ye, psym=-3, color=4, /device
		print, 'plots, xf_out_new, yf_out_new and ellipse fit'
		if keyword_set(pauses) then pause
	endif

jump1:

loadct, 0 & $
if contour_count eq 0 then tvscl, sigrange(da, /use_all) & $
if keyword_set(show) && error ne 1 then begin
	set_line_color
	plots, flank1x, flank1y, psym=2, color=4, /device
	plots, flank2x, flank2y, psym=2, color=4, /device
	plots, xf, yf, psym=1, color=4, /device
	if keyword_set(pauses) then pause
endif
loadct,0
if contour_count eq 0 then tvscl, da
; delete the tvscl repeat since currently issue with overplotting multiple detections
;tvscl,da

; Label the thresholds in place as declared at start of run_algorithms_edges.pro
xyouts, 20, 50, 'max_cme_mask', charsize=2
xyouts, 20, 25, 'thr: C2=1 C3=1', charsize=2


if error ne 1 then begin
	set_line_color
	plots, res[0,*], res[1,*], psym=3, color=5, /device
;	plots, xf, yf, psym=1, color=4, /device
;	plots, xe_full, ye_full, psym=-3, color=4
	plots, xf_out, yf_out, psym=1, color=3, /device
;	plots, xf_out_new, yf_out_new, psym=1, color=3
;	spline_p, xf_out, yf_out, x_spline, y_spline
;	plots, x_spline, y_spline, psym=-3, color=6
;	plots, xe_noflanks, ye_noflanks, psym=-3, color=2, /device
	plots, flank1x, flank1y, psym=4, color=5, /device
	plots, flank2x, flank2y, psym=4, color=5, /device
	plots, [in.xcen,flank1x], [in.ycen,flank1y], /device
	plots, [in.xcen,flank2x], [in.ycen,flank2y], /device
;	plots, xe, ye, psym=-3, color=3 & $
	for temp=0,countc-1 do begin
		plots, [in.xcen,radxs[temp]+in.xcen],[in.ycen,radys[temp]+in.ycen],linestyle=2,color=6, /device
	endfor
;	plots, ave(xy[0,*]), ave(xy[1,*]), psym=6, color=7, /device
endif else begin
	set_line_color
	print, '-----------------'
	print, 'Ellipse fit fails'
	print, '-----------------'
	plots, xf, yf, psym=1, color=6, /device
	legend, 'Ellipse fit fails', charsize=2,/right
endelse
;x2png, 'da_points_ave'+int2str(count)+'.png' & $

jump3:
if fail eq 1 then begin
        print, 'Not enough points - detection fails!'
        if contour_count eq 0 then tvscl, da 
        legend, 'Detection area too small', charsize=2
endif

if error_full ne 1 then save, in, da, xf, yf, xf_out_new, yf_out_new, res, xe, ye, xe_noflanks, ye_noflanks, xe_full, ye_full, p_noflanks, f='catalogue_input18.sav'

;stop

; Output CME detection info to catalogue.
;catalogue, in, da, xf, yf, xf_out_new, yf_out_new, res, xe, ye, xe_noflanks, ye_noflanks, xe_full, ye_full, p_noflanks






end
