;.........................................................................
;+
; NAME:
;   UTPLOT
; PURPOSE:
;   Plot X vs Y with Universal time labels on bottom X axis.
; CALLING SEQUENCE:
;   UTPLOT,X,Y,BASE_TIME( or Utstring or Xst0), $
;     TIMERANGE=TIMERANGE, LABELPAR=LBL, /SAV,TICK_UNIT=TICK_UNIT,NTICKS=NTICKS, $
;     MINORS=MINORS, /NOLABEL, ERROR=ERROR,$
;               [& ALL KEYWORDS AVAILABLE TO PLOT]
;       UTPLOT, roadmap, y
;       utplot, x, y, '1-sep-91'
;       utplot, x, y, '1-sep-91', timerange=['1-sep-91', '2-sep-92']
;       utplot, x, y, '1-sep-91', timerange=[index(0), index(i)], xstyle=1
; INPUTS:
;   X -   X array to plot in seconds relative to base time.
;               (MDM) Structures allowed. X axis
;     range can be as small as 5 msec or as large as 20 years.
;
;   Y -   Y array to plot.
;   Base_time (optional)- reference time, it's purpose is as a fiducial
;     time to preserve the precision of the graphics, that is
;     the range over which a plot is drawn must not be too small
;     with respect to the absolute size of the start of the plot or
;     roundoff errors will create strange effects.  In previous
;     versions of Utplot, Base_time was called Utstring or Xst which
;     are explained below:
;           UTSTRING -
;     (Optional) ASCII string containing base time for X axis.
;     Format for time is YY/MM/DD,HHMM:SS.XXX.  If this parameter
;     isn't present    and hasn't been set yet (by a previous call to
;     UTPLOT, via routine SETUTBASE, or directly), user is
;     prompted for base time.
;           Xst0 - The reference time to use for converting a structure
;               into a seconds array (OR) the time for the first value if
;               passing a double prec. array.
;
;   Optional Keyword Inputs
;
;       TIMERANGE - Optional. This can be a two element time range to be
;               plotted.  It can be a string representation or structure.
;
;       LBL -   (Labelpar=LBL) 2 element vector selecting substring from publication format
;               of ASCII time (YY/MM/DD, HH:MM:SS.XXX).  For example,
;               LBL=[11,18] would select the HH:MM:SS part of the string.
;       SAV -   If set, UTPLOT labels, tick positions, etc. in !X... system
;               variables will remain set so that they can be used by
;               subsequent plots (normally !x... structure is saved in
;               temporary location before plot and restored after plot).
;               To clear !x... structure, call CLEAR_UTPLOT.
;       TICK_UNIT - Time (in seconds) between Major tick marks is forced to TICK_UNIT
;                   Has no effect for axis longer than 62 days.
;                   If TICK_UNIT is negative, then a standard value for TICK_UNIT is used
;                   that is closest to abs(TICK_UNIT). Returned as new value.
;   NTICKS - Previously unused in utplot.  The default tick_unit is adjusted such
;     that the number of intervals is as close to NTICKS as possible. If two
;     values are consistent, the longer interval (smaller value) is used.
;       MINORS    - Number of minor tick marks is forced to MINORS
;       NOLABEL If set then UTLABEL isn't printed on plot
;       XTITLE - text string for x-axis label - If the string contains
;                4 asterisks ('****'), the UT time will be substituted
;                for that substring
;   Year - Force the year to appear in the x axis labels
;   YOHKOH - Use Yohkoh style labels, e.g. '03-May-93 18:11:30.732'

;   DATE_LABEL_ONLY - Special format for the bottom label, showing Time (date)
;     A format requested by Arnold Benz
;   ANYTIM_LABEL_EXTRA - This is used to obtain alternate time formats for the
;     bottom label, used with anytim(/truncate, start_time, _extra=ANYTIM_LABEL_EXTRA)
;     Requested by Joe Gurman to accommodate the anytim2utc formats that are also
;     available through anytim().  Use for VMS, CCSDS, STIME, ECS formats
;     e.g.  ANYTIM_LABEL_EXTRA = {vms:1} for /vms or {ccsds:1} for /ccsds. ,etc.

