; Created	20120210	from run_algorithms2_edges_tvscl.pro to go with run_automated.pro


; INUTS:	in -	index/headar
;		da -	image data
;		


; OUTPUTS


; VARIABLES:

pro run_automated2, fl, in, da, multmods, cme_mask_thr_unique, edges, out_dir, af_out, heights, fail, gail=gail

sz = size(da, /dim)

; Initialising
error_full = 0
fail = 0 ;flagging when detection fails for jump3

multmask = multmods * cme_mask_thr_unique

ind = where(multmask ne 0)
if ind eq [-1] then begin
	fail = 1
	goto, jump3
endif

multmask_binary = intarr(sz[0], sz[1])
multmask_binary[ind] = 1

;Thinning the multmask_binary because the peak location of the edges is in somewhat from the mask edges which can pick up some outside noise.
se_thin = replicate(1,9,9)
multmask_binary = erode(multmask_binary, se_thin)
if ~keyword_set(gail) then print, 'Eroding the multmask_binary by 9x9'

contour, multmask_binary, lev=1, path_xy=xy, /path_data_coords
; if the contour returns nothing then the detection fails --> jump3
if n_elements(xy) eq 0 then begin
	fail = 1
	goto, jump3
endif

;Multiplying these two means the multmask comes in the same amount as the multmask_binary thinning.
multmask *= multmask_binary

if ~keyword_set(gail) then print, 'Currently using edges[*,*,2] from wtmm, corresponding to array entry scale 5 of the canny_atrous decomposition.'
multmask *= edges[*,*,2]

;mu = moment(multmask,sdev=sdev)
;temp = dblarr(sz[0],sz[1])
;tempind = where(multmask gt (mu[0]+1.5*sdev))
;temp[tempind] = multmask[tempind]
;multmask = temp
;delvarx, temp, tempind, mu, sdev

ind = where(multmask gt 0)
if ind eq [-1] || n_elements(ind) lt 20 then begin
	fail = 1
	goto, jump3
endif

res = array_indices(multmask, ind)

; Unwrap image about the average of the contours not including the streamer segment.
unwrap = polar(multmask, ave(xy[0,*]), ave(xy[1,*]))

if max(unwrap) eq 0 then begin
	fail = 1
	goto, jump3
endif

kx1 = indgen(360)
ky1 = indgen(360)
kx = indgen(360)
ky = indgen(360)
count1 = 0
count2 = 0

for k=0,359 do begin
	find_outer_peak_edges, unwrap[*,k], loc;, /plots
	if loc eq 0 then count1 += 1 else kx[k-count1] = loc
	ky[count2] = ky1[k]
	if loc ne 0 then count2 += 1
	polrec, loc, k, tempx, tempy, /degrees
endfor

if count1 ne 360 then kx = kx[0:(359-count1)]
if count2 ne 0 then ky = ky[0:(count2-1)]

polrec, kx, ky, x, y, /degrees

xf = x + ave(xy[0,*])
yf = y + ave(xy[1,*])

;Renaming the header for changing its parameters
in_readin = in

; Gives out only the front points for use fitting ellipse (unless /full_front specified).
ellipse_mpfit_corimp, xf, yf, in_readin, da, xf_out, yf_out, xe, ye, error, p;, /rm_inner_front

if error eq 1 then goto, jump1

xf_out = (xf_out/in.cdelt1)+in.xcen
xe = (xe/in.cdelt1)+in.xcen
yf_out = (yf_out/in.cdelt2)+in.ycen
ye = (ye/in.cdelt2)+in.ycen

xe_noflanks = xe
ye_noflanks = ye
p_noflanks = p

recpol, xf_out[0]-in.xcen, yf_out[0]-in.ycen, flank1r, flank1a, /degrees
recpol, xf_out[n_elements(xf_out)-1]-in.xcen, yf_out[n_elements(yf_out)-1]-in.ycen, flank2r, flank2a, /degrees

