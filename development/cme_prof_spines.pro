; Created:	20111013	to take the cme_prof image (better off if smoothed) and plot only the mediam in the ROIs along each columns.
; CODE UNFINISHED!

pro cme_prof_spines, im

sz = size(im,/dim)

spines = intarr(sz[0],sz[1])

;for i=0,sz[1]-1 do begin
for i=0,0 do begin

	prof = im[i,*]
plot,prof	
	inds = where(prof gt 0)
	print,inds
	endpoints = inds[0]
	count = inds[0]
	inds_count = 0
	while count lt n_elements(prof) do begin
		plots, count+1, prof[count+1], psym=2, color=3
		plots, count, prof[count], psym=2, color=4
		if inds[inds_count+1]-inds[inds_count] eq 1 then begin
			count+=1
			inds_count+=1
		endif else begin
			endpoints = [endpoints,count,count+1]
			count+=1
		endelse
		pause
	endwhile


stop
	print, 'inds ', inds
	count_ind = 0.
	count = inds[count_ind]
	flag = 0
	while count lt n_elements(prof)-1 do begin
plots,count,prof[count],psym=2,color=3	
		if prof[count] eq 0 then begin
			endpoints = [endpoints,count]
plots,count,prof[count],psym=6,color=4
			flag = 1
			count_ind += 1
		endif
		if flag eq 1 then begin
			print, count_ind
			help,inds
			count = inds[count_ind]
			flag = 0
		endif else begin
			count += 1
		endelse
		print, 'count ', count
		pause
	endwhile

endfor

print, endpoints

end
