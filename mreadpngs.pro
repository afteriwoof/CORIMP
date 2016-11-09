pro mreadpngs, fls, edges

sz = size(fls, /dim)

init = read_png(fls[0])
sz_init = size(init, /dim)

edges = fltarr(sz_init[0], sz_init[1], sz[0])

for k=0,sz[0]-1 do begin
	edges[*,*,k] = flip(read_png(fls[k]))
endfor
print, 'flipping pngs'



end
