;+
; PROJECT:
;   SDAC
; NAME:
;   SET_UTAXIS
;
; PURPOSE:
;   This function returns the system variable x=axis structure as though it were
;   set by a call to UTPLOT.  Used with IDL's AXIS routine.
;
; CATEGORY:
;   Plotting, UTIL, UTPLOT
;
; CALLING SEQUENCE:
;   xaxis_structure = set_utaxis(ut)
;
; CALLS:
;   UTPLOT, GET_UTAXIS, RESTORE_PLOTVAR, STORE_PLOTVAR.
;
; INPUTS:
;       UT - Time array. All formats acceptable to UTPLOT.
;       Utbase - base time for inputs in seconds format (time in seconds from 1-jan-1979).
;      not used for fully referenced times understood by anytim
;
; OPTIONAL INPUTS:
;   none
;
; OUTPUTS:
;       The function returns the X axis structure needed for subsequent calls to axis.
;
; OPTIONAL OUTPUTS:
;   none
;
; KEYWORDS INPUTS:
;
;       All KEYWORDS AVAILABLE TO UTPLOT notably:
;
;       TIMERANGE - This can be a two element time range to be
;               plotted.  It can be a string representation or structure.
;
;       LABEL - a 2 element vector selecting substring from publication format
;               of ASCII time (YY/MM/DD, HH:MM:SS.XXX).  For example,
;               LBL=[11,18] would select the HH:MM:SS part of the string.
;       SAV -   If set, UTPLOT labels, tick positions, etc. in !X... system
;               variables will remain set so that they can be used by
;               subsequent plots (normally !x... structure is saved in
;               temporary location before plot and restored after plot).
;               To clear !x... structure, call CLEAR_UTPLOT.
;       TICK_UNIT - Time (in seconds) between Major tick marks is forced to TICK_UNIT
;                   Has no effect for axis longer than 62 days.
;       MINORS    - Number of minor tick marks is forced to MINORS
;       NOLABEL If set then UTLABEL isn't printed on plot
;       XTITLE - text string for x-axis label - If the string contains
;                4 asterisks ('****'), the UT time will be substituted
;                for that substring
;       YEAR - Force the year in the x axis labels
;       YOHKOH - Use Yohkoh style labels, e.g. '03-May-93 18:11:30.732'
;
; COMMON BLOCKS:
;   none
;
; SIDE EFFECTS:
;   The saved system variables in the Utplot common area are left unchanged
;   as well as the system variables.  Therefore calls must be self-contained since the
;   memory of these actions is erased.
;
; RESTRICTIONS:
;   Same as for Utplot as applies to x axis.
;
; How to use it with a call to AXIS
; this sets the axis label on the top
;
; Using Utbase
;   x=findgen(1000)
;   utplot, x,x, '3-jan-2003', xstyle=4
;   ax = set_utaxis(x,'3-jan-2003')
;   axis, xaxis=1, xtitle=''
;   xtickname = !x.tickname
;   axis, xaxis=0, xtickname= strarr(n_elements(xtickname))+' '


;   ; For a fully referenced time
;
;   x=findgen(1000)
;   t= anytim( x + anytim('3-jan-2003'), /ex)
;   utplot, t,x, xstyle=4
;   ax = set_utaxis(t)
;   !x=ax
;   axis, xaxis=1, xtitle=''
;   xtickname = !x.tickname
;   axis, xaxis=0, xtickname= strarr(n_elements(xtickname))+' '
;
;



;
;
; MODIFICATION HISTORY:
;   Version 1, richard.schwartz@gsfc.nasa.gov, 5-jun-1998, on a suggestion
;   from AC to better support calls to AXIS.
;   08-Oct-2002, Kim.  Added !x = xold, etc lines to make it work right.
;   2-nov-2005, richard.schwartz@gsfc.nasa.gov
;     No longer setting null device, plotting to current device instead
;   15-nov-2005, ras, added title='' and subtitle='' to inhibit
;     writing these if !p.title or !p.subtile are set
;-
function set_utaxis, ut,  utbase, xstyle=xstyle, _extra=utplot_extra

    xold = !x
    yold = !y
    zold = !z
    pold = !p
    restore_plotvar
    xold_ut = !x
    yold_ut = !y
    zold_ut = !z
    pold_ut = !p

    !x = xold
    !y = yold
    !z = zold
    !p = pold

    y =anytim(ut,/sec)*0.0 ;if no y then set y to zero of length ut

    ;old_device=!d.name
    ;set_plot, 'NULL'
    default, xstyle, !x.style
    default, utbase, (anytim(ut))[0]


    utplot,ut,utbase, ystyle=4, xstyle = xstyle or 4,$
        /noeras,/nodata, _extra=utplot_extra, title='',subtitle=''
    xaxis = get_utaxis(/xaxis)
    xaxis.style = xstyle
    ;set_plot,old_device
    !x=xold_ut
    !y=yold_ut
    !z=zold_ut
    !p=pold_ut
    store_plotvar
    !p = pold
    !x = xold
    !z = zold
    !y = yold
    ;LIMITS DETERMINED

return, xaxis
end
