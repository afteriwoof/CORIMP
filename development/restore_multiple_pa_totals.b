restore,fls[0]
pat = pa_total
for i=1,n_elements(fls)-1 do begin & $
sz = size(pat,/dim) & $
restore,fls[i] & $
pa_totals = dblarr(sz[0],sz[1]+(size(pa_total,/dim))[1]) & $
pa_totals[*,0:sz[1]-1] = pat & $
pa_totals[*,sz[1]:*] = pa_total & $
pat = pa_totals & $
endfor
