function minmax,array,extend=extend
;+
; NAME:
;	MINMAX
; PURPOSE:
;	Return a 2 element array giving the minimum and maximum of a vector
;	or array.  This is faster than doing a separate MAX and MIN.
;
; CALLING SEQUENCE:
;	value = minmax( array,extend=extend )
; INPUTS:
;	array - an IDL numeric scalar, vector or array.
;       extend - widens the region for extend % of its length
;
; OUTPUTS:
;	value = a two element vector, 
;		value(0) = minimum value of array
;		value(1) = maximum value of array
;
; EXAMPLE:
;	Print the minimum and maximum of an image array, im
; 
;         IDL> print, minmax( im )
;
; PROCEDURE:
;	The MIN function is used with the MAX keyword
;
; REVISION HISTORY:
;	Written W. Landsman                January, 1990
;-
 On_error,2
 Fin = where(finite(array))
 if Fin(0) ne -1 then amin = min( array(Fin), MAX = amax) else $
   return,[!values.f_nan,!values.f_nan] 
 if keyword_set(extend) then begin
     range = amax - amin
     amin = amin - range*extend
     amax = amax + range*extend
 endif
 return, [ amin, amax ]
 end