; OPTIONAL OUTPUT PARAMETERS:
;   ERROR - 0/1.  1 means there was an error in plotting.
; COMMON BLOCKS:
;   COMMON UTCOMMON, UTBASE, UTSTART, UTEND, xst = base, start, and
;   end time for X axis in double precision variables containing
;   seconds since 79/1/1, 00:00. xst is the fully referenced start
;   time of the plot.
;       COMMON UTSTART_TIME, PRINT_START_TIME = 0/1 ( don't/do print
;       start time label on plot), ATIME_FORMAT ('YOHKOH'  or 'HXRBS')
; SIDE EFFECTS:
;   X vs Y plot is produced on current graphics device.  The normal
;   X-axis is replaced by an axis with ticks and labels showing the
;   universal time.  The start time of the plot is displayed in the
;   upper right inside corner of the plot if SET_UTLABEL,0 hasn't been
;   called.
; RESTRICTIONS:
;   Cannot be used for times before 1-JAN-1950 or after 31-DEC-2049
;   Range of X axis can be anywhere between 5 msec and 20 years.
;   Keywords DATA, DEVICE, NORMAL are not available
;   The utbase time is only set if either base_time
;   is passed or required as input.
; PROCEDURE:
;   If start or end time hasn't been set, autoscale X axis.
;   If either has been set (via routines SETUTSTART   and SETUTEND,
;   or directly), only data between times selected will be displayed;
;   i.e. X min = UTSTART - UTBASE; X max = UTEND - UTBASE.
;   Calls SET_UTPLOT using keyword LABELPAR to customize X
;   axis labels and tickmarks.  Otherwise it uses all normal plotting
;   procedures and    the !X and !Y system variables and keywords.
;   Note:   Format of time written in labels differs slightly from format
;   used to pass times to routines.  Input format contains only one colon
;   between minutes and seconds (makes the meaning of a partial string
;   precise) while labels include an extra colon between hours and minutes
;   (more acceptable for publication).
; MODIFICATION HISTORY:
;   Written by Kim Tolbert, 4/88.
;   Mod. by Richard Schwartz to Version 2 91/02/17
;       Mod. by Richard Schwartz for compatibility with OPLOT. 3/26/91
;   Mod. by RAS, keywords TICK_UNIT and MINORS added 91/05/02
;   MOD. BY RAS TO ACCEPT ALL PLOT KEYWORDS, 91/10/03
;       MOD. by AKT 11/12/92. Added error keyword argument.
;       Mod. ras, yohkoh style keyword
;   removed DATA, DEVICE, NORMAL keywords 14-May-93, ras
;     so version 2 can compile the many keywords
;   RAS, 93/6/8 -
;   If X window, make sure window is open before saving any bang variables
;   otherwise Linecolors will fail!
;       Mod by MDM to work with YOHKOH data (structure data types)
;       Mod by MDM to expand the COMMON block so that OUTPLOT will work
;       Mod by MDM 21-Apr-92 to not set !quiet
;       Mod by SLF 26-Apr-92 to reinstate the xtitle option
;       Mod by MDM 28-Aug-92 to add keyword YEAR to print the year on the
;                 tick label
;       Mod by MDM  9-Apr-93 to added TIMERANGE option
;       Mod by MDM 12-Apr-93 to removed ZMARGIN since older IDL versions had
;                 trouble with 9-Apr addition of TIMERANGE parameter
;   1-NOV-93, ras, integrate Yohkoh and SDAC software packages
;   10-Nov-93, ras, accept single element arguments for x0 and y0
;   14-Dec-93, MDM, - Added keyword XTHICK and YTHICK
;      - Set the x-axis label to be Start Time ... by default
;   4-jan-94, ras   - undeclared base_times are set to start of day
;        for fully referenced times, used anytim to make time processing
;        more resilient to the type of the x axis variable
;   28-jan-94, ras  - fixed ynozero problem
;   7-apr-94,  ras  - clarified some of the documentation on
;        tick_unit and labelpar
;   28-jul-94, ras - added keyword inheritance and eliminated explicit reference to zkeywords
;       8-Aug-94,  MDM  - Modified so that /NOLABEL is recognized with Yohkoh time
;                         format
;   10-aug-94, ras  - xtype is set explicitly to zero to facilitate later use of oplot
;               if utplot was used after a call to plot_oi, xtype not set properly
;   16-aug-94, ras  - added zvalue keyword and removed _extra from call to oplot
;        treatment of symsize is changed to allow control by !p.symsize
;   2-aug-95, ras   - symsize was not being utilized through !p.symsize
;        This is a clear IDL bug in version 4, also present in
;        version 3.6.1.c, !p.symsize is not being used, where
;        using the keyword symsize explicitly results in the
;        expected symbol size?
;        The second fix is to have the routine explicitly check for
;        data values within the requested range and to plot only the
;        plot box without data points.  So utplot will
;        be much more resilient in the future and will not cause
;        a code-stopping error.  However, an informative
;        message is issued using "message,/continue"
;   17-dec-98,        richard.schwartz@gsfc.nasa.gov
;                         Now, NTICKS can be used to help control the number of intervals.
;                         Default minor selection held to 12 or less.
;                         Approximate selection of TICK_UNIT enabled through negative values.
;   16-Aug-1999, William Thompson, GSFC
;        Changed way that MAX_VALUE is calculated if not
;        passed, to avoid problems with large Y ranges.
;   7-Feb-2000, Richard Schwartz (gsfc.nasa.gov), correctly implemented MAX_VALUE so it is
;                     really used.  Added MIN_VALUE.
;   25-Sep-2000, Richard Schwartz (gsfc.nasa.gov), added NaN protection to max_value and min_value.
;            Change per advice from Dale Gary, NJIT.
;       23-apr-2004 - csillag@ssl.berkeley.edu added keyword data_label_only
;   6-jan-2006, richard.schwartz@gsfc.nasa.gov,
;   1-aug-2006, S.L.Freeland - removed Windows induced ^M from the @COMMON
;	7-apr-2007, richard.schwartz, added is_gdl() branch for GDL
;
;-
PRO UTPLOT, X0, Y0, base_time, LABELPAR=LBL ,SAVE=SAV,TICK_UNIT=TICK_UNIT, NTICKS=NTICKS, $
    MINORS=MINORS , NOLABEL=NOLABEL, Yohkoh=Yohkoh, $
    timerange=timerange, $ ;include all keywords available to PLOT
    background=background, channel=channel, charsize=charsize, $
    charthick=charthick, clip=clip, color=color, $
    font=font, linestyle=linestyle, noclip=noclip, nodata=nodata, $
    noerase=noerase, nsum=nsum, polar=polar, $
    position=position, psym=psym, subtitle=subtitle, symsize=symsize, $
    t3d=t3d, thick=thick, ticklen=ticklen, title=title, year=year, $

    xrange=xrange, xcharsize=xcharsize, xmargin=xmargin, xminor=xminor, $
    xstyle=xstyle, xticklen=xticklen, xticks=xticks, $
    xtitle=xtitle, xthick=xthick, $

    yrange=yrange, ycharsize=ycharsize, ymargin=ymargin, yminor=yminor, $
    ystyle=ystyle, yticklen=yticklen, yticks=yticks, ytickname=ytickname, $
    ytickv=ytickv, ytitle=ytitle, ytype=ytype, ynozero=ynozero, $
    ythick=ythick, y2k=y2k, $
    date_label_only = date_label_only, $
    anytim_label_extra  = anytim_label_extra,  $
    _extra=_extra,     max_value=max_value, min_value=min_value, zvalue=zvalue
        ;zmargin and ztype removed for compatibility with earlier IDL
