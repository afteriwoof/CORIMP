; code to take data array and just subtract a pre-event image (base difference)

; Created: 27-11-08

pro base_diff, in, da, diff

sz = size(da, /dim)

diff = fltarr(sz[0], sz[1], sz[2]-1)

for k=0,sz[2]-2 do diff[*,*,k] = da[*,*,k+1] - da[*,*,0]



end
