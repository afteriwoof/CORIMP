;+
;
; NAME: 
;	SYS2UT
;
; PURPOSE:
; function to get current time (which is given in seconds since 70/1/1) and
; convert it to seconds since 79/1/1,0 so we can use atime and get ASCII
; time in our normal format yy/mm/dd,hhmm:ss.xxx
;
;
; CATEGORY:
;	GEN
;
; CALLING SEQUENCE:
;	result = SYS2UT()
;
; CALLS:
;	none
;
; INPUTS:
;       none, dummy 
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       The result is time in seconds from 1-jan-1979
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
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	Uses IDL systime function. Time from 1-jan-1970.
;
; MODIFICATION HISTORY:
; akt 4/7/91
;
;-


;
function sys2ut,x
return,systime(1) - 2.8399680d+08	;systime(1)+ utime('1-jan-1970')
end