;.........................................................................
;
error = 1   ;ras, 7-jan-94, needs to be a keyword
on_error,2
;ras, 11-apr-2007
;forward_function is_gdl 
;MAKE SURE AN X-WINDOW IS OPEN BEFORE CALLING PLOT
;Don't save anything without having the window open if it's X, because
;opening the window changes !p
;if !d.window eq -1 and !d.name eq 'X' then window
if !d.window eq -1 and have_windows() then window
;

@utstart_time_com
;COMMON UTSTART_TIME, PRINT_START_TIME, ATIME_FORMAT ; 1-nov-93, ras

@utcommon
;common utcommon, utbase, utstart, utend, xst ; 1-Nov-93, ras

;
;--------------------- RAS, use fully referenced times as well as
;                 times already referenced to utbase
;          The utbase time is set to base_time
;          ,if passed, or to the
;          first value of the fully referenced time.
;          The plot reference time, xst, is set to the
;          utbase.  If utbase is set and sufficiently
;          close to the time range covered by the passed
;          data, then utbase is unchanged.
;
;y = y0        ;ras, use y0, it is passed thru w/o change

xsave = !x
xst_old = fcheck( xst, 0.d0)
utbase_old = fcheck( utbase, 0.d0)

t_utplot, x0, xplot=x, xrange=xrange, base_time=base_time, timerange=timerange, $
    xstart=xst, utbase=utbase, ordinate = Y0
