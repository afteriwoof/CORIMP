;.........................................................................
;+
; NAME:
;	UTPLOT_IO
; PURPOSE:
;	Plot X vs Y with Universal time labels on bottom X axis.  X axis
;	range can be as small as 5 msec or as large as 99 years. Y-axis is
;	logarithmic.
;
; NOTE: 
;	This is an archaic routine.  Please change your calls to Utplot, /ytype instead
;	of calling Utplot_io.  Utplot_io will no longer be upgraded.
;
; CALLING SEQUENCE:
;	UTPLOT_IO,X,Y,UTSTRING,LABELPAR=LBL, /SAV,TICK_UNIT=TICK_UNIT,$
;		MINORS=MINORS, /NOLABEL, /YOHKOH ,$
;		[& ALL KEYWORDS AVAILABLE TO PLOT]
; 
; IDENTICAL TO UTPLOT	
; HISTORY:
;       11-Nov-92 (MDM) - Removed "ztype" keyword call to UTPLOT
;       19-Apr-93 (MDM) - Removed "zmargin" keyword call to UTPLOT
;	 7-jan-94 ras   - added xthick and ythick
;       23-feb-94 JRL   - Fixed xthick and ythick options
;       11-aug-94 ras   - added keyword inheritance
;	17-aug-94 ras   - removed keyword inheritance, with keyword inheritance
;			  no variables can be passed to utplot undefined!
;			  z keywords available through !z have been removed.
;		          loss of capability due to bug in IDL Version 3.6.1
;	10-jun-01 LWA   - added keyword ytickformat
;-

PRO UTPLOT_IO, X, Y, UTSTRING, LABELPAR=LBL ,SAVE=SAV,TICK_UNIT=TICK_UNIT,$
	MINORS=MINORS , NOLABEL=NOLABEL, YOHKOH=YOHKOH, timerange=timerange, $
	background=background, channel=channel, charsize=charsize, $
	charthick=charthick, clip=clip, color=color, $
	font=font, linestyle=linestyle, noclip=noclip, nodata=nodata, $
	noerase=noerase, nsum=nsum, polar=polar, $
	position=position, psym=psym, subtitle=subtitle, symsize=symsize, $
	t3d=t3d, thick=thick, ticklen=ticklen, title=title, year=year, $

	xrange=xrange, xcharsize=xcharsize, xmargin=xmargin, xminor=xminor, $
	xstyle=xstyle, xticklen=xticklen, xticks=xticks, $
;	xtitle=xtitle, $
	xtitle=xtitle, xthick=xthick, $					;ras 7-jan-94/jrl 23-feb-94
	
	ycharsize=ycharsize, ymargin=ymargin, yminor=yminor, yrange=yrange, $
	ystyle=ystyle, yticklen=yticklen, ytickname=ytickname, yticks=yticks, $
;	ytickv=ytickv, ytitle=ytitle, $
	ytickv=ytickv, ytickformat=ytickformat, ytitle=ytitle, ythick=ythick, 	$	;ras 7-jan-94/jrl 23-feb-94
	max_value=max_value, zvalue=zvalue 


UTPLOT, X, Y, UTSTRING, LABELPAR=LBL ,SAVE=SAV,TICK_UNIT=TICK_UNIT,$
	MINORS=MINORS , NOLABEL=NOLABEL, YOHKOH=YOHKOH, timerange=timerange, $
	$	;include all keywords available to PLOT
	background=background, channel=channel, charsize=charsize, $
	charthick=charthick, clip=clip, color=color, $
	font=font, linestyle=linestyle, noclip=noclip, nodata=nodata, $
	noerase=noerase, nsum=nsum, polar=polar, $
	position=position, psym=psym, subtitle=subtitle, symsize=symsize, $
	t3d=t3d, thick=thick, ticklen=ticklen, title=title, year=year, $

	xrange=xrange, xcharsize=xcharsize, xmargin=xmargin, xminor=xminor, $
	xstyle=xstyle, xticklen=xticklen, xticks=xticks, $
;	xtitle=xtitle, $
	xtitle=xtitle, xthick=xthick, $					;ras 7-jan-94/jrl 23-feb-94
	
	ycharsize=ycharsize, ymargin=ymargin, yminor=yminor, yrange=yrange, $
	ystyle=ystyle, yticklen=yticklen, ytickname=ytickname, yticks=yticks, $
;	ytickv=ytickv, ytitle=ytitle, $
	ytickv=ytickv, ytickformat=ytickformat, ytitle=ytitle, ythick=ythick, 	  /ytype, $

	max_value=max_value, zvalue=zvalue

end
