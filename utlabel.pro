pro utlabel,label,xposition=xpos,yposition=ypos, color=color
on_error,2
; !quiet=1
;+
; NAME: UTLABEL
; PURPOSE: Print start date and time on plot drawn with UTPLOT routine.
; Called by UTPLOT.
; CALLING SEQUENCE: UTLABEL,LABEL,XPOS=XPOS,YPOS=YPOS
; CALLING PARAMETERS:
;	LABEL -	Date and time string to be written
;	XPOS -	x value of location where LABEL will be printed in
;		normalized coordinates.
;	YPOS -	Same as x for y location for printing LABEL.
;	COLOR-  Normal color keyword
; MODIFICATION HISTORY:
;	Written by Richard Schwartz, Feb. 1991
;-
checkvar,xpos,.5 ;START POSITION OF STRING IN NORMALIZED WINDOW COORDINATES
checkvar,ypos,.9
checkvar, color, !p.color

xlen=.5*(!p.clip(2)-!p.clip(0)) ;half-width for xwindow in device uints
size=    fix(xlen/!d.x_ch_size)/1.1/34 ;scale x_character size in char. units
xloc=!x.window(0)+xpos*(!x.window(1)-!x.window(0)) ;.5 of window in norm. coord.
yloc=!y.window(0)+ypos*(!y.window(1)-!y.window(0)) ;.9 of window in norm. coord.
xyouts,/norm,size=size,xloc,yloc,label, color= color
return
end
