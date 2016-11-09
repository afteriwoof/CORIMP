
PRO SETUT,UTBASE=BASE,UTSTART=START,UTEND=END1,error=error, set_utplot=set

on_error,2
; !quiet=1
;+
; NAME:
;	SETUT
; PURPOSE:
;	Set base,start, or end time in common UTCOMMON.
;	SETUTBASE, SETUTSTART, and SETUTEND are all implemented through
;	SETUT as in SETUTBASE,'UTSTRING'.
;	When using UTPLOT, UTPLOT_IO, or OUTPLOT command, X array is
;	assumed to be in seconds relative to the base time.
;       Note: UTBASE, UTSTART, and UTEND are in common UTCOMMON and can
;	also be set directly (double precision seconds relative to
;	79/1/1, 00:00).
;	Can also be used to call SET_UTPLOT which creates !x.tickv and
;	!x.tickname.
; CATEGORY:
;
; CALLING SEQUENCE:
;	SETUT, UTBASE=BASE, UTSTART=START, UTEND=END, ERROR=ERROR, $
;		SET_UTPLOT=SET
;
; INPUT PARAMETERS:
;	BASE, START, or END - ASCII string in format YY/MM/DD,HHMM:SS.XXX.
;	   Sets UTBASE, UTSTART, or UTEND variables in common UTCOMMON to the
;	   number of seconds since 79/1/1, 0000.
; 	   Partial strings are allowed.  If the date is omitted, the last date
;	   passed (for base, start, or end time) is used.
;	   For example, if the string '88/3/4,1230' had already been passed:
;	   '1200'      means 88/3/4,1200
;	   '01'        means 88/3/4,0001        (1 minute into the day)
;	   '01:2'      means 88/3/4,0001:02.000 (1 min., 2 sec into day)
;          '1200:20.1' means 88/3/4,1200:20.100 (20.100 sec. after 12)
;	ERROR - 0/1 indicates no error/error in converting ASCII time to
;	   double precision seconds.
;	SET_UTPLOT - if 1 and START and END are set then SET_UTPLOT is called
;	for those values, remembered in subsequent calls.
;		   - if 0 then SET_UTPLOT is not called or subsequently.
;
; OUTPUTS:
;	None.
; OPTIONAL OUTPUT PARAMETERS:
;	None.
;
; COMMON BLOCKS:
;	COMMON UTCOMMON, UTBASE, UTSTART, UTEND = base, start, and
;	end time for X axis in double precision variables containing
;	seconds since 79/1/1, 00:00.
;	COMMON LASTDATECOM, LASTDATE = YY/MM/DD string for last entry
;	into SETUT
;	COMMON SETCOMMON, SETPLOT
;
; SIDE EFFECTS:
;	UTXXXX in common UTCOMMON is set to time passed in string translated
;	into a double precision floating point value representing the time
;	in seconds since 79/1/1, 00:00.  Function ATIME can be used to
;	display this time as an ASCII string.  If switch SET_UTPLOT is used
;	then the procedure SET_UTPLOT is called with the new values of
;	UTBASE, UTSTART, and UTEND.
;
; RESTRICTIONS:
;	Times must be between 79/1/1 and 99/1/1.  A base time must be set before
;	plotting with UTPLOT (or UTPLOT_IO), however the easiest ways to set it
;	are either in the calling arguments to UTPLOT (or UTPLOT_IO) or by
;	letting UTPLOT (or UTPLOT_IO) prompt for it.
;
; PROCEDURE:
;	Keyword parameters are used to route the input string(s) to their
;	proper variable in UTCOMMON.
;	UTIME is called to translate UTSTRING to epoch day and msec,
;	UTBASE is epoch day * 86400 + msec/1000 from 79/1/1
;
; MODIFICATION HISTORY:
;	Written by Kim Tolbert, 4/88
;	Modified for IDL Version 2 by Richard Schwartz, 2/91
;	Keyword SET_UTPLOT added 9/91
;	Corrections and new comments added 10/91 by RS.
;	Modified to accept Yohkoh time format, 6/93 by ras.
;   Modified by Kim, 12/3/99. Init utstring1 to '' before reading into it.
;-
;
@utcommon
;COMMON UTCOMMON, UTBASE, UTSTART, UTEND
COMMON LASTDATECOM, LASTDATE
COMMON SETCOMMON, SETPLOT
CHECKVAR,LASTDATE,'0' ;DEFAULT VALUE
CHECKVAR, SETPLOT, 0  ;DEFAULT VALUE - don't call set_utplot
CHECKVAR, SET, -1 ;DEFAULT VALUE, nothing is passed
if SET eq 1 then SETPLOT = 1
if SET eq 0 then SETPLOT = 0
error = 0
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Set the right variable in common
;FIND WHICH PARAMETERS HAVE BEEN PASSED
s_base=size(base)
s_start=size(start)
s_end1=size(end1)
;
;..............................
;SETUT works in one of two ways.  The first way is by calls to SETUTBASE,
;SETUTSTART, or SETUTEND.  In these routines, the time is either passed directly
;or it is passed interactively.  The second way is by passing parameters
;directly into SETUT using the keyword parameters UTBASE, UTSTART, and UTEND.
;
;Process calls to SETUTBASE, SETUTSTART, or SETUTEND
;..............................
;
index = -1
IF s_base(1) gt 0 THEN INDEX=0
IF s_start(1) gt 0 THEN INDEX=1
IF s_end1(1) gt 0 THEN INDEX=2
WHICHTIME=['base','start','end']
;
CASE INDEX OF
   0: UTSTRING=BASE
   1: UTSTRING=START
   2: UTSTRING=END1
   ELSE: BEGIN
      ERROR=1
      RETURN
   ENDELSE
