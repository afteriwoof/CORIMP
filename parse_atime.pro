;+
; Project     : SDAC    
;                   
; Name        : PARSE_ATIME
;               
; Purpose     : This procedure parses a time in any of the allowed 
;		formats and returns year, month, day, hour, minutes, 
;		and/or seconds depending on which keyword parameters
;		have been passed.  If the keyword STRING is set, 
;		the values are returned as strings, otherwise as numbers.
;
;               
; Category    : UTPLOT, TIME 
;               
; Explanation : Input is converted to HXRBS format and quantities
;		extracted by position in string using STRMID.
;               
; Use         : 
;    
; Inputs      : Time- Time in format handled by ANYTIM.PRO
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : YEAR   - Integer years, last two digits only.
;		MONTH  - Integer months.
;		DAY    - Integer days.
;		HOUR   - Integer hours, ZULU.
;		MIN    - Integer minutes.
;		SEC    - Seconds, including fractions
;		STRING - If set, return numbers as strings.
;		ERROR  - Set if ANYTIM fails.
;
; Calls       : ANYTIM
;
; Common      : None
;               
; Restrictions: 
;               
; Side effects: None.
;               
; Prev. Hist  : Written by Kim Tolbert, 3/5/92
;
;
; Modified    : Version 2,  
;		1/11/94 by AKT to allow any kind of time as 
;		input (previously required an ASCII time), and call 
;		anytim instead of atime.
;		Version 3, RAS, 5-feb-1997 documentation header
;-            
;==============================================================================


pro parse_atime, time, year=year, month=month, day=day, hour=hour, min=min, $
    sec=sec, string=string, error=error
;
on_error, 2
at = anytim(time, /hxrbs, error=error)
if error then goto,getout
;
; Extract the value
; 
year = strmid (at, 0, 2)
month = strmid (at, 3, 2)
day = strmid (at, 6, 2)
hour = strmid (at, 10, 2)
min = strmid (at, 13, 2)
sec = strmid (at, 16, 6)
;
;if user asked for strings, return.  Otherwise convert to numbers.
if keyword_set(string) then goto, getout
year = year * 1
month = month * 1
day = day * 1
hour = hour * 1
min = min * 1
sec = sec * 1.
;
getout:
end
