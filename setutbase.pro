PRO SETUTBASE, UTSTRING, error=error

;+
; Project:
;	SDAC    
; NAME: 
;	SETUTBASE
; Category:
;	UTPLOT, TIME
; Calls:
;	CHECKVAR, SETUT
;               
; PURPOSE: 
;	Set UTBASE variable in common UTCOMMON to the number of seconds
;  	   since 79/1/1, 0000 represented by the ASCII string passed as an 
;	   argument.
; CALLING SEQUENCE:
;	SETUTBASE,UTSTRING,ERROR=ERROR
; INPUT PARAMETERS:
;	UTSTRING - string in YY/MM/DD, HHMM:SS.XXX format to be converted
;	   to internal representation and stored in UTCOMMON variable UTBASE.
; KEYWORDS:
;	ERROR - 0/1 indicates no error/error in converting UTSTRING
; PROCEDURE:
;	Calls SETUT.  See SETUT.PRO program description.
; MODIFICATION HISTORY:
;	Written by Richard Schwartz, Feb. 1991
;-
on_error,2
checkvar, utstring, '-1'
setut, utbase=utstring, error=error
end
