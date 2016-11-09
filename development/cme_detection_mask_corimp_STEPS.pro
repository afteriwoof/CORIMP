;Created	09-05-11

pro cme_detection_mask_corimp_STEPS, in, da, modgrad, alpgrad

sdev_factor = 1.5
no_contours = 5 ;don't expect either a CME to be broken up more than that, or for more than 5 distinct CMEs to be present.
new_contours = no_contours

sz_mod = size(modgrad,/dim)

for s=0,sz_mod[2]-1 do begin & $
	
	mod1 = modgrad[*,*,s]
	alp1 = alpgrad[*,*,s]

	nonzero_inds = where(mod1 gt 0)

	mu = moment(mod1[nonzero_inds], sdev=sdev)

	thresh = mu[0] + sdev_factor*sdev

	contour, mod1, lev=thresh, path_xy=xy, path_info=info, /path_data_coords

	mask = bytarr(1024,1024)

	while size(info,/dim) lt new_contours do new_contours-=1
	
	for c=0,new_contours-1 do begin
		x = xy[0,info[c].offset:(info[c].offset+info[c].n-1)]
                y = xy[1,info[c].offset:(info[c].offset+info[c].n-1)]
                ind = polyfillv(x,y,sz[0],sz[1])
                if ind ne [-1] then mask[ind] = 1
        endfor
	delvarx, ind
	



