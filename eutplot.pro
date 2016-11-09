PRO EUTPLOT,X0, Y, Z, XST0, unc=unc, width=width,      $
        xerr=xerr,yerr=yerr,_extra=extra
;+
; NAME:
;	EUTPLOT
; PURPOSE:
;	Plot error bars on previously (using UTPLOT) drawn plot with
;	universal time labelled X axis.  If start and end times have been
;	set, only data between those times is displayed.
; CATEGORY:
; CALLING SEQUENCE:
;	EUTPLOT,X,Y,Z
;	EUTPLOT,X,Low,High
;	EUTPLOT,X,Y,UNC,/unc
;	EUTPLOT,X,Low,High,XST
; INPUTS:
;       X -     X array to plot in seconds relative to base time.
;               Structures allowed
;	LOW,HIGH - Vectors of Low and High Values
;   or
;       Y,UNC,/UNC - Will convert to LOW=Y-UNC, HIGH=Y+UNC
;		     UNC must be a vector of the same length as Y or a scalar.
;       xst -	Optional. The reference time to use for converting a structure
;		into a seconds array. IMPORTANT - this should not be
;		used since it will use the start time that was defined in the
;		plot command.  It is necessary if the X input is an in seconds
;		already and the reference time is not the same as that used by
;		the UTPLOT base time.
; OPTIONAL INPUT PARAMETERS:
;	UNC	=  If set, will assume that the Y and UNC were passed in.
;	WIDTH	=  Width of the error bars horizontal flags in units of
;		   the fractional plot width  (def=0.01).  Set width=0. to
;		   draw simple vertical bars.
; OUTPUTS:
;	None.
; OPTIONAL OUTPUT PARAMETERS:
;	None.
; KEYWORDS:
;       XERR,YERR = arrays of X and Y errors
; COMMON BLOCKS:
;	UTCOMMON
; SIDE EFFECTS:
;	Over plots uncertainties.
; RESTRICTIONS:
;	Can only be used after issuing UTPLOT command.
; PROCEDURE:
;	Calls errplot.
; MODIFICATION HISTORY:
; 18-dec-93, J. R. Lemen, Written (based on outplot by Tolbert/Schwartz/Morrison)
; 13-feb-95, JMM, JRL Uncertainty may be passed in as a scalar or a vector if
;		      the /unc keyword is set.
; 29-mar-95, JMM, Enable input time to be a 7-element external format
; 5-jun-1998, richard.schwartz@gsfc, use anytim() to prep time inputs.  This should allow
;	this routine to be run anywhere in SSW.
; 1-jul-1998, Zarro (SAC/GSFC), enhanced with OPLOTERR
; 1-Oct-1998, Zarro (SMA/GSFC), added keyword inheritance
;-

on_error,2			; Return to caller if there is a problem
COMMON UTCOMMON, UTBASE, UTSTART, UTEND, xst_plot

err_entered=exist(xerr) or exist(yerr)
if n_params() lt 3 then begin
 if not err_entered then begin
  message, 'Must supply time,low,high arguments',/cont
  return
 endif
endif

if (keyword_set(unc)) then begin ;jmm, 12-feb-95, allow Z to be a scalar
   if (n_elements(X0) lt 2) or (n_elements(Y) lt 2) then $
     message, 'Check that X0, Y are vectors of length ge 2'
   if (n_elements(z) ne n_elements(y) and (size(z))(0) ne 0) THEN $
     message, 'Z must have the same number of elements as Y or be a scalar'
endif else begin
   if not err_entered then begin
    if (n_elements(X0) lt 2) or (n_elements(Y) lt 2) or (n_elements(Z) lt 2) then begin
     message,'Check that X0, Y, Z are vectors of length ge 2',/cont
     return
    endif
   endif
endelse

if (n_elements(xst0) ne 0) then begin
    ex2int, anytim2ex(xst0), xst_msod, xst_ds79
    xst = [xst_msod, xst_ds79]
    off = int2secarr(xst, xst_plot)
    off = off(0)	;convert to scalar
end else begin
    xst = xst_plot	;use the value that was used for UTPLOT
    off = 0
end

siz = size(x0)
typ = siz( siz(0)+1 )
x   = anytim(x0, /ints)	    ;-- this allows all SSW time formats! (RAS added)

if (typ eq 8 or siz(0) eq 2 or typ eq 7) then x = int2secarr(x, xst) else x = x0 + off ;jmm, 29-mar-95


;if keyword_set(unc) then 		$
;   errplot,x,y-z,y+z,width=width else	$	; User passed in y, unc
;   errplot,x,y,z,width=width			; User passed in Low, High

;-- call OPLOTERR in a backward compatible way (DMZ added)

if exist(xerr) then begin
 err_x=',xerr' 
 np=n_elements(x)
 if n_elements(xerr) ne np then xerr=replicate(xerr(0),np)
endif else err_x=''

if exist(z) then err_y=',z' else begin
 if exist(yerr) then err_y=',yerr'
endelse

if keyword_set(unc) or err_entered then begin
 if not exist(err_y) then begin
  message,'Y-uncertainties are required',/cont
  return
 endif
 stat='oploterr,x,y'+err_x+err_y+',_extra=extra,hatlength=width'
 s=execute(stat)
endif else begin
 if exist(y) and exist(z) then begin
  errplot,x,y,z,width=width,_extra=extra
 endif
endelse

return & end
