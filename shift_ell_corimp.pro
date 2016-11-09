; Code to work out the angular width of an ellipse when it actually crosses the 0/360 line.

; Created:	01-03-11	 from shift_ell.pro

function shift_ell_corimp, in, da, x_ell, y_ell, p

true=0
sz_da = size(da,/dim)
sz = size(x_ell,/dim)

	
;to see if the ellipse needs shifting, make masks of ellipse and 0/360 line and add.
res = polyfillv( [p[2], x_ell[0], x_ell[1]], [p[3], y_ell[0], y_ell[1]], sz_da[0], sz_da[1] )
for i=1,sz[0]-2 do begin
	res2 = polyfillv( [p[2], x_ell[i], x_ell[i+1]], [p[3], y_ell[i], y_ell[i+1]], sz_da[0], sz_da[1] )
	res = [res,res2]
endfor
ell_mask=fltarr(sz_da[0], sz_da[1])
ell_mask[res] = 1
plot_image, ell_mask
pause

line_mask = fltarr(sz_da[0],sz_da[1])
line_mask[in.xcen:sz_da[0]-1, in.ycen] = 1
plot_image, line_mask
pause

intersect = line_mask + ell_mask
if max(intersect) eq 2 then true=1

shade_surf, intersect
pause


return, true



end
