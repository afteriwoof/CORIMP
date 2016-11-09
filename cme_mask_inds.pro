; Created:	2013-02-13	to save out only the index arrays of the non-zero locations in cme_mask

; Last edited:	2013-02-25	from Huw's email to use pointers instead of strutures alone.

function cme_mask_inds, cme_mask

mx = max(cme_mask)

for i=1,mx do begin
	indexnow = where(cme_mask eq i, count)
	if count ne 0 then begin
		if n_elements(cmeptr) eq 0 then begin
			cmeptr = ptr_new(indexnow)
			npoints = count
		endif else begin
			cmeptr = [cmeptr, ptr_new(indexnow)]
			npoints = [npoints, count]
		endelse
	endif
endfor

if n_elements(cmeptr) eq 0 then return, -1

sz = size(cme_mask,/dim)
cme_mask_str = {size:sz, npoints:npoints, cmeptr:cmeptr}

return, cme_mask_str

end
