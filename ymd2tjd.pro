
;+
;Project:
;	SDAC    
;                   
;NAME: 
;	YMD2TJD
;      
;PURPOSE:
;	This function converts standard format times to truncated Julian day, 
;	returned in double precision floating point.  This is a standard
;	CGRO/BATSE time format.
;
;Category:
;	UTPLOT, TIME, BATSE
;       
;CALLS:
;	DATATYPE, ANYTIM
;CALLING SEQUENCE:
;       time = ymd2tjd( item, [,error=error])
;       time = ymd2tjd('1-jan-79')
;       print, time
;       ;3874.0
;
;INPUT:
;       Item    - The input time in any standard format accepted by ANYTIM
;	    TJD of 3874 is equivalent to 1-jan-1979 
;
;KEYWORDS:
;       ERROR   - set if there is an error in time conversion
;
;RESTRICTIONS:
;	limited to ANYTIM formats.
;HISTORY:
;	ras, 19-march-94, 
;MODIFIED:
;	 Version 2, documented RAS, 5-Feb-1997
;-

function ymd2tjd, item, error=error

on_error, 2
; Convert time to days since 1-jan-79 and then add TJD offset

return,   anytim( item, /sec, error=error) /  86400.d0 + 3874.0d0
end