;   x0 will be in seconds relative to xst
;   xst and utbase will be the same
;   xrange will be relative to xst

;.........................................................................
;SET THE X AXIS VARIABLES RELEVANT FOR UTPLOT AXIS
;.........................................................................

        checkvar,xstyle,!x.style
    checkvar,minors,xminor,!x.minor  ;minors or xminor or !x.minor
        xminor=minors
    checkvar,nticks, 0

SET_UTPLOT,$
        xrange=xrange,labelpar=lbl, error_range=error_range, eflag=eset_utplot,$
    err_format=err_format,tick_unit=tick_unit, nticks=nticks, minors=xminor,xstyle=xstyle,$
    yohkoh=yohkoh, year=year, y2k=y2k
if eset_utplot then begin
    ;restore to state on input
    !x = xsave
    utbase = utbase_old
    xst    = xst
    print, 'Error in Set_utplot!'
    goto, getout
endif

;IN CASE UTSTART AND UTEND WERE CHANGED DURING THE CALL TO SET_UTPLOT
if n_elements(utstart_old) ne 0 then begin
    utstart = utstart_old
    utend   = utend_old
endif
utplot_s = !x ;save new x labels
if error_range or err_format then goto, return1

;Extract current value of !p.color to use for axis
pcolor = !p.color
;
;   Make the plotted variables into vectors even if scalar.
;   ras, 10-Nov-93
    y = y0(*)
    x = x(*)
;.........................................................................
    psave = !p
    !p.background=fcheck(background,!p.background)
    !p.channel=fcheck(channel,!p.channel)
    !p.charsize=fcheck(charsize,!p.charsize)
    !p.charthick=fcheck(charthick,!p.charthick)
    !p.clip=fcheck(clip,!p.clip)
    !p.color=fcheck(color,!p.color)
    !p.font=fcheck(font,!p.font)
    !p.linestyle=fcheck(linestyle,!p.linestyle)
    !p.noclip=fcheck(noclip,!p.noclip)
    !p.noerase=fcheck(noerase,!p.noerase)
    !p.nsum=fcheck(nsum,!p.nsum)
    !p.position=fcheck(position,!p.position)
    !p.psym=fcheck(psym,!p.psym)
    !p.subtitle=fcheck(subtitle,!p.subtitle)
    if !p.symsize ne 0.0 then !p.symsize=fcheck(symsize,!p.symsize) $
       else !p.symsize=fcheck(symsize, 1.0)
    !p.t3d=fcheck(t3d,!p.t3d)
    !p.thick=fcheck(thick,!p.thick)
    !p.ticklen=fcheck(ticklen,!p.ticklen)
    !p.title=fcheck(title, !p.title)

    !x.charsize=fcheck(xcharsize, !x.charsize)
    !x.margin=fcheck(xmargin, !x.margin)
    !x.ticklen=fcheck(xticklen, !x.ticklen)
    !x.title=fcheck(xtitle,!x.title)
    !x.thick=fcheck(xthick,!x.thick)     ;MDM added 14-Dec-93
        !x.style=fcheck(xstyle, !x.style)    ;MDM added

    ysave = !y
    !y.charsize=fcheck(ycharsize, !y.charsize)
    !y.margin=fcheck(ymargin, !y.margin)
    !y.minor=fcheck(yminor, !y.minor)
    !y.range=fcheck(yrange, !y.range)
    !y.style=fcheck(ystyle, !y.style)
    !y.ticklen=fcheck(yticklen,!y.ticklen)
    !y.tickname=fcheck(ytickname,!y.tickname)
    !y.ticks=fcheck(yticks, !y.ticks)
    !y.tickv=fcheck(ytickv, !y.tickv)
    !y.title=fcheck(ytitle,!y.title)
    !y.thick=fcheck(ythick,!y.thick)     ;MDM added 14-Dec-93
    !y.type=fcheck(ytype, 0) ;clear ytype

    ;zsave = !z
    ;!z.charsize=fcheck(zcharsize, !z.charsize)
    ;!z.margin=fcheck(zmargin, !z.margin)
    ;!z.minor=fcheck(zminor, !z.minor)
    ;!z.range=fcheck(zrange, !z.range)
    ;!z.style=fcheck(zstyle, !z.style)
    ;!z.ticklen=fcheck(zticklen,!z.ticklen)
    ;!z.tickname=fcheck(ztickname,!z.tickname)
    ;!z.ticks=fcheck(zticks, !z.ticks)
    ;!z.tickv=fcheck(ztickv, !z.tickv)
    ;!z.title=fcheck(ztitle,!z.title)
    ;!z.type=fcheck(ztype, !z.type)

