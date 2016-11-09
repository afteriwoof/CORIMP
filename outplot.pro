PRO OUTPLOT,X0, Y, base_time, $
        channel=channel, $
        clip=clip, color=color, device=device, $
        linestyle=linestyle, noclip=noclip, data=data, $
        normal=normal, nsum=nsum, polar=polar, $
        psym=psym, symsize=symsize, $
        t3d=t3d, thick=thick, max_value=max_value

;quiet_save = !quiet
;!quiet=1
on_error,2
;+
; NAME:
;	OUTPLOT
; PURPOSE:
;	Plot vector data over a previously drawn plot (using UTPLOT) with
;	universal time labelled X axis.  If start and end times have been
;	set, only data between those times is displayed.
; CATEGORY:
; CALLING SEQUENCE:
;	OUTPLOT,X,Y
;	OUTPLOT,X,Y, base_time
; INPUTS:
;       X -     X array to plot in seconds relative to base time.
;               (MDM) Structures allowed
;       Y -     Y array to plot.
;	base_time - reference time, formerly called...
;       	xst or utstring.  It's purpose is to fully define the time
;		in the input parameter, x0.  The start of the plot is fully
;		defined by utbase and xst, both in utcommon and the two are identical
;		after a call to Utplot.  When x0 is passed as a double precision
;		vector, it is assumed to be relative to utbase.  Any other form
;		for the time should be complete.  
;		This parameter should only be used for seconds arrays relative to
;		a base other than Utbase, the base just used for plotting.
; OUTPUTS:
;	None.
; OPTIONAL OUTPUT PARAMETERS:
;	None.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	Overlays X vs Y plot on existing plot.
; RESTRICTIONS:
;	Can only be used after issuing UTPLOT command.
; PROCEDURE:
;	If UTSTRING parameter is passed, a temporary X array is created 
;	containing the original X array offset by the new base
;	time minus the old base time (used in UTPLOT command).  OPLOT is 
;	called to plot the temporary X vs Y.
; MODIFICATION HISTORY:
;	Written by Kim Tolbert 4/88
;	Modified for IDL VERSION 2 by Richard Schwartz, Feb. 1991
;	21-Mar-92 (MDM) - Adjusted for YOHKOH spacecraft use - allowed 
;			  input variable to be a structure
;			- Added multiple keyword options (old version
;			  only took x and y)
;	28-Apr-92 (MDM) - "SYMSIZE" was not being implemented
;	23-Oct-92 (MDM) - IDL Ver 2.4.0 does not accept /DEV, /NORM, or /DATA
;			  for the OPLOT command any more
;	5-jan-94 ras    - incorporated t_utplot for preparation of x array
;	Version 7, richard.schwartz@gsfc.nasa.gov, protect against non-scalar values
;	of XST coming out of t_utplot.  16-mar-1998.
;-
@utcommon
;COMMON UTCOMMON, UTBASE, UTSTART, UTEND, xst
;
;overplot on UTPLOT
;;utbase=getutbase(0)
;;setutbase,utstring ;set new base time
;;utbasenew=getutbase(0)
;;setutbase,atime(utbase)
;;oplot,x+utbasenew-utbase,y

;--------------------- MDM added
;if (n_elements(xst0) ne 0) then begin
;    ex2int, anytim2ex(xst0), xst_msod, xst_ds79
;    xst = [xst_msod, xst_ds79]
;    off = int2secarr(xst, xst_plot)
;    off = off(0)        ;convert to scalar
;end else begin
;    xst = xst_plot      ;use the value that was used for UTPLOT
;    off = 0
;end

;siz = size(x0)
;typ = siz( siz(0)+1 )
;if (typ eq 8) then x = int2secarr(x0, xst) else x = x0 + off
;--------------------- RAS 2-nov-93
;ref_time = anytim( xst, out='sec')  ;the plot is relative to this time, in secs
;checkvar, base_time, utbase ;Utbase must have been defined on the call to Utplot!
;typ = datatype( x0 )
;if typ eq 'DOU'  or typ eq 'FLO' then $ 
;	x = anytim( x0, out='sec') + anytim( base_time, out='sec') - ref_time $
;else $
;	x = anytim( x0, out='sec') - ref_time
;
; 	commonality on time axis using t_utplot
; 	ras, 5-jan-94
;
	;save some values which could be changed inside t_utplot, utbase, and xst
	utbase_old=utbase
	xst_old   =xst
	t_utplot, x0, xplot=x, utbase=utbase, xstart=xst, base_time=base_time
	x = x + (anytim(xst,/sec))(0) - (anytim(xst_old,/sec))(0)
	utbase = utbase_old
	xst    = xst_old
;
;    
psave = !p
        !p.channel=fcheck(channel,!p.channel)
        !p.clip=fcheck(clip,!p.clip)
        !p.color=fcheck(color,!p.color)
        !p.linestyle=fcheck(linestyle,!p.linestyle)
        !p.noclip=fcheck(noclip,!p.noclip)
        !p.nsum=fcheck(nsum,!p.nsum)
        !p.psym=fcheck(psym,!p.psym)
        !p.t3d=fcheck(t3d,!p.t3d)
        !p.thick=fcheck(thick,!p.thick)

;;oplot,x,y, data=fcheck(data), device=fcheck(device), $
;;        normal=fcheck(normal), $
;;        polar=fcheck(polar), symsize=fcheck(symsize,1)
if n_elements(max_value) eq 0 then max_value=max(y)+1
oplot,x,y, polar=fcheck(polar), symsize=fcheck(symsize,1), $	;MDM patch 23-Oct-92 because of change to IDL
	max_value=max_value
!p = psave
;
;.........................................................................

;!quiet = quiet_save
return
end

