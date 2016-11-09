;+
; Project     : SDAC
;
; Name        : YYDOY_2_UT
;
; Purpose     : This function converts time from Year (YY)  and Day of Year (DOY)
;		into the UTIME format, sec from 1-jan-1979.
;
; Category    : UTPLOT, TIME
;
; Explanation :
;
; Use         : Ut = YYDOY_2_UT('YYDOY') or
;		Ut = YYDOY_2_UT( [yy, doy] )
;
; Inputs      : Time - [YY,DOY] a 2 element or 2 x n vector
;		 or a string or string array in the format 'YYDOY'
;		 where YY is the last 2 digits of the year from 1950-2049,
;		 i.e. 80 for 1980.
;
;		Also accepts years as 4 digit numbers or strings. Cannot
;		mix 4 digit years with 2 digit years for string input.
;
;
; Opt. Inputs : None
;
; Outputs     : The function returns time in double precision seconds from
;		1-jan-1979, the ANYTIM(input, /sec) format.
;
; Opt. Outputs: None
;
; Keywords    :
;
; Calls       : DATATYPE, UTIME
;
; Common      : None
;
; Restrictions:
;                Limited to 1950-2049
; Side effects: None.
;
; Prev. Hist  :
;		RAS, 93/1/25
;
; Modified    :
;               Version 2, RAS, 5-feb-1997, documentation header updated
;		Version 3, RAS, 19-Mar-1997, accepts 4 digit years
;	2-oct-2012, richard.schwartz@nasa.gov, converted to [] syntax using idlv4_to_v5;
;-

function yydoy_2_ut, yydoy; convert year and day to utime,vec or string

yrday = yydoy
dim = (size( yydoy))[0] ;dimension of input array

;GET STRING YEAR AND CONVERT DAY TO OFFSET UTIME

type = datatype( yrday )
if type eq 'STR' then begin

;HELPBLOCK
  if STRUPCASE(yrday[0]) eq 'HELP' then begin
	print,'yydoy_2_ut(yydoy) ; convert year and day to utime,[yy,doy] or ''yydoy'''
	print,'		or use 4 digit years, [yyyy,doy] or "yyyydoy"'
	ans=0
	goto,return1
  endif
;HELPBLOCK

  sdoy = strarr(n_elements(yrday))
  syy  = sdoy
  slen = strlen(yrday)
  w5 = where( slen eq 5, n5)
  if n5 ge 1 then begin
    sdoy[w5] = strmid(yrday[w5],2,3)
    syy[w5]  = strmid(yrday[w5],0,2)
  endif
  w7 = where( slen eq 7, n7)
  if n7 ge 1 then begin
    sdoy[w7] = strmid(yrday[w7],4,3)
    syy[w7]  = strmid(yrday[w7],0,4)
  endif
  doy=fix(sdoy) ;convert string to integer
  goto,ans1

endif else begin ; 2xn array of years and days of year

; vector of yr and doy: [yr,doy]
  yrday = reform( yrday, 2, n_elements(yrday)/2)
  syy=strtrim(fix(yrday[0,*]),2)
  doy=yrday[1,*]

ENDELSE

;convert to utime
ANS1:
ans = ( utime( '1-jan-'+syy[*] ) + (doy[*]-1)*86400.d0 )[*]

;if a scalar or 1d vector passed, then return a scalar

if ((type ne 'STR') and (dim eq 1)) or $
	((type eq 'STR') and (dim eq 0)) then ans = ans[0]

RETURN1:

return, ans
end
