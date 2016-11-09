PRO SET_UTPLOT, xrange=x, labelpar=lbl, utbase=base, error_range=error_range, $
	err_format=err_format, eflag=eflag, tick_unit=tick_unit, nticks=nticks, minors=minors, xstyle=xstyle, $
	yohkoh=yohkoh, year=year, y2k=y2k
;+
; NAME:
;	SET_UTPLOT
; PURPOSE:
;	Allows user flexibility in setting up time axis labelling.
;	Prepares IDL system variables (!X.RANGE, !X.TICKV, !X.TICKNAME, 
;	and !X.TICKNAME) for plotting X vs Y with Universal time labels 
;	on bottom X axis.  After calling SET_UTPLOT, user calls the 
;	standard IDL PLOT routine to draw the plot. 
;	SET_UTPLOT is normally called by UTPLOT, and is transparent to 
;	the user.
;	Default style is controlled by atime_format which is set by
;	a call to YOHKOH( HXRBS )_FORMAT, Yohkoh style uses
;	dd-mon-yr hh:mm:ss.xxx and for HXRBS
;	yy/mm/dd, hh:mm:ss.xxx
;
; CATEGORY:
; CALLING SEQUENCE:
;	SET_UTPLOT,XRANGE=X,LABELPAR=LBL,UTBASE=BASE,ERROR_RANGE=ERROR_RANGE,
;	   ERR_FORMAT=ERR_FORMAT, EFLAG=EFLAG, TICK_UNIT=TICK_UNIT, NTICKS=NTICKS, MINORS=MINORS,
;	   XSTYLE=XSTYLE, yohkoh=yohkoh, year=year
; INPUT PARAMETERS:
;	X - 	X array to plot (seconds relative to base time).
;	LBL - 	2 element vector selecting substring from publication format
;	   	of ASCII time (YY/MM/DD, HH:MM:SS.XXX).  For example, 
;	   	LBL=[11,18] would select the HH:MM:SS part of the string.
;	BASE - 	ASCII string containing base time for X axis. Format for
;	   	time is YY/MM/DD,HHMM:SS.XXX.  If this parameter isn't present
;          	and hasn't been set yet (by a previous call to UTPLOT, via 
;		routine SETUTBASE, or directly), user is prompted for base time.
;	ERROR_RANGE - = 0/1. If set to 1, the X array is outside of the
;	   	limits defined by start and end times selected by user.
;	ERR_FORMAT - =0/1. If set to 1, there was an error in the ASCII time
;	   	format for the base time.
;	TICK_UNIT - Time between Major tick marks is forced to TICK_UNIT
;		    Has no effect for axis longer than 62 days.
;                   If TICK_UNIT is negative, then a standard value for TICK_UNIT is used
;                   that is closest to abs(TICK_UNIT). Returned as new value.
;	NTICKS-  Similar to standard XTICKS in plot.  The default tick_unit is adjusted such
;		that the number of intervals is as close to XTICKS as possible. If two
;		values are consistent, the longer interval is used. Using NTICKS to avoid
;		problems with users not completely specifying TICK_UNIT.
;	MINORS	  - Number of minor tick marks is forced to MINORS. 
;	XSTYLE    - Same meaning as in PLOT, if SET xaxis is exact to UTSTART
;		    and UTEND.
;       /yohkoh  - force yohkoh time formats, e.g. '03-May-93 18:14:23.732'
;		   instead of '93/05/03, 18:14:23.732'
;	/year    - forces the year to be included in the date string
;	EFLAG	 - Error flag, if set then not normal return
; COMMON BLOCKS:
;	COMMON UTCOMMON, UTBASE, UTSTART, UTEND, XST = base, start, and 
;	end time for X axis in double precision variables containing
;	seconds since 79/1/1, 00:00.
;       COMMON CLEARCOMMON,XOLD,YOLD,CLEARSET = holding area for previous
;	!x and !y structures if clearset=1
;	COMMON UTSTART_TIME, PRINT_START_TIME, ATIME_FORMAT
;
; RESTRICTIONS:
;	Cannot be used for times before 79/1/1 or after 2049/12/31.
; MODIFICATION HISTORY:
;	Written by Richard Schwartz 91/02/17
;	Modified 91/03/27, RAS
;		Clears all !x vectors which will be set.
;	Modified 91/05/02, RAS
;		New Keywords Tick_unit, and Minors		
;       Modified 92/5/11, Kim Tolbert.  If lower and upper limits for x axis
;               are passed in xrange (rather than entire x array to plot),
;               then those limits take precedence over any utstart and
;               utend that might be set by user.  Before utstart/end always
;               defined limits if they were set.
;	Modified 92/07/10, RAS
;		Uses new version of ATIME which accepts arrays of times
;		and is valid from 1950-2049 
;	Modified 93/01/18, RAS
;		no longer uses ymd2sec to find first day of years or months
;		uses jdcnv and daycnv
;       Modified 93/05/03, RAS
;		switch for Yohkoh format
;	Modified 93/06/07, RAS
;		accepts Yohkoh database structure for X
;       26-Aug-92 (MDM) - Added keyword YEAR - put year on tick labels
;       18-Mar-93 (MDM) - Removed the modification made 91/10/18 since it was
;                         causing problems on subsequent plots (giving a
;                         error_range error)
;	1-Nove-93 ras - reconcile Yohkoh and SDAC software 
;	14-Dec-93 (MDM) - Various changes - allow plotting reverse time order
;			- Allow plotting of a single point
;	5-jan-94 ras - use t_utplot to resolve problems with 
;		       multiple formats for x, i.e, sec+utbase and 
;		       fully referenced time formats
;       28-jan-94 ras - allows degenerate time range without crashing
;	 7-Feb-94 (MDM) - Patch for plotting single point case
;	17-dec-98,        richard.schwartz@gsfc.nasa.gov
;                         Now, NTICKS can be used to help control the number of intervals.
;                         Default minor selection held to 12 or less.
;                         Approximate selection of TICK_UNIT enabled through negative values.
;-
; initialize error flags
eflag = 1
err_format=0
error_range=0 ;logical for x-data out of range
on_error, 2	;return to calling program

