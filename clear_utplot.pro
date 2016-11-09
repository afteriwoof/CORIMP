pro clear_utplot, no_utbase=no_utbase
;+
; NAME:
;	CLEAR_UTPLOT
; PURPOSE:
;	Restores plotting structures !x and !y to their values prior to calls to
;	SET_UTPLOT or UTPLOT.. 
; CALLING SEQUENCE:
;	CLEAR_UTPLOT
; KEYWORD INPUTS:
;	NO_UTBASE - Don't clear UTBASE from common.  Useful for datasets where
;	the data is relative to the base and only the plot limits need clearing.
; COMMON BLOCKS:
;       COMMON CLEARCOMMON,XOLD,YOLD,CLEARSET = holding area for previous
;	!x and !y structures if clearset=1
;	common utcommon - utbase,utstart,utend,xst
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	Restores structures !x and !y and resets the common variable CLEARSET.  
;	Next call to SET_UTPLOT will again store !x and !y.
;	Call CLEAR_UTPLOT if execution stops in the middle of any UTPLOT 
;	package calls to clear plotting structures !x and !y.
; MODIFICATION HISTORY:
;	Written by Richard Schwartz for IDL Version 2   91/02/17
;       20-Aug-92 (MDM) Added clearing UTBASE, UTSTART and UTEND
;        1-Nov-92 (DMZ) Added check that xold and yold exist
;       17-Mar-93 (MDM) Set !quiet=0 instead of =1
;	16-nov-93 removed !quiet
;	27-jan-1998, richard.schwartz@gsfc.nasa.gov, added NO_UTBASE keyword.
;-
on_error,2
@utcommon
common clearcommon,xold,yold,clearset
clearset=1 ; !variables can be saved again in set_utplot
if n_elements(xold) ne 0 then !x=xold
if n_elements(yold) ne 0 then !y=yold

if not keyword_set(no_utbase) then $ ;richard.schwartz added 27-jan-1998
	utbase = 0      ;MDM added 20-Aug-92
utstart = 0     ;MDM added 20-Aug-92
utend = 0       ;MDM added 20-Aug-92

end
