pro utcursor,x,y,xd, normal=normal, data=data, device=device, err=err, $
	mark=mark, label=label, yrange=yrange, ticks=ticks, quiet=quiet
;
;+
;   Name: utcursor
;
;   Purpose: allow user to click on utplot and return utplot time 
;
;   Calling Sequence:
;      (first display utplot)
;      utcursor,x [,y, xd, /normal, /data, /device ,
;		   /mark , /label , yrange=[y0,y1], /ticks , /quiet ,
;		   err=err ]
;
;   Output Parameters:
;     x -  time coordinate (Yohkoh internal time  format)
;     y -  y coordinate (default is data, use /device or /normal to override)
;     xd - x coordinate (same format as y)
;
;   Keyword Parameters:
;     data, device, normal - switches specify y, xd output 
;     mark, label, ticks - switches to control labeling (see evt_grid.pro)
;     yrange - [y0,y1] in normalized coord for evt_grid vertical line
;     err - gets !err value after selection
;
;   History:
;      11-Dec-1993 (SLF)
;-

; find utplot start time
qtemp=!quiet
getut, utbase=startt, /string  
!quiet=qtemp
;
; now get input
quiet=keyword_set(quiet)
if not quiet then message,/info,'Click on desired feature...'
cursor, xd, y, /data, /down
err=!err
x=anytim2ints(startt,offset=xd)
if not quiet then message,/info,'Time Selected: ' + fmt_tim(x)

; convert y and xd to desired coord type.
xy=convert_coord([xd,y], /data, $
	to_normal=keyword_set(normal),  to_device=keyword_set(device))
xd=xy(0) & y=xy(1)

; mark plot if requested
evt_grids=keyword_set(label) or keyword_set(yrange) or keyword_set(ticks) or $
	keyword_set(mark)
if evt_grids then evt_grid, x, yrange=yrange, ticks=ticks, label=label
 
return
end