@utcommon
;Hold Utplot values in memory.
;common utcommon, utbase, utstart, utend, xst
@clearcommon
;common clearcommon,xold,yold,clearset
@utstart_time_com
;COMMON UTSTART_TIME, PRINT_START_TIME, ATIME_FORMAT


frst_of_mnth = 0 ;logical set if ticks are all on 01-Mon-YY

;INITIALIZE UTCOMMON VALUES
checkvar,utstart,0. ;utstart or 0. if undefined
checkvar,utend,0.
checkvar,base,'-1'
	checkvar,utbase,base(0) ;Is UTBASE defined?  
	;if no then prompt for base time
try_again:
	if (utbase eq '-1') then setutbase,err=err_format
	if err_format then goto,try_again
	 ;set utbase to base
	if (base ne '-1') then setut,utbase=base(0),err=err_format
	if err_format then begin
           print,'Error - invalid base time.'
           goto, getout
        endif
utbase = (anytim( utbase, out='utime'))(0) ;make sure of the representation of utbase
;************
;DETERMINE LIMITS ON X AXIS
checkvar,clearset,1
if clearset then begin ;save !x and !y in clearcommon
	xold=!x
	yold=!y
	clearset=0
endif
	xstyle_in = !x.style
	!x.style=fcheck(xstyle, !x.style)


S_X=SIZE(X) ;IS X PASSED?
IF S_X(1) NE 0 THEN BEGIN ;IF1 BEGIN
	t_utplot, x, xplot=xn, utbase=utbase, xstart=xst, base_time=base_time 
	;ras - use common plot variable preparation with utplot, 5-jan-94
	CSAVE=!C

	case n_elements(xn) of			;MDM added 14-Dec-93
	    1: begin
		xmin = xn(0)-10.0    ;10 seconds on either side of point
		xmax = xn(0)+10.0
		xn = replicate(xn(0), 1)	;make it an array - MDM modified 7-Feb-94
	       end
	    2: begin				;assume passed XRANGE
                xmin = xn(0)
		xmax = xn(1)	
	       end
	    else: begin
		xmin=min(xn)
		xmax=max(xn)
	       end
	endcase

	;protect against degenerate xranges ras, 28-jan-94
	if xmin eq xmax then begin
		xequal = xmin
		xmin = xequal-.01*xequal>.01
		xmax = xequal+.01*xequal>.01
		xn = [xmin, xmax]
	endif