;if atime_format eq 'YOHKOH' then begin

if atime_format eq 'YOHKOH' or is_struct(anytim_label_extra) and NOT keyword_set(nolabel) then begin
           start_time=GETUTBASE(0) + !x.crange(0)
           date_label = keyword_set(date_label_only)
           LABW = is_struct(anytim_label_extra) ? $
           anytim(start_time, _extra = anytim_label_extra,/truncate,date=date_label) : $
           ANYTIM(/truncate, start_time, date = date_label,/yohkoh)
; acs 2004-04-23 added the date_label_only to get only the date in the xtitle
;           TLABW =  strmid(LABW,0,18)
;           LABEL = 'Start Time (' + TLABW   + ')'       ;MDM remove the
           if keyword_set( date_label_only ) then begin ;date label by csillag 5-apr-2004
               ;TLABW =  LABW ;strmid(LABW,0,9)
               LABEL = 'time (' + LABW   + ')' ; arnold benz' format
           endif else begin
               ;TLABW =  strmid(LABW,0,18)
               LABEL = 'Start Time (' + LABW   + ')' ;MDM remove the
                   ;msec part of the label
           endelse

        if keyword_set(xtitle) then $
           xtitle=str_replace(xtitle,'****',' ' + labw + ' ')  ;slf,24-jul-92
        !x.title=fcheck(xtitle, label)                          ;slf,24-jul-92
endif
;stop

if n_elements(max_value) eq 0 then begin
    max_value=max(y0, /nan)                                  ;<--change
    max_value= max_value + 0.1*abs(max_value)
endif
if n_elements(min_value) eq 0 then begin
    min_value=min(y0, /nan)                                  ;<--change
    min_value= min_value - 0.1*abs(min_value)
endif

;find the number of elements in the range
;wrange = where( x ge (!x.crange(0) < !x.crange(1)) and $
;    x le (!x.crange(0) > !x.crange(1)), nwrange)
;if x values surround the plot box, no warning
mmx = minmax( x )
if mmx[1] lt (!x.crange(0) < !x.crange(1)) or mmx[0] gt (!x.crange(0) > !x.crange(1)) then begin
;if nwrange lt 1 then begin
    message,/continue,'Warning, Times passed out of plotting range.  '
    message,'Time-range of plot box: '+ atime(!x.crange(0) + utbase)+ ' '+$
       atime(!x.crange(1) + utbase),/continue
    message,'Time-range of data passed: '+atime( mmx[0] + utbase) + ' '+$
       atime( mmx[1] + utbase),/continue
endif

yrange0 = min(y,/nan)                                           ;<--change
yrange1 = max(y,/nan)                                           ;<--change

!c = 0
;Plot the timerange even if no data lies within the interval!
if Is_GDL() then begin
if not keyword_set(color) then $
    plot,!x.crange,[yrange0,yrange1]< max_value>min_value, $
       data=fcheck(data), device=fcheck(device), $
       /nodata,$
       normal=fcheck(normal), $
       polar=fcheck(polar), $
       symsize=fcheck(symsize,!p.symsize), $
       ;ytype=!y.type,$
       ynozero=fcheck(ynozero) $
       ,_extra=_extra    $          ;ras, 28-jul-94