ENDCASE
;
;This block is to be used only if one variable is to be set interactively
;Only SETUTXXXX should be entering this block
IF UTSTRING EQ '-1' THEN BEGIN
   UTSTRING1 = ''
   READ,'Enter '+WHICHTIME(INDEX)+' time.  ' + $
	'Format is YY/MM/DD,HHMM:SS.XXX or DD-MON-YY HH:MM:SS.XXX', UTSTRING1

;
;
;   if no date is given, i.e. 'YY/MM/DD,' isn't included in the string
;   then use the most recent date string appearing in a call to SETUT

   IF STRPOS(UTSTRING1,'/')  NE -1 or strpos(Utstring1,'-') ne -1 THEN $
		$ 			;date is included!!!!
		LASTDATE=STRMID( $
		ATIME(/hxrbs, UTIME(UTSTRING1,err=error)),0,8) $;REMEMBER DATE
	ELSE $
		IF (LASTDATE NE '0') AND (UTSTRING1 NE '0') THEN $
			UTSTRING1=LASTDATE+', '+UTSTRING1
  		IF UTSTRING1 EQ '0' THEN $
			UTOUT=0.D0 ELSE $
			UTOUT=(UTIME(UTSTRING1,err=error))(0)

   if not error then begin
     CASE INDEX OF
 	0: UTBASE=UTOUT
	1: UTSTART=UTOUT
	2: UTEND=UTOUT
     ENDCASE
   endif ;close error check
ENDIF $
$;......................................................................
$;......................................................................
$;......................................................................
ELSE BEGIN
;
;PROCESS NON-INTERACTIVE CALLS TO SETUT OR SETUTXXX
;
;At least one parameter has been passed where UTXXX isn't -1, so
;process each parameter string into its appropriate common variable.
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Set the right variable in common
;*************************UTBASE************************************
 IF s_base(1) gt 0 THEN begin
  if datatype(base) eq 'STR' then utstring1 = base else $
	UTSTRING1=anytim(BASE, out='hxrbs')
  IF STRPOS(UTSTRING1,'/') NE -1 or strpos(Utstring1,'-') ne -1 THEN $
	LASTDATE=STRMID(ATIME(/hxrbs, UTIME(UTSTRING1,err=error)) ,0,8) $;REMEMBER DATE
	ELSE IF (LASTDATE NE '0') AND (UTSTRING1 NE '0') THEN $
	UTSTRING1=LASTDATE+', '+UTSTRING1
  IF UTSTRING1 EQ '0' THEN UTOUT=0.D0 ELSE UTOUT=UTIME(UTSTRING1,err=error)
  if not error then UTBASE=UTOUT(0)
 ENDIF
;*************************UTSTART***********************************
 IF s_start(1) gt 0 THEN BEGIN
  if datatype(start) eq 'STR' then utstring1 = start else $
	UTSTRING1=anytim(START, out='hxrbs')
  IF STRPOS(UTSTRING1,'/') NE -1 or strpos(utstring1,'-') ne -1 THEN $
	LASTDATE=STRMID(ATIME(/hxrbs,UTIME(UTSTRING1,err=error)),0,8) $;REMEMBER DATE
   	   ELSE IF (LASTDATE NE '0') AND (UTSTRING1 NE '0') THEN $
	UTSTRING1=LASTDATE+', '+UTSTRING1
  IF UTSTRING1 EQ '0' THEN UTOUT=0.D0 ELSE UTOUT=UTIME(UTSTRING1,err=error)
  if not error then UTSTART=UTOUT(0)
 ENDIF
;*************************UTEND*************************************
 IF s_end1(1) gt 0 THEN BEGIN
  if datatype(end1) eq 'STR' then utstring1 = end1 else $
	UTSTRING1=anytim(END1, out='hxrbs')
  IF STRPOS(UTSTRING1,'/') NE -1 or strpos(utstring1,'-') ne -1 THEN $
	LASTDATE=STRMID(ATIME(/hxrbs, UTIME(UTSTRING1,err=error)),0,8) $;REMEMBER DATE
	ELSE IF (LASTDATE NE '0') AND (UTSTRING1 NE '0') THEN $
	UTSTRING1=LASTDATE+', '+UTSTRING1
  IF UTSTRING1 EQ '0' THEN UTOUT=0.D0 ELSE UTOUT=UTIME(UTSTRING1,err=error)
  if not error then UTEND=UTOUT(0)
 ENDIF
;*************************UTEND*************************************
ENDELSE
;
;Call SETUTPLOT with the new values of UTBASE, UTSTART, UTEND if SET
	if SETPLOT and keyword_set(UTEND) and $
		keyword_set(UTSTART) then $
		SET_UTPLOT, XRANGE = [UTSTART, UTEND] - UTBASE
$;......................................................................
$;......................................................................
$;......................................................................
RETURN
END