;;        if (n_elements(xn) eq 2) then begin      ;assume passed XRANGE	;MDM removed 14-Dec-93
;;                xmin = xn(0)
;;                xmax = xn(1)
;;        end else begin
;;                xmin=min(xn)
;;                xmax=max(xn)
;;        end
	!C=CSAVE
ENDIF ELSE BEGIN	  ;IF1 ELSE
	xmin=!x.crange(0)
	xmax=!x.crange(1)
ENDELSE		          ;IF1 CLOSE
;************
;If a two element array is passed, it is assumed to be to set limits and to
;override the limits of utstart and utend.  Otherwise use the limits imposed
;by utstart and utend, if they exist, otherwise the limits of the array passed.

if n_elements(xn) ne 2 then begin   
   if utstart ne 0. then xmin=(utstart-utbase)
   if utend   ne 0. then xmax=(utend-utbase)
endif
if atime_format eq 'HXRBS' then begin
    IF XMAX LE XMIN THEN BEGIN ;IF2 BEGIN
	PRINT,'Error- end time is less than or equal to start time.'
	error_range=1
	goto, getout ;EXIT
    ENDIF			   ;IF2 CLOSE
endif else begin 
    IF XMAX LE XMIN THEN BEGIN ;IF2 BEGIN
	;;PRINT,'Warning- end time is less than or equal to start time.'	;MDM commented out 14-Dec-93
	;error_range=1
	;RETURN ;EXIT
    ENDIF			   ;IF2 CLOSE
endelse

IF XMAX+UTBASE Ge  2.24061120e+09 THEN BEGIN
	PRINT,'Error - end time is greater than year 2049.'
	error_range=1
	goto, getout
ENDIF

;clear old plot parameters prior to DUMMYPLOT, 91/03/27, RAS *****************
	!x.crange=0.
	!x.range=0.
	!x.tickv=0.
	!x.ticks=0.
	!x.tickname=0.
	!x.minor=0.
	!x.range=[xmin,xmax]
;***************************** end modification ******************************
wrange=where( (xn le (xmax>xmin) ) and (xn ge (xmin<xmax) ), nrange)
if nrange lt 2 then begin
	;;print,'Error, less than two data points within the range'		;MDM commented out 14-Dec-93
	;;error_range=1
	;;return
endif
;DUMMY PLOTS

DUMMYPLOTS,X=xn ;SETS PLOTS RANGES WO PLOTTING
	!x.range=!x.crange
	;;drange=!x.crange(1)-!x.crange(0)
	drange=abs(!x.crange(1)-!x.crange(0))			;MDM added 14-Dec-93

checkvar,minors,0 ;if minors is passed use it, 
!x.style = xstyle_in ; 

;SET TICKMARKS

;Initialize default ranges for major and minor tick marks

tick_units=1.d0 * [10^findgen(5)*1.0d-3,10^findgen(4)*.002,10^findgen(4)*.005,$
	20.,30.,60.,60.*[2,4,5,6,10,15,20,30,60],3600.*[2.+findgen(5),8.,10.,12.],$
	86400.*[findgen(6)+1.,10.,20.,30.,60.]]
	;6)+1.,12.*(1.+findgen(10.))]]]
if fcheck(tick_unit, 0) lt 0 then begin
	mindiff = min( abs( abs(tick_unit) - tick_units), imin)

	tick_unit = tick_units( imin )
	endif

