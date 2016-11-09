; Code to take the steps from REDUCE_LEVEL_!.pro and perform them individually myself.

pro my_C3_reduce_level_1, fls

szfls = size(fls, /dim)

init = lasco_readfits(fls[0])

sz = size(init, /dim)

da = fltarr(sz[0], sz[1], szfls)
sz = size(da, /dim)
delvar, szfls

calibda = fltarr(sz[0], sz[1], sz[2])

for k=0,sz[2]-1 do begin
	calibda[*,*,k] = c3_calibrate(da[*,*,k], in[k])
endfor









end
