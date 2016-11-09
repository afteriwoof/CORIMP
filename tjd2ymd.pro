;+
;Project:
;       SDAC    
;NAME: 
;	TJD2YMD
;      
;PURPOSE: 
;	This function converts truncated Julian days to a standard time format.
;	TJD is a CGRO/BATSE standard numerical internal format.
;CATEGORY:
;       UTPLOT, TIME, BATSE
;       
;	       
;CALLING SEQUENCE:
;       time = tjd2ymd( item, [,seconds=seconds, string=string, error=error])
;       time = tjd2ymd(3874)
;       print, time
;       ;1-jan-79
;
;INPUT:
;       Item    - The input time in Truncated Julian Day
;	    TJD of 3874 is equivalent to 1-jan-1979 
;                 Form can be scalar or vector integer, long, float, double 
;OUTPUT:
;	The function returns the time in seconds from 1-jan-1979, ANYTIM 
;	format.
;
;CALLS:
;	DATATYPE, ANYTIM
;KEYWORDS:
;	OPTIONAL INPUT:
;       SECONDS -  added to input days
;       STRING  - if set, output is in string format
;                 output is truncated to the calendar date if time is at midnight.
;      
;	OUTPUT:
;       ERROR   - set if there is an error in time conversion
;
;RESTRICTIONS:
;	limited to output strings covered by ATIME.pro
;
;HISTORY:
;	ras, 19-march-94, 
;
;MODIFIED:
;        Version 2, documented RAS, 5-Feb-1997
;-
;
function tjd2ymd, tjd,  seconds=sec, string=strng,  error=error

error = 0
dtype = datatype(tjd(0))

if dtype ne 'DOU'  and  dtype ne 'FLO'  and dtype ne 'LON'  and dtype ne 'INT' $
	then begin 
		error=1
		print, 'Error in input format, type = ', dtype
		print, 'Argument to TJD2YMD must be numerical.'
		return, tjd
	endif	

ut = (tjd - 3874.) * 86400. 
if keyword_set( sec) then ut = ut + sec
if keyword_set(strng) then begin
	utd = anytim( ut, /date, error=error)
	wd = where( ut ne utd, nwd)
	if nwd eq 0 then ut = atime(utd , /date, err=error)  $;can just use calendar string, no seconds
		else  ut = atime(ut, error=error)
endif

return, ut
end