minor_units=1.d0 * [.0001,.0002,.001,.002,.01,.02,.1,.2,1.0,2.0,5.0,10.,20.,60.,$
	120.,300.,600.,3600.,7200.,14400.,3600.*[6.,12.],$
	86400.*[1.,2.,5.,10.]] ;possible time intervals between minor ticks

;THE UNITS SHOULD BE SELECTED SO THAT THERE ARE FROM 2 TO 6 TICK INTERVALS

if drange le 62*86400. then begin ;select from units lt month
	if (size(tick_unit))(1) eq 0 then begin ;find tick_unit if its not set already
;		w_ok=where( (drange/tick_units lt 7) and (drange/tick_units ge 2)) 
;		m_ok=max(drange/tick_units(w_ok)) &!C=0
		w_ok=where( (drange/tick_units lt 7) and (drange/tick_units ge 2),n_ok) 
		if n_ok eq 0 then w_ok = [0] ;choose smallest tick_units if nothing found, ras, 28-jan-94
		if fcheck(nticks,0) ne 0 then begin
			m_ok = min( abs(long(drange/tick_units(w_ok))- nticks), i_ok)
			i_ok = where( tick_units(w_ok(i_ok)) eq tick_units(w_ok), n_ok)
			if n_ok eq 2 then tick_unit = min(tick_units(w_ok(i_ok))) else tick_unit = tick_units(w_ok(i_ok))
			endif else begin
				m_ok=max(drange/tick_units(w_ok),i_ok) 
				tick_unit=tick_units(w_ok(i_ok))
				endelse
		tick_unit = tick_unit(0)
		endif 
	
	!x.ticks=drange/tick_unit ;number of tick intervals
	
	;*****************
	if minors eq 0 then begin
                ;which minors divide evenly
		wminors=where( tick_unit mod minor_units lt 1.e-5*tick_unit,cnt)
                if cnt eq 0 then begin 
                   !x.minor = 0
                endif else begin
   		   ;into major tick intervals
  		   nminors=tick_unit/minor_units(wminors) ;possible #minor intervals
		   test_minors=min(abs(nminors-4)) ;get as close as possible to 4 sub-intervals	
		   !x.minor=nminors(!c) <12 &!c=0 ;number of minor tick intervals
                endelse
	endif else !x.minor=minors
;*****************
;*****************
;SET THE TICKVALUES AND NAMES
;	start_off=(utbase+!x.crange(0))/tick_unit mod 1.d0 ;looking for frac. 
	start_off=(utbase+ (!x.crange(0)<!x.crange(1)) )/tick_unit mod 1.d0 ;looking for frac. 
	tic_n_range=((1.d0-start_off) mod 1. +findgen(!x.ticks+1))*tick_unit $
	       + (!x.crange(0)<!x.crange(1)) +utbase		;MDM patched 14-Dec-93
;;	       + !x.crange(0) +utbase

endif else begin ;range is at least two months 

;FIND YY/MM/01 AND YY/01/01 WITHIN RANGE SELECTED

	;ARRAY TIC_N_RANGE HAS ALL YY/MM/01 WITHIN ALLOWED RANGE

	;ymd2sec,day=days_month,iut=iuty,/alt ;REPLACED BY FOLLOWING, 93/1/18

	        edy = 2443874.5 ;epoch day, 79/1/1 in Julian days

	if drange lt 1096.*86400. then begin ;LT 3 YEARS, 4-36 MONTHS
		
		daycnv, ( (limits(!x.crange)+ utbase)/86400.) + edy, jyr
                tic_n_range = dblarr(12,  ( jyr(1)-jyr(0)+1) )
		for iy= jyr(0), jyr(1) do begin
			jdcnv, iy, findgen(12)+1, 1, 0.0, day_one
			tic_n_range( *, iy-jyr(0)) = day_one(*)
		endfor
		tic_n_range = (tic_n_range(*) - edy) * 86400.0d0
		tick_unit=30.d0*86400.d0 ;approximately one month or more between
			 	 ;tick marks

	endif else begin ;range is longer than 3 years

		jdcnv, findgen(100)+1950,1,1,0.,jdy ;GET STARTS IN JULIAN DAYS
		tic_n_range = 86400.d0*(jdy - edy) ; LONGER THAN 3 YEARS
		tick_unit   = 365.*86400.d0 ;about one year between tick marks

	endelse
	frst_of_mnth = 1 ;logical set if ticks are all on 01-Mon-YY

