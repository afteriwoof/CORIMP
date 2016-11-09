;+
; Project     : SDAC    
;                   
; Name        : YOHKOH_FORMAT
;               
; Purpose     : This procedure sets the default style
;		for ATIME.PRO to the Yohkoh format, i.e.
;		dd-mon-yr  hh:mm:ss.xxx
;               
; Category    : UTPLOT, TIME
;               
; Explanation : A logical in the common is set.
;               
; Use         : YOHKOH_FORMAT
;    
; Inputs      : None
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : OLD_FORMAT - Format before changing.
;
; Calls       :
;
; Common      : UTSTART_TIME_
;               
; Restrictions: UTPLOT directories should be in !path.
;               
; Side effects: None.
;               
; Prev. Hist  : First written, RAS, 1988?
;
; Modified    : 
;		1/10/94 by AKT to return old format
;		RAS, 5-Feb-1997, completed documentation.
;-            
;==============================================================================
pro yohkoh_format, old_format = old_format

on_error,2

@utstart_time_com
old_format = atime_format
atime_format = 'YOHKOH'
 
end