;Case where CME crosses 0/360 line
if abs(flank1a-flank2a) gt 350 then begin
	;print, '----------------------------------'
        ;print, 'Case where flanks cross 0/360 line'
        ;print, '----------------------------------'
        recpol, xf_out-in.xcen, yf_out-in.ycen, rf_out, af_out, /degrees
        af_out = (af_out+180) mod 360
        flank1a = (min(af_out)+180) mod 360
        flank2a = (max(af_out)+180) mod 360
endif

if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then begin
        polrec,200,flank1a,flank1x,flank1y,/degrees & $
        polrec,200,flank2a,flank2x,flank2y,/degrees & $
endif
if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then begin
        polrec,110,flank1a,flank1x,flank1y,/degrees
        polrec,110,flank2a,flank2x,flank2y,/degrees
endif
if in.i4_instr eq 'COR2' || in.i4_instr eq 'cor2' then begin
        polrec,200,flank1a,flank1x,flank1y,/degrees
        polrec,200,flank2a,flank2x,flank2y,/degrees
endif

flank1x += in.xcen
flank1y += in.ycen
flank2x += in.xcen
flank2y += in.ycen

xf_new = [flank1x, xf_out, flank2x]
yf_new = [flank1y, yf_out, flank2y]

if keyword_set(fit_ellipse) then begin
	ellipse_mpfit_corimp, xf_new, yf_new, in_readin, da, xf_out_new, yf_out_new, xe, ye, error_out_new, p, /full_front
        xf_out_new = (xf_out_new/in.cdelt1)+in.xcen & $
        xe = (xe/in.cdelt1)+in.xcen & $
        yf_out_new = (yf_out_new/in.cdelt2)+in.ycen & $
        ye = (ye/in.cdelt2)+in.ycen & $
endif

jump1:

if ~keyword_set(gail) then begin
	if error ne 1 then begin
		print, '---------------------------------------'
	        ; Print out kinematic type info
	        heights = (sqrt((xf_out-in.xcen)^2.+(yf_out-in.ycen)^2.))*in.pix_size
	        recpol, xf_out-in.xcen, yf_out-in.ycen, rf_out, af_out, /degrees
	        print, 'Max height: ', max(heights)
	        print, 'Average height: ', ave(heights)
	        print, 'Median height: ', median(heights)
	        print, 'Flank angles: ', flank1a, flank2a
	        print, '---------------------------------------'
	endif else begin
	fail = 1
	print, '------------------------'
        print, 'Detection area too small'
        print, '------------------------'
	endelse
endif else begin
	heights = (sqrt((xf_out-in.xcen)^2.+(yf_out-in.ycen)^2.))*in.pix_size
        recpol, xf_out-in.xcen, yf_out-in.ycen, rf_out, af_out, /degrees
endelse

if ~keyword_set(gail) then begin
	set_line_color
	plots, res[0,*], res[1,*], psym=3, color=2, /device
	plots, xf_out, yf_out, psym=1, color=3, /device
endif

front = fltarr(2,n_elements(xf_out))
front[0,*] = xf_out
front[1,*] = yf_out
delvarx, xf_out, yf_out

if in.i3_instr eq 'C2' || in.i3_instr eq 'c2' then begin
	dets = {filename:file_basename(fl), date_obs:in.date_obs,instr:in.i3_instr,edges:float(res),front:float(front)}
	save, dets, f=out_dir+'/dets_'+in.filename+'_C2.sav'
endif
if in.i4_instr eq 'C3' || in.i4_instr eq 'c3' then begin
	dets = {filename:file_basename(fl), date_obs:in.date_obs,instr:in.i4_instr,edges:float(res),front:float(front)}
	save, dets, f=out_dir+'/dets_'+in.filename+'_C3.sav'
endif
if in.i4_instr eq 'COR2' || in.i4_instr eq 'cor2' then begin
	dets = {filename:file_basename(fl), date_obs:in.date_obs,instr:in.i4_instr,edges:float(res),front:float(front)}
	save, dets, f=out_dir+'/dets_'+in.filename+'_COR2.sav'
endif


jump3:

if fail eq 1 && ind ne [-1] then begin
	if ~keyword_set(gail) then print, 'Detection fails -- not enough points.'
endif



end
