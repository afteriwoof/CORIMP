; Trying to see if windowing out the CME in the modgrad images will work.

; Last Edited: 08-07-08

pro rundiff_canny_atrous, da, diff

sz = size(da, /dim)

diff = fltarr(sz[0], sz[1], sz[2])

canny_atrous2d, da[*,*,0], modinit

for k=0,sz[2]-2 do begin
	canny_atrous2d, da[*,*,k+1], modgrad
	diff[*,*,k] = modgrad[*,*,5] - modinit[*,*,5]	
endfor


end
