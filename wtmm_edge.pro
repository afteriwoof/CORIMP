PRO wtmm_edge, ax, ay, edg

; ax = horizontal details
; ay = vertical details

sz_ax = size(ax, /dim)
m = sz_ax[0]
n = sz_ax[1]

edg = fltarr(size(ax, /dim))

mag = sqrt((ax*ax) + (ay*ay))

magmax = max(mag)

if magmax gt 0 then mag = mag / magmax ; Normalise

; The next step is to perform the non-maxima suppression
; We will accrue indices which specify ON pixels in Strong Edgemap
; The array e will become the weak edge map.


for dir = 1,4 do begin
	idxLocalMax = FindLocalMaxima(dir, ax, ay, mag)
	idxWeak = idxLocalMax
	edg[idxWeak] = 1
	if dir eq 1 then idxStrong = [idxWeak]
	if dir ne 1 then idxStrong = [idxStrong, idxWeak]
endfor

; EVERYTHING in this code and in FindLocalMaxima.pro seems to be working upto this point! -JPB 23-09-07

if idxStrong ne [-1] then begin
	rstrong = ((idxStrong-1) mod m) + 1
	cstrong = floor( (idxStrong-1)/m ) + 1
	; got the same in Matlab (nearly) upto this point!
	; Make a loop for the rstrong,cstrong pixels to overlap roi's
	sz_r = size(rstrong,/dim)
	sz_c = size(cstrong,/dim)
	edg_roi = fltarr(size(edg,/dim))
	;for i=0,sz_r-1 do begin
	;	for j=0,sz_c-1 do begin
	i = 0.
	set_line_color
	while(i lt sz_r[0]) do begin
		j = 0.
		while(j lt sz_c[0]) do begin
			; is this wrong---> pix = edg[rstrong[i],cstrong[j]]
			regions = edg eq pix
			labels = label_region(regions)
			pix = labels[rstrong[i],cstrong[j]]
			roi = where(labels eq pix)
			edg_roi[roi]=1
			j += 1
			;plots, rstrong[i], cstrong[j], psym=5, color=i mod 8
		endwhile
		i += 1
		print, i
	endwhile
	;	endfor
	;endfor
	plot_image, edg_roi


endif


end

