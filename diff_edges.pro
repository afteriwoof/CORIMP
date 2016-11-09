; Code to take the edges from the multiscale detections and overlay them on running difference

; Created: 06-01-09

pro diff_edges, da, edges, overlay, mov=mov

sz = size(da, /dim)

diff = dblarr(sz[0], sz[1], sz[2]-1)

for k=0,sz[2]-2 do begin
	im1 = da[*,*,k]
	im2 = da[*,*,k+1]
	mean0 = (moment(im1[where(im1 ne 0)]))[0]
	mean1 = (moment(im2[where(im2 ne 0)]))[0]
	div = mean1/mean0
	diff[*,*,k] = da[*,*,k-1] - (da[*,*,k]*div)

	ind = where(edges[*,*,k+1] gt 0)
	im1 = da[*,*,k+1]
	im1[ind] = 



end
