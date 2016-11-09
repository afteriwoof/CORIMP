; Taking out the 7th step for ease of programming.

; Last Edited: 12-10-07

pro combined_thr_step7, in, da, modgrads, dilations, se

sz_da = size(da, /dim)
frontmasks = fltarr(sz_da[0], sz_da[1], sz_da[2])

for k=1,sz_da[2]-1 do begin
	im = rm_inner(dilations[*,*,k], in[k], dr_px, thr=2.2)
	im = rm_outer(im, in[k], dr_px, thr=7.3)
	thr=1
	contour, im, lev=thr, path_xy=xy, path_info=info, /path_data_coords
	x = xy[0,info[0].offset:(info[0].offset+info[0].n-1)]
	y = xy[1,info[0].offset:(info[0].offset+info[0].n-1)]
	frontmask = fltarr(sz_da[0],sz_da[1])
	index=polyfillv(x,y,sz_da[0],sz_da[1])
	frontmask[index] = 1
	frontmasks[*,*,k] = erode(frontmask,se)	                
	;thinned[*,*,k] = m_thin(frontmask)			                
	;index = where(thinned[*,*,k] eq 1)	
	;res = array_indices(thinned[*,*,k], index)
	plot_image, sigrange(da[*,*,k])
	
	ellipse_mpfit_rads, x, y, in[k], da[*,*,k], frontmask*modgrads[*,*,k], xpeak, ypeak

	ellipse_mpfit, xpeak, ypeak, in[k], da[*,*,k]

endfor	

end
