FUNCTION utplot_UTIME,UTSTRING,ERROR=ERROR
on_error,2
!quiet=1
;+
; NAME:
;	utplot_UTIME
; PURPOSE:
;	Function to return time in seconds from 79/1/1,0000 corresponding to
;       the ASCII time passed in the argument.
; CATEGORY: 
; CALLING SEQUENCE: 
;	RESULT = utplot_UTIME(UTSTRING,/ERROR)
; INPUTS:
;	UTSTRING -	String containing time in form YY/MM/DD,HHMM:SS.XXX
;	ERROR -		=0/1. If set to 1, there was an error in the ASCII
;			time string.
; OUTPUTS:
;	Double precision time in seconds since 79/1/1, 0000.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;       If just a time is passed (no date - detected by absence of slash
;       and comma in string), then just the time of day is converted to 
;	seconds relative to start of day and returned.  If date and time 
;	are passed, then day and time of day are converted to seconds and 
;	returned.  In other words, doesn't 'remember' last date used if 
;	no date is specified.
; PROCEDURE:
;	Parses string into component parts, i.e. YY,MM,DD,HH,MM,SS.XXX,
;	converts the strings into double precision seconds, and sums them.
; MODIFICATION HISTORY:
; 	Written by Kim Tolbert 7/89
;	Modified for IDL Version 2 by Richard Schwartz Feb. 1991
;	Corrected RAS 91/05/02, error should be initialized to 0
;	15-Nov-91 (MDM) Renamed from UTIME to UTPLOT_UTIME to avoid
;			conflict with existing routine
;-
error = 0  ; initialize to no error
; check that argument is a scalar string, if not pass back an error
s=size (utstring)
if (s(0) ne 0) or (s(1) ne 7) then goto,errorlog
;if publication format then 'YY/MM/DD, HH:MM:SS.XXX
test=UTSTRING
;Look for comma, slashes, colons, and periods
c1=strpos(test,',')
b1=strpos(test,'/')
c2=strpos(test,':')
pub=0 ;ASSUME NON-PUBLICATION FORMAT, i.e. only one colon.
c3=-1
if c2 ge 0 then c3=strpos(test,':',c2+1)
if c3 ge 0 then pub=1 ;PUBLICATION FORMAT
p1=strpos(test,'.')
IF (P1 GE 0) AND (C2 EQ -1) THEN GOTO,ERRORLOG ;INDETERMINATE FORMAT
IF (C1 GE 0) AND (B1 EQ -1) THEN GOTO,ERRORLOG
tlng=strlen(test)
IF (B1 GT 0) THEN BEGIN
	if c1 gt 0 then lng=c1 else lng=tlng
	YMD2SEC,ymd=strmid(test,0,lng),sec=ymdsec,error=error
ENDIF ELSE ymdsec=0.0D0
if error then goto,errorlog ;IF YY, MM, or DD out of range
;ANYTHING AFTER THE YMD
;CONVERT HH AND MM TO SECONDS
IF (C1 GT 0) or (B1 EQ -1) THEN BEGIN
	IF NOT PUB THEN BEGIN
		if c2 gt 0 then lng=c2 else lng=tlng
		hhmm=fix(strmid(test,c1+1,lng-c1-1))
		hh=hhmm/100
		mm=hhmm mod 100
	ENDIF ELSE BEGIN ;PUBLICATION FORMAT, must two colons or ambiguous
		hh=fix(strmid(test,c1+1,c2-c1-1))
		mm=fix(strmid(test,c2+1,c3-c2-1))
	ENDELSE
	if (hh lt 0) or (hh gt 23) then goto,errorlog
	if (mm lt 0) or (mm gt 59) then goto,errorlog
	hhmm = hh*3600.d0 + mm*60.d0
ENDIF ELSE hhmm=0.0d0
if not pub then $
	IF C2 GT 0 THEN sec=float(strmid(test,c2+1,tlng-c2-1)) ELSE sec=0.0 $
else	sec=float(strmid(test,c3+1,tlng-c3-1))
return, ymdsec+hhmm+sec
errorlog:
;PRINT,'ERROR = ',ERROR
error = 1
print,'Error. Format for time is YY/MM/DD, HHMM:SS.SSS
end
