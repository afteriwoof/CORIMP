; Code to take out window of where running difference highlights changes.

; Created: 01-12-08
; Last Edited: 27-01-09 to include more than one contour

pro rundiff_window, da, diff, dim, windows, mov=mov

read, 'Number of contours? ', no_contours
help, no_contours
sz = size(da, /dim)

diff = fltarr(sz[0], sz[1], sz[2]-1)
windows = dblarr(sz[0],sz[1],sz[2]-1)
dim = windows

window, xs=800, ys=800
if keyword_set(mov) then mov = fltarr(800,800,sz[2]-1)

se = dblarr(8,8)
se[*,*] = 1

for k=0,sz[2]-2 do begin	
	im1 = da[*,*,k]
	im2 = da[*,*,k+1]
	mean0 = (moment(im1[where(im1 ne 0)]))[0]
	mean1 = (moment(im2[where(im2 ne 0)]))[0]
	div = mean1/mean0
	im = da[*,*,k] * div
	diff[*,*,k] = da[*,*,k+1] - im
	diff[*,*,k] = fmedian(diff[*,*,k],5)
	mu = moment(diff[*,*,k], sdev=sdev)
	contour, diff[*,*,k], lev=mu[0]+0.2*sdev, path_info=info, path_xy=xy, /path_data_coords, /fill
	plot_image, sigrange(diff[*,*,k],frac=0.97)
	temp = fltarr(sz[0],sz[1])
	for c=0,no_contours[0]-1 do begin
		x = xy[0,info[c].offset:(info[c].offset+info[c].n-1)]
		y = xy[1,info[c].offset:(info[c].offset+info[c].n-1)]
		print, 'Plotting contours ', c
		plots, x, y, psym=3, color=0
		wait, 1
		index = polyfillv(x,y,sz[0],sz[1])
		temp[index] = 1
	endfor
	windows[*,*,k] = dilate(temp,se)
	dim[*,*,k] = windows[*,*,k]
	dim[where(dim eq 0)] = 0.5
	
	if keyword_set(mov) then mov[*,*,k] = tvrd()
endfor

if keyword_set(mov) then wr_movie, 'mov_diff', mov

end