endelse ;CLOSE LOOP FOR YEAR OR MONTH TICK MARKS

;Make sure ticks are within range by both methods of time selection
	tic_n_range=tic_n_range-utbase
	xcrange = limits(!x.crange)
;	wyymm=where( (tic_n_range ge !x.crange(0)) and $
; 		(tic_n_range le !x.crange(1)),num_yymm) ;how many possible ticks
	wyymm=where( (tic_n_range ge xcrange(0)) and $
 		(tic_n_range le xcrange(1)),num_yymm) ;how many possible ticks

	if drange gt 62*86400. then begin ; make sure minor tick marks lie close
					  ;to month boundaries
	        dticks=fix(num_yymm/6.1)+1 ;number of months/years between ticks
		if minors eq 0 then $
		!x.minor=dticks $;set minor tick marks close to months or years
		else !x.minor=minors
        	wyymm=wyymm(where( (wyymm-wyymm(0)) mod dticks eq 0)) ;use only every dtick month/yr
	endif 
	!x.ticks = n_elements(wyymm)-1 ;
        if !x.ticks eq 0 then goto,getout   ; added 9/15/93 by akt
	xtickv   = tic_n_range(wyymm)

;SET THE TICKNAME STRINGS
;wtickname = where( xtickv le !x.crange(1), nname)
wtickname = where( xtickv le (!x.crange(1)>!x.crange(0)), nname)

;The label style, Yohkoh or HXRBS, is controlled within atime
;If the yohkoh keyword is set, then Yohkoh style is forced.

if nname ge 1 then $
	!x.tickname = atime(utbase +xtickv(wtickname),yohkoh=yohkoh,/pub,y2k=y2k)


;DETERMINE PROPER LABEL FORMAT
if not keyword_set(lbl) then begin ;if no label format, select one

        ;test_units=[365.*86400.,86400.,60.,1., .1, .01,.001   ]	
        test_units=[365./2.*86400.,86400.,60.,1., .1, .01,.001 ]	

if keyword_set(yohkoh) or atime_format eq 'YOHKOH' then begin

; New Form dd-mmm-yy hh:mm:ss.xxx
;          0123456789012345678901
;
;           * mmm-yy
;                       * dd-mmm
;                               * hh:mm
;                                       * mm:ss.x
;                                           * ss.xx
;                                               * ss.xxx
		rhs=       [8,          5,     14, 17, 19, 20, 21]                      ;MDM
		lhs=       [3,          0,     10, 10, 13, 16, 16]                      ;MDM
		if keyword_set(y2k) then begin
		    lhs = [ 3,          0,     12, 12, 15, 18, 18]
		    rhs = [10,          5,     16, 19, 21, 22, 23]
		endif
		if (keyword_set(year)) then rhs(1)=rhs(0)
	        if frst_of_mnth then begin
		    lhs(0) = 7
		    lhs(1) = 3
		endif
	endif else begin
		rhs=       [4,          7,     17, 17, 19, 20, 21]
		lhs=       [0,          3,     10, 10, 13, 16, 16]
		if keyword_set(y2k) then begin
		    rhs=   [6,          9,     19, 19, 21, 22, 23]
		    lhs=   [0,          3,     12, 12, 15, 18, 18]
		endif
		if (keyword_set(year)) then lhs(1)=lhs(0)
	endelse







	wtest=where( tick_unit ge test_units, cnt)
        if cnt eq 0 then lbl=[16,21] else lbl=[lhs(wtest(0)) ,rhs(wtest(0))]
endif ;LABEL FORMAT SELECTED

!x.tickname = strmid(!x.tickname,lbl(0),lbl(1)-lbl(0)+1)
!x.tickv    = xtickv

getout:
eflag = 0	;normal return, other error flags may be set
return
end
