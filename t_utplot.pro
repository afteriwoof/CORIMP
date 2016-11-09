pro t_utplot, x0, xplot=x, xrange=xrange, xstart=xst, utbase=utbase, timerange=timerange, $
    base_time=base_time, ordinate=ordinate
;+
;
; NAME: t_utplot
;
;
; PURPOSE:
;   Given the input time vector, x0, prepare the time variable, xplot, for utplot.
;   Put it in a standard form, seconds from 79/1/1, set the plot range, xrange,
;   determine the plot reference time, xstart, and decide whether utbase needs to
;   be set or changed.
;
; CATEGORY: Graphics
;
;
; CALLING SEQUENCE: t_utplot, x0, xplot=x, xrange=xrange, xstart=xst, utbase=utbase, $
;      timerange=timerange
;
;
; CALLED BY: utplot, set_utplot
;
;
; CALLS TO: anytim
;
; INPUTS:
;   x0 - time axis variable in any accepted anytim format
;   utbase - current value of utbase
;   xstart - current value of plot reference time
;   timerange - xrange specified with two fully referenced times
;   base_time - passed reference time for double precession seconds time array
;   ordinate - keyword used to pass the ordinate of the plot to anytim
;     used to determine whether time is in 2xN or 7xN longword format or
;     if it is to be interpreted as seconds from the fiducial (default 1-jan-1979)
;
; OUTPUTS:
;   xrange - plot range relative to xstart
;   utbase
;   xstart
;
; MODIFICATION HISTORY:
;   pulled from utplot and set_utplot, ras- 5-jan-94
;   xst is set to a yohkoh time format (external 7xn Int2) prior to return, ras, 25-jan-94
;    2-May-94 (MDM) - Patch since sometimes the xrange is passed to this
;        routine and sometimes the full x-vector is passed
;    3-May-94 (MDM) - Expanded conditional to call ANYTIM if the input is
;        a structure (even if only two elements)
;    4-May-94 (MDM) - Removed 2-May and 3-May patches.  The problem was
;        elsewhere.
;       31-may-95 (SLF) - per RAS, ensure TIMERANGE is used as plot reference
;   28-Feb-00 (Kim) - only use TIMERANGE passed in if both values are not zero.
;       10-Mar-00 (SLF) - update 28-feb change to permit TIMERANGE structures
;                         AND strings....(2nd 10-mar update)
;   23-May-05 (Kim) - use dblarr, not fltarr for xrange
;   06-Jan-06 richard.schwartz@gsfc.nasa.gov, added ORDINATE keyword
;	4-aug-2008, ras, abs added
;-

case 1 of
  n_elements(timerange) ne 2:  timerange_passed=0
  data_chk(timerange,/struct,/string): timerange_passed=1
  else: timerange_passed=total(abs(timerange)) gt 0  ;	4-aug-2008, ras, abs added
endcase


;   Fully reference all times immediately to seconds from 1-jan-1979 00:00:00.000
;   First convert the time to this format and determine whether the base time is needed.  If it
;   is needed, then add it.x = anytim( x0, /utime) ;convert utime format, seconds since 79/1/1
;
x = x0
x = (anytim( x, /utime, ordinate=ordinate))(*)
typ = datatype( x0(0) )
dims = size( x0)
;;if (n_elements(x) gt 2) or (typ eq 'STC') then x = (anytim( x, /utime))(*)        ;MDM added conditional 2-May-94

;
;Interpret double precision seconds array
;       one dimensional or scalar longwords will be interpreted as
;       double precision seconds unless they have either two or seven
;       elements
;
sec_passed = 0  ;boolean variable, if set, then seconds array passed

;Looking for time in utime format, nominally double precision seconds
;   but being kind to improper calls using float or integers
;   if they don't look like the 2xn or 7xn formats.
;
if (typ eq 'DOU' or typ eq 'FLO') or $
   ( (typ eq 'INT' or typ eq 'LON') and ( (n_elements(x) eq 1) or $
         (dims(0) eq 1 and (dims(1) ne 2 and dims(1) ne 7)))) then begin
    if n_elements(base_time) eq 0 and n_elements(utbase) eq 0 then begin
       setutbase
    endif
    if n_elements(base_time) eq 0 and n_elements(utbase) ne 0 then $
       base_time = (anytim(utbase,/utime))(0)
    sec_passed = 1
endif

if (n_elements(base_time) ne 0) then xst = (anytim(base_time, /utime))(0)
;
;
;Here the time is passed fully referenced and the
;the plot start time, xst_ut, will be set to the start of the passed
;array as has been done in the Yohkoh version of UTPLOT.  However, the utbase will then be
;set to xst_ut, and this reinforces keeping the reference time base separately
;because utbase can be changed by any outside routine.
;
if not sec_passed and (typ eq 'LON' or typ eq 'INT' or typ eq 'STR' or typ eq 'STC') then begin

        if timerange_passed then $   ; 28-Feb-00, akt
           xst = ( fcheck( base_time, anytim(/utime,timerange(0))))(0) else $
                xst = ( fcheck( base_time, x(0)))(0)
    xst = anytim(xst,/utim)
    x   =  x - xst          ;x is in seconds from xst
endif
;
setut, utbase= (anytim( xst, /atime))(0)            ;utbase will be set to xst
xst  = anytim( xst, /ex)             ;ras, 25-jan-94, yohkoh software wants one of their time formats
xst_ut = anytim( xst, /utime)          ;ras, 25-jan-94
;
;
;.........................................................................

checkvar, xrange, !x.range ; if a range is passed use it, unless timerange is used

if timerange_passed then begin          ;MDM added 9-Apr-93     ; 28-Feb-00, akt
    xrange = dblarr(2)          ;ras added 5-jan-94   ; changed to dbl akt 23-may-05
    xrange(0) = anytim( timerange(0),/utime) - xst_ut   ;ras 4-jan-94, changed to use anytim
    xrange(1) = anytim( timerange(1),/utime) - xst_ut
;    xrange = !x.range          ;ras, 5-jan-94
endif



;if !x.range wasn't set, then set xrange from x
if (xrange(0) eq 0.) and (xrange(1) eq 0.) then xrange = x

;
;
;.........................................................................
;
;   checkvar, xrange, [0.,0.]  ; if a range is passed use it, otherwise pass x


;If a two element array is passed, it is assumed to be to set limits and to
;override the limits of utstart and utend.  Otherwise use the limits imposed
;by utstart and utend, if they exist, otherwise the limits of the array passed.
;Only use if a seconds array has been passed.
;
getut, utstart=utstart, utend=utend
if n_elements(xrange) ne 2 and keyword_set(utstart) and keyword_set(utend) then begin
   xmin=( anytim(utstart,/utime)-xst_ut)(0)
   xmax=( anytim(utend,/utime)  -xst_ut)(0)
   xrange = [xmin, xmax]
endif


end

