;Code to sort the fls by their date for reading in to CME detections in order

; Created:	22-03-11	to sort files in order for run_algorithms_edges_tvscl to cal.
; Last edited:	27-05-11	to include str_count input for different filename lengths.
;		2013-07-12	by Huw to work with calling filename2date.

function sort_fls, fls

print, 'Sorting files in order of timestamps'

sz = size(fls,/dim)
if sz gt 1 then begin
	index = dblarr(sz)
	fb=file_basename(fls)
	for k=0,sz[0]-1 do index[k]=anytim2tai(filename2date(fb[k]))
	
	return,fls[sort(index)]
endif else begin
	return, fls
endelse

end
