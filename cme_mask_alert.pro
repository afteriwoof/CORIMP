; Created	2014-01-08	to check a CME detection alert for whether the CME mask is a worthy CME alert or not (by mask area versus mask score).

; INPUTS	da		- the data image in question.
;		cme_mask_str	- the restore variable saved as CME_mask_str_C?_yyyymmdd_hhmmss.sav

; OUTPUT	score		- [area_score, mask_score]


function cme_mask_alert, da, cme_mask_str

mask = cme_mask_recover(cme_mask_str)

; area of field of view
fov_area = n_elements(where(da ne 0))
; area of cme detection mask
cme_area = n_elements(where(mask ne 0))
; fraction of area that cme is in is the score
area_score = cme_area / float(fov_area) * 100.
; mask score is the additive scores of the mask
mask_val = total(mask[where(mask ne 0)])

max_mask_score = 12.*fov_area

mask_score = mask_val / max_mask_score * 100.

;score = [area_score, mask_score]
score = mask_score

return, score

end