else $
    plot,!x.crange,[yrange0,yrange1]< max_value>min_value, $
       data=fcheck(data), device=fcheck(device), $
       normal=fcheck(normal), $
       polar=fcheck(polar),  $
       ;ytype=!y.type,
       /nodata, color = pcolor, $
       ynozero=fcheck(ynozero), _extra=_extra          ;ras, 28-jul-94
;     ynozero=fcheck(ynozero)
endif else begin

if not keyword_set(color) then $
    plot,!x.crange,[yrange0,yrange1]< max_value>min_value, $
       data=fcheck(data), device=fcheck(device), $
       /nodata,$
       normal=fcheck(normal), $
       polar=fcheck(polar), $
       symsize=fcheck(symsize,!p.symsize), $
       ytype=!y.type,$
       ynozero=fcheck(ynozero) $
       ,_extra=_extra    $          ;ras, 28-jul-94
else $
    plot,!x.crange,[yrange0,yrange1]< max_value>min_value, $
       data=fcheck(data), device=fcheck(device), $
       normal=fcheck(normal), $
       polar=fcheck(polar),  $
       ytype=!y.type, /nodata, color = pcolor, $
       ynozero=fcheck(ynozero), _extra=_extra          ;ras, 28-jul-94
;     ynozero=fcheck(ynozero)
endelse
if not fcheck(nodata) then $
    if n_elements(zvalue) eq 0 then $
      oplot,x,y, $
       polar=fcheck(polar), $
       max_value=max_value , min_value=min_value, $
       symsize=fcheck(symsize,!p.symsize) $
    else $
      oplot,x,y, $
       polar=fcheck(polar), $
       max_value=max_value, min_value=min_value, $
       zvalue=zvalue, $ ;ras, 16-aug-94
       symsize=fcheck(symsize,!p.symsize)
;     symsize=fcheck(symsize,!p.symsize)



; save !x, !y, !z, and !p in case we need access to what was used later.
store_plotvar


AFTERXLABELS:
;
; Write label with start time in top right inside corner of plot
CHECKVAR,PRINT_START_TIME,1
IF (atime_format eq 'HXRBS') AND $
    (PRINT_START_TIME EQ 1) AND (NOT KEYWORD_SET(NOLABEL)) THEN BEGIN
       start_time=GETUTBASE(0) + !x.crange(0)
       LABW = ATIME(start_time,/PUB,yohkoh=yohkoh)
       LABEL = 'Plot Start: ' + LABW
       ;Set the color so that the label to white on black or black on white
       UTLABEL,LABEL, color=pcolor
ENDIF
;
return1:

;save new system variables needed for overplotting
xcrange = !x.crange
xs      = !x.s
xwindow = !x.window
xregion = !x.region
xtype   = !x.type     ;ras 10-aug-94

ycrange = !y.crange
ys      = !y.s
ywindow = !y.window
yregion = !y.region
ytype   = !y.type

;zcrange = !z.crange
;zs      = !z.s
;zwindow = !z.window
;zregion = !z.region
;ztype   = !z.type

pmulti  = !p.multi
pclip   = !p.clip
;restore original system variables

!x=xsave

!p=fcheck(psave, !p)
!y=fcheck(ysave, !y)
;!z=fcheck(zsave, !z)

;replace system variables needed for overplotting
!x.crange = xcrange
!x.s      = xs
!x.window = xwindow
!x.region = xregion
!x.type   = xtype               ;ras 10-aug-94

!y.crange = ycrange
!y.s      = ys
!y.window = ywindow
!y.region = yregion
!y.type   = ytype

;!z.crange = zcrange
;!z.s      = zs
;!z.window = zwindow
;!z.region = zregion
;!z.type   = ztype

!p.multi  = pmulti
!p.clip   = pclip
if keyword_set(sav) then begin
    !x.tickv = utplot_s.tickv
    !x.tickname = utplot_s.tickname
    !x.minor = utplot_s.minor
    !x.ticks = utplot_s.ticks
endif

error=0

getout:
end
