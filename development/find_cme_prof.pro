; Created:	20111013	to find the regions corresponding to CME tracks in the cme_prof output from find_pa_heights_all_redo.pro

pro find_cme_prof, cme_prof

sm_fac = 10 ;smoothing factor

im = smooth(cme_prof,sm_fac)

sz = size(im, /dim)

im = im[(sm_fac/2):(sz[0]-(sm_fac/2)-1),(sm_fac/2):(sz[1]-(sm_fac/2)-1)]

sz_im = size(im,/dim)

mu = moment(im)

for i=0,9 do begin

	contour, im, lev=(10-i), path_xy=xy, path_info=info, /path_data_coords

	mask = intarr(sz_im[0],sz_im[1])

	for contour_count=0,n_elements(info)-1 do begin
	
		x = xy[0,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
		y = xy[1,info[contour_count].offset:(info[contour_count].offset+info[contour_count].n-1)]
		
		ind = polyfillv(x,y,sz_im[0],sz_im[1])
	
		mask[ind] = 1

		

	endfor

	res = label_region(mask)

	plot_image, res

	pmm, res

	for i=1,max(res) do begin
	
		single = intarr(sz_im[0],sz_im[1])
		single[where(res eq 1)] = 1
	


	pause	


endfor

end
