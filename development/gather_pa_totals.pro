; Gather up the pa_total_yyyymmdd.sav files of each day and stack them (per month for example).

; Created:	18-04-11

; INPUTS:	pas - the file_search of the pa_total_yyyymmdd.sav

; OUTPUT:	pa_total_new - the gathered pa_totals of pas


pro gather_pa_totals, pas, pa_total_out

restore, pas[0]

pa_total_out = pa_total

i = 1

while i lt n_elements(pas) do begin
	sz1 = size(pa_total_out,/dim)
	restore, pas[i]
	sz2 = size(pa_total,/dim)
	new = fltarr(360, sz1[1]+sz2[1])
	new[*,0:(sz1[1]-1)] = pa_total_out
	new[*,sz1[1]:(sz1[1]+sz2[1]-1)] = pa_total
	pa_total_out = new
	delvarx, new
	i += 1
endwhile


end
