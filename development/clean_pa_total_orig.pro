; Created	23-03-11	to remove the regions in pa_total that are too small

pro clean_pa_total, pa_total, thr ;thr being the allowed maximum angular width

sz = size(pa_total,/dim)
pa_mask = intarr(sz[0],sz[1])
pa_mask[where(pa_total gt 0)] = 1 ;binary

pa_mask = morph_open(pa_mask,[1,1])

hit = [1,1]
matches = intarr(sz[0], sz[1])

for k=4,thr-1 do begin & $
	miss = intarr(k,3) & $
	miss[*,*] = 1 & $
	miss[1:(k-2),1] = 0 & $
	matches += morph_hitormiss(pa_mask, hit, miss) & $
endfor

ind = where(matches gt 0)

if ind eq [-1] then goto, jump_end

init = morph_cc(pa_mask, ind[0])

for k=1,n_elements(ind)-1 do begin & $
	init += morph_cc(pa_mask, ind[k]) & $
endfor

init[where(init gt 0)] = 1
pa_mask -= init

pa_total *= pa_mask

jump_end:

end
