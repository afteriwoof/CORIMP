;+
; Project     : SDAC    
;                   
; Name        : UTHELP
;               
; Purpose     : This procedure prints the normal calling arguments
;		and purpose for the core UT plotting and time
;		conversion routines developed at the SDAC.
;               
; Category    : UTPLOT 
;               
; Explanation : A text file is read and displayed.
;               
; Use         : UTPLOT [,/LONG]
;    
; Inputs      : 
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : LONG- Display the long format help file.
;
; Calls       : RD_ASCII, MORE, LOC_FILE, BREAK_PATH
;
; Common      : UTCOMMON, UTSTART_TIME
;               
; Restrictions: The UTPLOT directory should be in the !path.
;               
; Side effects: None.
;               
; Prev. Hist  :
;        written AKT -- ???
;        made UNIX/VMS compatible (DMZ, ARC April'93)
;
; Modified    : RAS, 5-feb-1997, looks for help files in !path.
;
;-            
;==============================================================================
pro uthelp,long=long
 
on_error, 1

@utcommon
@utstart_time_com

 
path = break_path(!path)
 
help_file = 'utplot_' + (['short','long'])(keyword_set(long))+ '.txt' 
 
 
 
look=loc_file(help_file,path = path, count=nf)
 
 
if nf eq 0 then message,'UTPLOT help files unavailable'
 
more, rd_ascii( look )
 
;
;PRINT THE VALUES IN UTCOMMON
;
; The explicit references to values in common should be replaced
; by a call to GETUT, /strin, utb=utbase, uts=utstart, ute=utend
;
print,' '
print,'Current values of base, start, and end times:
utstring=['UTBASE  = ','UTSTART = ','UTEND   = ']
;************************************                                                      
for index=0,2 do begin 
    ;PRINT THE VALUE OF THE INDICATED UTXXX IN COMMON IN ASCII FORMAT
    if index eq 0 then  s=size(utbase) 
    if index eq 1 then  s=size(utstart) 
    if index eq 2 then  s=size(utend) 
    IF s(1) EQ 0 THEN utout=-1 ELSE BEGIN
        CASE INDEX OF
            0: utout=utbase
            1: utout=utstart
            2: utout=utend
            ENDCASE
        ENDELSE
    if utout eq -1 then utout='NOT DEFINED' else utout=anytim(utout,out='atime')
    ;
    print,utstring(index)+' '+utout
    endfor ;close loop over common variables
;************************************
;START TIME LABEL, PRINT IT?
CHECKVAR,PRINT_START_TIME,1
PRINT, ' '
CASE PRINT_START_TIME OF
    0: PRINT,'Start time label will not be written on plot.'
    1: PRINT,'Start time label will be written on plot.'
    ENDCASE
 
 
 
end
