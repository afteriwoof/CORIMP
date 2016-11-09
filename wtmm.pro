; Code which takes the canny_atrous2d from James and performs non-maxima suppression based on Alex's Matlab codes wtmm_edge.m

; Created:	17-02-11	from atrous_wtmm.pro in order to just call the edge detection part.

; Last Edited:

FUNCTION wtmm, modgrad, rows, columns

sz = size(modgrad,/dim)
;print, 'Currently running atrous decomposition edge detections with smoothing of 5 pixels.'

if n_elements(sz) lt 3 then begin
	edges = dblarr((size(rows,/dim))[0],(size(rows,/dim))[1])
	count = 0
endif else begin
	edges = dblarr((size(rows,/dim))[0],(size(rows,/dim))[1],sz[2])
	count = sz[2]-1
endelse


for n=0,count do begin

	sm = 5
	
	ax = smooth(rows[*,*,n], sm)
	ay = smooth(columns[*,*,n], sm)
	mag = smooth(modgrad[*,*,n], sm)
	mag /= max(mag)
	
	edg = dblarr((size(ax,/dim))[0],(size(ax,/dim))[1])
	
	; Use the rows and columns to determine the wtmm / non-maxima suppression in four directions.
	for dir=1,4 do begin
		idxLocalMax = FindLocalMaxima(dir, ax, ay, mag)
		idxWeak = idxLocalMax
		edg[idxWeak] = 1
		if dir eq 1 then begin
			idxStrong = [idxWeak]
		endif else begin
			idxStrong = [idxStrong, idxWeak]
		endelse
	endfor
	
	rstrong = idxStrong mod (size(ax,/dim))[0]
	cstrong = floor(idxStrong/(size(ax,/dim))[1])
	
	for k=0L,n_elements(idxStrong)-1 do begin
		if edg[rstrong[k],cstrong[k]] ne 0 then edges[rstrong[k],cstrong[k],n]=1
	endfor

endfor


return, edges

END
