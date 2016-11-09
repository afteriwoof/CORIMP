;+
; Project     : SDAC     
;                   
; Name        : UT_2_YYDOY 
;               
; Purpose     : This function converts time from UTIME format, sec from 1-jan-1979,
;		to Year (YY)  and Day of Year (DOY) as integers or strings.
;               
; Category    : UTPLOT, TIME
;               
; Explanation : 
;               
; Use         : YYDOY = UT_2_YYDOY( Ut )
;    
; Inputs      : Ut - Time in ANYTIM.PRO readable format.
;               
; Opt. Inputs : None
;               
; Outputs     : The funtion returns the output:
;	  Default is a 2xN element INTARR where the first column is
;         YY, the truncated year (i.e. 79 for 1979)
;         and the second column is
;         DOY, the day number where 1 January is DOY=1
;         If only one time is passed, then a 2 element vector is returned
;
;
; Opt. Outputs: None
;               
; Keywords    : STRING - If set, return answer as string 'YYDOY'
;
; Calls       : ANYTIM, DAYCNV, JDCNV
;
; Common      : None
;               
; Restrictions: 
;		 Limited to 1950-2049              
; Side effects: None.
;               
; Prev. Hist  :
;	RAS, 93/1/25
;	ras, 7-jan-94, take advantage of anytim	
;
; Modified    : 
;		Version 3, RAS, 5-feb-1997, documentation header updated
;
;-            
;==============================================================================
;
function ut_2_yydoy, ut0, string=string ; convert utime to year and doy


ut = anytim( ut0,/utime,/date) 	;ras, 7-jan-94


nut   = n_elements(ut) 
eday  = 2443874.5 ;julian day for epoch day, 79/1/1
jday  = ut/86400. + eday ;convert input time to julian days
daycnv, jday, yr, mm, dd, hh ;FIND the year
jdcnv, yr, 1, 1, 0.0, jdyr ;julian day of the start of the year
doy   = jday - jdyr +1
yy    = fix(yr mod 100) ;extract the last two digits


if not keyword_set(string) then $
	if nut ge 2 then $
		ans= reform( [reform(yy,1,nut),reform(doy,1,nut)]) else $
		ans = [yy,doy] $
else begin
	sdoy  = strmid(string(doy,'(i8.8)'),5,3) 
	syy   = strmid( strtrim(yr,2),2,2)
	ans   = syy + sdoy
endelse	

RETURN1:

return,ans 
end

