; Code which takes the canny_atrous2d from James and performs non-maxima suppression based on Alex's Matlab codes wtmm_edge.m

; Last Edited: 	26-09-07
;		16-02-11

PRO atrous_wtmm, da, n, edg_morph

im = da ;need for loop over da
plot_image, im

; Perform the atrous wavelet transform to obtain the rows and columns.
canny_atrous2d, im, modgrad, alpgrad, rows=rows, columns=columns

ax = rows[*,*,n]
ay = columns[*,*,n]
mag = modgrad[*,*,n] / max(modgrad[*,*,n])
edg = fltarr(size(ax, /dim))
m = (size(ax,/dim))[0]
n = (size(ax,/dim))[1]

; Use the rows and columns to determine the wtmm / non-maxima suppression in four directions.
for dir=1,4 do begin
	idxLocalMax = FindLocalMaxima(dir, ax, ay, mag)
	help, idxLocalMax
	idxWeak = idxLocalMax
	edg[idxWeak] = 1
	if dir eq 1 then begin
		idxStrong = [idxWeak]
	endif else begin
		idxStrong = [idxStrong, idxWeak]
	endelse
endfor

stop

; Make a threshold on the mag
thr = mag
thr[where(thr lt 0.02)] = 0
edg = thr * edg
edg[where(edg ne 0)] = 1
plot_image, edg
pause
se = [[1,1],[1,1]]
edg_morph = morph_close(dilate(edg, se), se)
plot_image, edg_morph



END
