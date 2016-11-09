; Created	2014-01-02	to gather the single file pa_slice outputs from run_automated_realtime_alert.pro into a single daily pa_total.

; Last edited	2014-06-12	to save out the det_stack
;		2014-06-18	to fix the plots_list 

; INPUT:	-	files of pa_slices to join together

; OUTPUT:	-	pa_total


pro gather_pa_slices_gail_realtime, in_date, det_stack

pa_fls = file_search(in_date+'/pa_slices/*')
restore, pa_fls[0]

pa_total = pa_slice

datetime_fls = strmid(file_basename(pa_fls),12,15)
fits_filenames = file_search('/home/gail/jbyrne/realtime/soho/lasco/separated/fits/'+strmid(in_date,strlen(in_date)-10,10)+'/*fits.gz')

for ii = 0,n_elements(fits_filenames)-1 do begin
	tmp = strmid(file_basename(fits_filenames[ii]),23,15)
	if where(pa_fls eq tmp) ne 0 then begin
		if n_elements(gather_filenames) eq 0 then begin
			gather_filenames = fits_filenames[ii] 
			gather_date_obs = strmid(tmp,0,4)+'/'+strmid(tmp,4,2)+'/'+strmid(tmp,6,2)+' '+strmid(tmp,9,2)+':'+strmid(tmp,11,2)+':'+strmid(tmp,13,2)
		endif else begin
			gather_filenames = [gather_filenames,fits_filenames[ii]]
			gather_date_obs = [gather_date_obs, strmid(tmp,0,4)+'/'+strmid(tmp,4,2)+'/'+strmid(tmp,6,2)+' '+strmid(tmp,9,2)+':'+strmid(tmp,11,2)+':'+strmid(tmp,13,2)]
		endelse
	endif
endfor


i = 1
plots_list = -1
while i lt n_elements(pa_fls) do begin
	sz1 = size(pa_total, /dim)
	restore, pa_fls[i]
	sz2 = size(pa_slice, /dim)
	new = fltarr(360,i+1)
	new[*,0:i-1] = pa_total
	new[*,i] = pa_slice
	pa_total = new
	delvarx, new
	if max(pa_slice) gt 0 then begin
		if plots_list eq [-1] then plots_list = i else plots_list = [plots_list, i]
	endif
	i += 1
endwhile

det_stack = {filenames:gather_filenames,date_obs:gather_date_obs,stack:pa_total,list:plots_list}

end
