;+
; PROJECT:
;	SSW
; NAME: 
;	ANYTIM_REPORT
;
; PURPOSE:
;	This routine checks the performance of anytim for all of its inputs and outputs.
;
; CATEGORY:
;	UTPLOT
;
; CALLING SEQUENCE:
;	
;
; CALLS:
;	none
;
; INPUTS:
;       Input - a time array to use for validation.
;
; OPTIONAL INPUTS:
;	none
;
; KEYWORD OUTPUTS:
;       MAXDIFF - maximum difference for Input for format i vs format j.
;	OUT - Text report.
;	
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	none
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	The input array is first converted to the ith output format, converted to seconds,
;	and the absolute value is taken vs the same for the jth format.
;	
;
; MODIFICATION HISTORY:
;	2 april 2001, richard.schwartz@gsfc.nasa.gov
;
;-
pro anytim_report, input, out=out, maxdiff=maxdiff

t = fcheck( input, dindgen(2, 20)*1e6)
 
out=['ints','stc','2xn','ex','utime','sec','atime','yohkoh','hxrbs','mjd','utc_int','utc_ext','ccsds','ecs','vms']
nout = n_elements( out )
maxdiff = fltarr( nout, nout )
for i=0,nout-1 do for j=0,nout-1 do begin
	ti = anytim(anytim(t,out=out[i]))
	tj = anytim(anytim(t,out=out[j]))
	if n_elements( ti ) ne n_elements( tj ) then help, i, j,'Unequal output vector lengths'
	maxdiff[i,j] = max( abs(ti - tj))
	endfor

help, t, out = input_report

out = ['ANYTIM REPORT - Test ANYTIM for '+strtrim(nout,2)+' formats, input vs output',$
	'Input variable: '+input_report,$
	'Maximum absolute difference is '+string(max(maxdiff)) ]
print,out,format='(a)'

end

