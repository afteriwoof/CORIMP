;Code to sort the fls by their date for reading in to CME detections in order

; Created:	22-03-11	to sort files in order for run_algorithms_edges_tvscl to cal.
; Last edited:	27-05-11	to include str_count input for different filename lengths.
;		2012-11-16	to sort the new form of files, e.g., c2_lasco_soho_dynamics_yyyymmdd_hhmmss.fits.gz

function sort_fls, fls, str_count

;print, 'Sorting files in order of timestamps'

sz = size(fls,/dim)

ind = dblarr(sz)

n_par = n_params()

if n_par ne 2 then str_count = 25 ;or 28 for cme_model

for k=0,sz[0]-1 do begin
	if strpos(fls[k], '_lasco_soho_') ne [-1] then begin
		date = strmid(fls[k], strpos(fls[k],'_lasco_soho_')+21,8)
		date += strmid(fls[k], strpos(fls[k],'_lasco_soho_')+30,6)
	endif else begin
		if strpos(fls[k], 'IFAcorimp_lasco') ne [-1] then begin
			date = strmid(fls[k],strpos(fls[k],'IFAcorimp_lasco_')+str_count,12)
		endif else begin
			if strpos(fls[k], 'separated_lasco') ne [-1] then begin
				date = strmid(fls[k],strpos(fls[k],'separated_lasco')+str_count,12)
			endif else begin
				if strpos(fls[k], 'separated_secchi_') ne [-1] then begin
					date = strmid(fls[k],strpos(fls[k],'separated_secchi_')+str_count+1,12)
				endif else begin
					if strpos(fls[k], 'COR') ne [-1] then begin
						date = strmid(fls[k],strpos(fls[k],'COR')-14,12)
					endif else begin
						if strpos(file_basename(fls[k]),'CME_front_edges') ne [-1] then begin
							date = strmid(file_basename(fls[k]),strpos(file_basename(fls[k]),'CME_front_edges')+19,15)
							date = strjoin(strsplit(date,'_',/extract))
						endif else begin 
							print, '** Wrong filename input for sorting **'
							goto, jump
						endelse
					endelse
				endelse
			endelse
		endelse
	endelse
	year = strmid(date,0,4)
	mon = strmid(date,4,2)
	day = strmid(date,6,2)
	hh = strmid(date,8,2)
	mm = strmid(date,10,2)
	ss = strmid(date,12,2)
	date = year+'/'+mon+'/'+day+'T'+hh+':'+mm+':'+ss
	ind[k] = anytim(date)
endfor


return,fls[sort(ind)]

jump:

end
