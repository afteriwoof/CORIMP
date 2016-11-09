;+
; Project     : SDAC    
;                   
; Name        : SET_UTLABEL
;               
; Purpose     : This procedure controls the default for a date
;		label under UTPLOT.PRO.
;               
; Category    : UTPLOT, GRAPHICS
;               
; Explanation : A logical in a common block is set or reset.
;               
; Use         : SET_UTLABEL, 0		;Disables labeling.
;		SET_UTLABEL, 1		;Enables labeling.
;		    
; Inputs      : Option- 1 to set, 0 to reset. Default is reset.
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : 
;
; Calls       :
;
; Common      : UTSTART_TIME
;               
; Restrictions: Utplot directory in !path.
;               
; Side effects: None.
;               
; Prev. Hist  : Written about 1988 by RAS
;
; Modified    : Documentation header, 5-Feb-1997.
;
;-            
pro set_utlabel, option

on_error, 2

@utstart_time_com

checkvar, option, 0
print_start_time = option

end
