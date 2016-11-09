PRO SETUTEND,UTSTRING,error=error
; !quiet=1
on_error,2
;+
; NAME: 
;	SETUTEND
; PURPOSE: 
;	Set UTEND variable in common UTCOMMON to the number of seconds
;  	   since 79/1/1, 0000 represented by the ASCII string passed as an 
;	   argument.
; CALLING SEQUENCE:
;	SETUTEND,UTSTRING,ERROR=ERROR
; INPUT PARAMETERS:
;	UTSTRING - string in YY/MM/DD, HHMM:SS.XXX format to be converted
;	   to internal representation and stored in UTCOMMON variable UTEND.
;	ERROR - 0/1 indicates no error/error in converting UTSTRING
; PROCEDURE:
;	Calls SETUT.  See SETUT.PRO program description.
; MODIFICATION HISTORY:
;	Written by Richard Schwartz, Feb. 1991
;-
CHECKVAR,UTSTRING,'-1'
SETUT,UTEND=UTSTRING,error=error
RETURN
END
