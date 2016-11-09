; Created	20120222	to redo clean_pa_total.pro

; Last edited	2014-02-21	to jump_end if the input is so small.

; Take the output final_pa_mask and multiply it by the input pa_total to determine the cleaned pa_total.

pro clean_pa_total_gail, pa_total, final_pa_mask, debug=debug

if keyword_set(debug) then begin
	print, '***'
	print, 'clean_pa_total.pro'
	print, '***'
	pause
endif

sz = size(pa_total, /dim)
if n_elements(sz) le 1 then begin
	final_pa_mask = intarr(sz[0],1)
	goto, jump_end
endif
if where(sz lt 3) ne [-1] then begin
	final_pa_mask = intarr(sz[0],sz[1])
	goto, jump_end
endif

;padding image
pa_mask = intarr(sz[0]+14,sz[1]+14)
pa_mask[7:sz[0]+7-1, 7:sz[1]+7-1] = pa_total
if where(pa_mask gt 0) ne [-1] then pa_mask[where(pa_mask gt 0)] = 1 ;binary
pa_mask_orig = pa_mask

; Dilate by a pixel in both directions horizontally and vertically
se = intarr(3,3)
se[*,*] = 1
pa_mask = dilate(pa_mask, se)

; Perform hitormiss on dilated sizes up to limit of <7pixels wide (i.e. <7degrees ang. width).
for count=3,8 do begin

	hit = intarr(count,3)
	hit[*,*] = 1

	miss = intarr(count+2,5)
	miss[*,*] = 1
	miss[1:count,1:3] = 0

	matches = morph_hitormiss(pa_mask, hit, miss)
	matches = dilate(matches, hit)

	pa_mask -= matches

endfor

; erode it back to where it was
final_pa_mask = erode(pa_mask, se)

; Take out the non-padded region again.
final_pa_mask = final_pa_mask[7:sz[0]+7-1, 7:sz[1]+7-1]

; Now perform clause to remove any regions that haven't been grouped with at least 2 other regions.

labels = label_region(final_pa_mask)
sz_labels = size(labels,/dim)

for i=1,max(labels) do begin
	label_unique = intarr(sz_labels[0],sz_labels[1])
	label_unique[where(labels eq i)] = 1
	test_regions = label_unique * pa_total
	if max(label_region(test_regions)) lt 3 then final_pa_mask -= label_unique
endfor

jump_end:


end
