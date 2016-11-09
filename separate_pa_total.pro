; Code to separate out the individual CME detections in a chunk of pa_total

; Created:	27-03-11
; Last edited	28-03-11	majority of code written today!
;		2012-09-19	to output final_pa_total.
;		2012-09-21	to include a region_grow that corrects for edge removal of morph operators.
;		2012-11-09	to fix the cases where the detections go off the images, top or bottom.
;		2012-12-12	to include keyword debug.

pro separate_pa_total, input_pa_total, detection_info, final_pa_total, show=show, debug=debug

if keyword_set(debug) then begin
	print, '***'
	print, 'separate_pa_total.pro'
	print, '***'
	pause
endif

sz = size(input_pa_total,/dim)
new = dblarr(sz[0]*2,sz[1]+4)
new[0:179,2:sz[1]+1] = input_pa_total[180:*,*]
new[180:539,2:sz[1]+1] = input_pa_total
new[540:*,2:sz[1]+1] = input_pa_total[0:179,*]

se = indgen(3,5)
se[*,*] = 1

new = morph_close(new, se)

contour, new, lev=0.5, path_xy=xy, path_info=info, /path_data_coords

;plot_image,new

;verline, 180
;verline, 540


; Have to first cycle through the contoured regions to remove any overlap (inset) ones
for c=0,n_elements(info)-1 do begin & $
	xc = xy[0, info[c].offset:(info[c].offset+info[c].n-1)] & $
        yc = xy[1, info[c].offset:(info[c].offset+info[c].n-1)] & $
        x = intarr(n_elements(xc)) & $
        y = intarr(n_elements(yc)) & $
        x[*] = xc[0,*] & $
        y[*] = yc[0,*] & $
        delvarx, xc, yc & $
	cind = polyfillv(x,y,(size(new,/dim))[0],(size(new,/dim))[1]) & $
	masks = intarr((size(new,/dim))[0],(size(new,/dim))[1]) & $
	masks[cind] = 1 & $
	if c eq 0 then begin & $
		count = c & $
		mask0 = masks & $
	endif else begin & $
		if max(masks+mask0) eq 1 then begin & $
			count=[count,c] & $
			mask0+=masks & $
			mask0[where(mask0 gt 0)]=1 & $
		endif & $
	endelse & $
endfor 

minsmaxs=0
cme_counter_first=0
masks = intarr((size(new,/dim))[0],(size(new,/dim))[1])
for i=0,n_elements(count)-1 do begin
	c = count[i]
	xc = xy[0, info[c].offset:(info[c].offset+info[c].n-1)]
	yc = xy[1, info[c].offset:(info[c].offset+info[c].n-1)]
	x = intarr(n_elements(xc))
	y = intarr(n_elements(yc))
	x[*] = xc[0,*]
	y[*] = yc[0,*]
	delvarx, xc, yc
	; Check each region for whether it's crossing the 0/360 line
	xmax = max(x)
	xmin = min(x)
	true = 0
	if xmax gt 539 then if xmin lt 539 then begin
		cind = polyfillv(x,y,(size(new,/dim))[0],(size(new,/dim))[1])
		masks[cind] = 1
		if cme_counter_first eq 0 then cme_counter=c else cme_counter = [cme_counter, c]
		cme_counter_first=1
		true = 1
	endif
	; Include the regions within the position angles allowed
	if xmin gt 180 and xmax lt 540 then begin
		cind = polyfillv(x,y,(size(new,/dim))[0],(size(new,/dim))[1])
		masks[cind] = 1
		if cme_counter_first eq 0 then cme_counter=c else cme_counter = [cme_counter, c]
		cme_counter_first=1
		true = 1
	endif
;	if xmin lt 180 then if xmax gt 180 then begin
;		print, 'Crosses 0/360'
;		cind = polyfillv(x,y,(size(new,/dim))[0],(size(new,/dim))[1])
;		masks[cind] = 1
;	endif
	if true eq 1 then begin
		xmax -= 180
		xmin -= 180
		if keyword_set(debug) AND xmax gt 359 then begin
			print, 'xmax gt 359 is ', xmax
			print, 'xmax-=360 is ', xmax-360
		endif
		if xmax gt 359 then xmax-=360
		if minsmaxs eq 0 then begin
			xmins = xmin
			xmaxs = xmax
			ymins = min(y)
			ymaxs = max(y)
			minsmaxs=1
		endif else begin
			xmins = [xmins, xmin]
			xmaxs = [xmaxs, xmax]
			ymins = [ymins, min(y)]
			ymaxs = [ymaxs, max(y)]
		endelse
	endif

endfor

;save, masks, f='masks_preshift.sav'
final_pa_total = shift(masks,1,1) ;contour shifts indices by 1 so correct for that
final_pa_total = final_pa_total[*,2:sz[1]+1]

if keyword_set(show) OR keyword_set(debug) then plot_image, final_pa_total, tit='final_pa_total wrapped around!'

if keyword_set(debug) then print, 'No of CMEs ', n_elements(cme_counter) 

if ~exist(xmins) then begin
	detection_info = 0
	goto, jump_end
endif

detection_info = intarr(4,n_elements(xmins))

for i=0,n_elements(xmins)-1 do begin
	if (ymaxs[i]-2+1) eq (size(input_pa_total,/dim))[1] then begin
		if (ymins[i]-2) lt 0 then detection_info[*,i] = [xmins[i],xmaxs[i]+1,0,ymaxs[i]-2] else detection_info[*,i] = [xmins[i],xmaxs[i]+1,ymins[i]-2,ymaxs[i]-2]
	endif else begin
		if (ymins[i]-2) lt 0 then detection_info[*,i] = [xmins[i],xmaxs[i]+1,0,ymaxs[i]-2+1] else detection_info[*,i] = [xmins[i],xmaxs[i]+1,ymins[i]-2,ymaxs[i]-2+1]
	endelse
endfor
;save, detection_info, f='detection_info.sav'
;stop

jump_end:

end
