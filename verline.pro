;+
; ROUTINE:    verline
;
; PURPOSE:    Draw a vertical line through a given data point
;
; USEAGE:     hline,x
;
; INPUT:
;   x         x-coord of point through which line is to be drawn
;
; OUTPUT:    
 
; Example:    CURSOR,x,y,/data,/down
;   	      VERLINE,x
;             
; AUTHOR:     Peter T. Gallagher, May. '98
;
; MODIFIED:   Ryan Milligan, Nov '03
;   	      inserted color=color
;   	      thick=thick

PRO verline, x, ylog=ylog,linestyle=linestyle,thick=thick,color=color

    IF KEYWORD_SET(ylog) THEN BEGIN
    	PLOTS,[x,x],[10^min(!y.crange) ,10^max(!y.crange) ],$
	    linestyle=linestyle,thick=thick,color=color
    ENDIF ELSE BEGIN
    	PLOTS,[x,x],[min(!y.crange),max(!y.crange) ],$
	    linestyle=linestyle,thick=thick,color=color
    ENDELSE
    
END
