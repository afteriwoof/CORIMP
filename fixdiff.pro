; Code to take out window of where running difference highlights changes.

; Created: 09-02-09
; Last Edited: 09-02-09 from rundiff_window.pro

pro fixdiff, da, dim, fixdiff, windows, mov=mov

read, 'Number of contours? ', no_contours
help, no_contours
sz = size(da, /dim)

fixdiff = dblarr(sz[0], sz[1], sz[2]-1)
windows = dblarr(sz[0],sz[1],sz[2]-1)
dim = windows

window, xs=800, ys=800
if keyword_set(mov) then mov = fltarr(800,800,sz[2]-1)

se = dblarr(8,8)
se[*,*] = 1
im1 = da[*,*,0]

for k=0,sz[2]-2 do begin	
	fixdiff[*,*,k] = da[*,*,k+1] - im1
	fixdiff[*,*,k] = fmedian(fixdiff[*,*,k],5)
	mu = moment(fixdiff[*,*,k], sdev=sdev)
	contour, fixdiff[*,*,k], lev=mu[0]+0.1*sdev, path_info=info, path_xy=xy, /path_data_coords, /fill
	plot_image, sigrange(fixdiff[*,*,k],frac=0.97)
	temp = fltarr(sz[0],sz[1])
	for c=0,no_contours[0]-1 do begin & $
		x = xy[0,info[c].offset:(info[c].offset+info[c].n-1)] & $
		y = xy[1,info[c].offset:(info[c].offset+info[c].n-1)] & $
		print, 'Plotting contours ', c & $
		plots, x, y, psym=3 & $
		wait, 1 & $
		index = polyfillv(x,y,sz[0],sz[1]) & $
		temp[index] = 1 & $
	endfor 
	windows[*,*,k] = dilate(temp,se)
	dim[*,*,k] = windows[*,*,k]
	dim[where(dim eq 0)] = 0.3
	
	if keyword_set(mov) then mov[*,*,k] = tvrd()
endfor

if keyword_set(mov) then wr_movie, 'mov_fixdiff', mov

end
