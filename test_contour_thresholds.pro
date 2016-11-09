; Created:	28-07-11

; Input		-	mod1:	individual image 

pro test_contour_thresholds, mod1, sdev_factor, no_contours, err, mask, mu, sdev

err = 1

sz = size(mod1,/dim)

nonzero_inds = where(mod1 gt 0)

mu = moment(mod1[nonzero_inds],sdev=sdev)

contour, mod1, lev=mu[0]+sdev_factor*sdev, path_xy=xy, path_info=info, /path_data_coords, closed=0

if n_elements(info) gt 1 then lim = n_elements(info)-1 else goto, jump1
if lim gt no_contours then lim = no_contours

mask = intarr(sz[0],sz[1])

for i=0,lim do begin

	x = xy[0,info[i].offset:(info[i].offset+info[i].n-1)]
	y = xy[1,info[i].offset:(info[i].offset+info[i].n-1)]

	res = polyfillv(x,y,sz[0],sz[1])

	if res ne [-1] then begin
		mask[res] = 1
		mask = morph_close(mask,replicate(1,3,3))
		mask = fix(mask)
	endif

endfor

err = 0

jump1:

end
