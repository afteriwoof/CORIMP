;Code to find the outer higest peak of a profile, i.e., the outermost peak where the next peak in is lower.

;INPUT: prof - the profile to be inspected

;OUTPUT: globalpeak - the outermost peak
;	prof_loc - the location of globalpeak

; Created: 31-01-11

pro find_outer_peak, prof, prof_loc, globalpeak

peak_count = 0
globalpeak_set = 0
prof_loc = 0

for k=2,n_elements(prof)-1 do begin
	
	;plots, n_elements(prof)-k, prof[n_elements(prof)-k], psym=2

	;wait, 0.05

	outerpoint = prof[n_elements(prof)-k+1]
	thispoint = prof[n_elements(prof)-k]
	innerpoint = prof[n_elements(prof)-k-1]

	if globalpeak_set ne 1 then begin
		if thispoint gt outerpoint && thispoint gt innerpoint then begin
			;print, thispoint
			plots, n_elements(prof)-k, prof[n_elements(prof)-k], psym=2, color=4
			if peak_count eq 0 then begin
				localpeak = thispoint
				prof_loc = n_elements(prof)-k
				peak_count = 1
			endif else begin
				if thispoint gt localpeak then begin
					localpeak = thispoint
					prof_loc = n_elements(prof)-k
				endif else begin
					globalpeak = localpeak
					;print, 'stop now: globalpeak ', globalpeak
					;horline, globalpeak
					globalpeak_set = 1
					;pause
				endelse
			endelse
		endif
	endif

endfor	


end
