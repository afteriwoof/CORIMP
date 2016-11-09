;Code to find the outer higest peak of a profile.

;INPUT: prof - the profile to be inspected

;OUTPUT: globalpeak - the outermost peak
;	prof_loc - the location of globalpeak

; Created: 17-02-11

pro find_outer_peak_edges, prof, prof_loc, plots=plots

if where(prof lt 0) ne [-1] then prof[where(prof lt 0)] = 0

found_peak = 0
prof_loc = 0
if keyword_set(plots) then plot, prof, psym=-1, linestyle=1

for ii=2,n_elements(prof)-1 do begin
	
	if keyword_set(plots) then plots, n_elements(prof)-ii, prof[n_elements(prof)-ii], psym=2

	outerpoint = prof[n_elements(prof)-ii+1]
	thispoint = prof[n_elements(prof)-ii]
	innerpoint = prof[n_elements(prof)-ii-1]

	
	if thispoint gt outerpoint && thispoint gt innerpoint then begin
		if found_peak ne 1 then begin
			if keyword_set(plots) then begin
				set_line_color
				plots, n_elements(prof)-ii, prof[n_elements(prof)-ii], psym=2, color=4, thick=3
			endif
			prof_loc = n_elements(prof)-ii
			if keyword_set(plots) then begin
				horline, prof[n_elements(prof)-ii]
			endif
			found_peak = 1
		endif
	endif

	delvarx, outerpoint, thispoint, innerpoint

endfor	


end
