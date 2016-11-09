;+
;
; NAME:
;	DUMMYPLOTS
;
; PURPOSE:
; 	This procedure is called by utplot to set up plot system variables without actually drawing
; 	a plot.  Used to find out what the exact x limits (x.crange) of the plot will be.
;
;
; CATEGORY:
;	UTIL, UTPLOT, GRAPHICS, TIME
;
; CALLING SEQUENCE:
;	DUMMYPLOTS, X=X,Y=Y
;
; CALLS:
;	none
;
; INPUTS:
;       X - array of x values
;
; OPTIONAL INPUTS:
;	Y - array of y values
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	none
; COMMON BLOCKS:
;	none
;
; SIDE EFFECTS:
;	The !X  structure is changed.
;
; RESTRICTIONS:
;	This procedure is buried deep inside Utplot and should not be called
;	independently since it may be changed at any time by the author as unlikely
;	as that seems.
;
; PROCEDURE:
;	The plot device is set to 'NULL' and the plot command is given.  The
;	!X and !Y variables are changed by the call.  The plot device is set
;	back to the input device.
;
; MODIFICATION HISTORY:
; 	Version 1, Written by Richard Schwartz, Feb. 1991
;	Version 2, RAS, 14-August-1996, cleaned !p.color problem
;	Version 3, richard.schwartz@gsfc.nasa.gov, 14-may-1998, cleared the
;	!p.background problem which was identical to the !p.color problem.
;	9-apr-2007, ras, uses 'z' instead of 'null' device for gdl
;-


pro dummyplots,x=x,y=y
;
checkvar,y,x*0.0 ;if no y then set y to zero of length x
XSTYLEOLD=!X.STYLE
YOLD=!Y
!X.STYLE=XSTYLEOLD OR 4L
!Y.STYLE=YOLD.STYLE OR 4L
old_device=!d.(0)
pcolor = !p.color
pbackground = !p.background
if is_gdl() then set_plot,'z' else SET_PLOT,'NULL'

plot,x,y,/noeras,/nodata

set_plot,old_device
!p.color = pcolor
!p.background = pbackground
!X.STYLE=XSTYLEOLD
!Y=YOLD
;LIMITS DETERMINED

end


