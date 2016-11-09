; Created	2014-03-20	from  /volumes/data/solarsoft/ssw/soho/lasco/lasco/data_anal/adjust_hdr_tcr.pro  to fix the call to NRL_LIB manually.

FUNCTION adjust_hdr_tcr_jpb,hdr,verbose=verbose

;
; ADJUST_HDR_TCR
;+
; Name:
;    ADJUST_HDR_TCR
; Purpose:
;    To return an IDL structure containing corrected date-obs, sun-center, and roll-angle
;    for a input level 0.5 image header. These can then be used to adjust the level-1 image
;     headers in the level-1 processing.
;
; Input Parameters:
;    HDR              - A C1, C2, C3, or C4 (EIT) header. For C1 and C4, only the returned
;                       date-obs is valid (roll is set to zero and center is not changed).
; Output:
;    None
;
; RETURN VALUE:       - This function returns an IDL structure containing the following tags:
;                         DATE: adjusted date-obs (string)
;                         TIME: adjusted time-obs (string)
;                         ERR : delta-erros from the time_correction routine (string)
;                         XPOS: adjusted x-center (float) 
;                         YPOS: adjusted y-center (float) 
;                         ROLL: roll angle (float) degrees
;
; Keywords:
;    VERBOSE           - If set, print out information from various steps of the processing.
;
; Calling Sequence:
;    adj = ADJUST_HDR_TCR(hdr,/verbose)
;
; History:
; 2003 March 11 - Ed Esfandiari (first version).
; 2003 March 11, nbr - Add version info to header; change path derivation of data files
; 2004 April 1 , nbr - Adjust HISTORY kewyords for header
; 2004 July 17, nbr - good thru March 31, 2004
; 2004 Oct 4, nbr - good thru Aug 15, 2004
; 2004 Nov 24, AEE - read in last day from a .sav file instead of hard coded date.
; 2005 Jan 25, AEE - changed linterp call linear_interp.
; 2010 Nov  1, nbr - accomodate new version of sun-center-roll-from-stars sav files
;   	    	     fix history; add common roll_data
; 2012 Nov 30, nbr - slight mod to history text to match time_correction2.pro
; 2013 Jul 30, nbr - fix syntax error in HISTORY stmt
;
version= '@(#)adjust_hdr_tcr.pro	1.13 07/30/13' ; LASCO IDL Library (NRL)
;-

COMMON reduce_history, cmnver, prev_a, prev_hdr, zblocks0
common roll_data, odatafile, last_day ,C_DT,C_R,C_RMED,C_TAI,C_UTC,C_X,C_XMED,C_Y,C_YMED

   if datatype(odatafile) eq 'UND' then odatafile=''

; hdr is a level 0.5 header; adjust_hdr_tcr.pro returns adjusted date, time (plus delta_error), 
; xpos, ypos, and the roll for the hdr as an idl structure. These should then be applied to the
; the L1 header.

  adjusted= {date:'', time:'', err:'', xpos:0.0, ypos:0.0, roll:0.0}
  shdr= hdr
  fits_hdr=1  ; check if input is structure or not
  IF (DATATYPE(shdr) NE 'STC') THEN shdr=LASCO_FITSHDR2STRUCT(hdr) ELSE fits_hdr=0
  tel= strupcase(STRTRIM(shdr.detector,2))
  date= shdr.date_obs
  time= STRTRIM(shdr.time_obs,2)

  IF fits_hdr THEN fxaddpar,hdr,'HISTORY',' '+strcompress(strmid(version,4,strlen(version)))

if datatype(last_day) eq 'UND' then begin
     ldayfile= 'c2_c3_last_post_recovery_day.sav' 
     ;pathldayfile=filepath(ldayfile,ROOT=getenv('NRL_LIB'),SUB=['idl','data','calib']) ;JPB
     pathldayfile=filepath(ldayfile,ROOT='/volumes/data/solarsoft/ssw/soho/lasco',SUB=['idl','data','calib']) ;JPB
     ;pathldayfile='~/idl/sandbox/ed/'+ldayfile
     print,'Restoring ',pathldayfile
     restore,pathldayfile
     ; => last_day (i.e. '2004/10/22'), c2_last_day, c3_last_day
     ;	    last_day is always oldest of two dates
endif

  utclast_day=anytim2utc(last_day)  ; added to fix date formatting issues.  KB 050412
  utcdate= anytim2utc(date)
  IF (utcdate.MJD GT utclast_day.MJD ) THEN BEGIN
  ;IF (date GT '2004/08/15') THEN BEGIN
	;msg='Time not corrected; only available thru 2004-08-15.'
        msg='CNTR/ROLL not corrected; only available thru '+last_day+'.'
	PRINT,''
	PRINT,msg
	IF fits_hdr THEN fxaddpar,hdr,'HISTORY',' '+strcompress(msg)
	PRINT,''
	RETURN,adjusted    
  ENDIF

  IF (KEYWORD_SET(verbose)) THEN $ 
	adj_dt= ADJUST_ALL_DATE_OBS(shdr,/verbose) $
  ELSE $
	adj_dt= ADJUST_ALL_DATE_OBS(shdr)

  IF fits_hdr THEN BEGIN
  ; cmnver is defined as strarr(2) in time_correction.pro
	fxaddpar,hdr,'HISTORY',' '+strcompress(strmid(cmnver[0],4,strlen(cmnver[0])-2))+' using:'
	fxaddpar,hdr,'HISTORY',' '+strcompress(cmnver[1])+': stdev '+strcompress(adj_dt.err)
  	fxaddpar,hdr,'HISTORY',' Original date_obs: '+strcompress(shdr.date_obs)+' '+strcompress(shdr.time_obs)
  ENDIF
  adjusted.date= adj_dt.date
  adjusted.time= adj_dt.time
  adjusted.err= adj_dt.err

  IF (KEYWORD_SET(verbose)) THEN BEGIN
      PRINT,'Input hdr date_obs=    ',anytim2utc(date+' '+time,/ecs)
      PRINT,'Adjusted hdr date_obs= ',anytim2utc(adj_dt.date+' '+adj_dt.time,/ecs)
      HELP,/ST,adjusted
  ENDIF
  ; Add 32.184 sec to match c2[3]_tai from sunDec file:

  tai= utc2tai(anytim2utc(adj_dt.date+' '+adj_dt.time)) + 32.184 

  ;path= getenv('NRL_LIB')+'/lasco/data/calib/'

  CASE tel OF 
	'C2': BEGIN  
		IF (adj_dt.date LT '1998/07/01') THEN $
		datafile ='c2_pre_recovery_adj_xyr_medv2.sav' ELSE $
		datafile ='c2_post_recovery_adj_xyr_medv2.sav'
		if odatafile ne datafile then begin
                   odatafile=datafile
		   ;pathdatafile=filepath(datafile,ROOT=getenv('NRL_LIB'),SUB=['idl','data','calib']) ;JPB
		   pathdatafile=filepath(datafile,ROOT='/volumes/data/solarsoft/ssw/soho/lasco',SUB=['idl','data','calib']) ;JPB
		   ;pathdatafile='~/idl/sandbox/ed/'+datafile
		   print,'Restoring ',pathdatafile
		   restore,pathdatafile
        ;=> c_tai (from sunDec file is 32.184sec ahead of adjusted time in header) is already sorted
        ;=> c_utc (tai changed to utc format)
        ;=> c_dt (tai changed to date/time string)
        ;=> c_x,c_y,c_r,c_xmed,c_ymed,c_rmed 
                endif
	END
	'C3': BEGIN
		IF (adj_dt.date LT '1998/07/01') THEN $
		datafile ='c3_pre_recovery_adj_xyr_medv2.sav' ELSE $
		datafile ='c3_post_recovery_adj_xyr_medv2.sav'
		if odatafile ne datafile then begin
                   odatafile=datafile
		   ;pathdatafile=filepath(datafile,ROOT=getenv('NRL_LIB'),SUB=['idl','data','calib']) ;JPB
		   pathdatafile=filepath(datafile,ROOT='/volumes/data/solarsoft/ssw/soho/lasco',SUB=['idl','data','calib']) ;JPB
		   ;pathdatafile='~/idl/sandbox/ed/'+datafile
		   print,'Restoring ',pathdatafile
		   restore,pathdatafile
        ;=> c_tai (from sunDec file is 32.184sec ahead of adjusted time in header) is already sorted
        ;=> c_utc (tai changed to utc format)
        ;=> c_dt (tai changed to date/time string)
        ;=> c_x,c_y,c_r,c_xmed,c_ymed,c_rmed 
                endif

	END
	ELSE: BEGIN  ; C1 and C4
		PRINT,''
		PRINT,'WARNING: Header is for a '+tel+ $
                      ' image. Only C2 and C3 images can be corrected for sun-center and roll.'
		PRINT,'        (using roll=0.0, xpos=crpix1, ypos=crpix2).'
                ;PRINT,'        (using roll=0.0, xpos= 0.0, ypos= 0.0)'
		PRINT,''
		IF tag_exist(shdr,'crpix1') THEN adjusted.xpos= shdr.crpix1
		IF tag_exist(shdr,'crpix2') THEN adjusted.ypos= shdr.crpix2
                ;adjusted.xpos= 0.0
                ;adjusted.ypos= 0.0
		adjusted.roll= 0.0
		RETURN, adjusted
	END
  ENDCASE

  version2 = datafile
  ind= WHERE(c_tai LE tai, cnt)

  CASE cnt OF
    0: BEGIN  ;hdr time is LT first time of the sunDec file. use the first row. 
	bind=0
	aind=0
	PRINT,'WARNING: Header date_obs < first date_obs row in center and roll file; Using first row.' 
    END
    ELSE: BEGIN
	bind= cnt-1
	IF (LONG(c_tai(bind)) EQ LONG(tai)) THEN $
		aind= bind $  ; found a match 
	ELSE aind= bind+1 
      	IF (aind EQ N_ELEMENTS(c_tai)) THEN BEGIN  ;hdr time is GT last time of the sunDec file. use last row.
        	aind= bind
        	PRINT,'WARNING: Header date_obs > last date_obs row in center and roll file; Using last row.'
      	END
    END
  ENDCASE

  ;help,c_tai,tai,bind,aind

  IF(bind NE aind) THEN BEGIN ; interpolate
    	LINEAR_INTERP,c_tai(bind),c_xmed(bind),c_tai(aind),c_xmed(aind),tai,val
	adjusted.xpos= val
	LINEAR_INTERP,c_tai(bind),c_ymed(bind),c_tai(aind),c_ymed(aind),tai,val
	adjusted.ypos= val
	LINEAR_INTERP,c_tai(bind),c_rmed(bind),c_tai(aind),c_rmed(aind),tai,val
	adjusted.roll= val
	version2=version2+' (interpolated)'
  ENDIF ELSE BEGIN ; bind eq aind
	adjusted.xpos= c_xmed(bind)
	adjusted.ypos= c_ymed(bind)
	adjusted.roll= c_rmed(bind)
  ENDELSE

  IF (KEYWORD_SET(verbose)) THEN BEGIN
	PRINT,'Input hdr date_obs   = ',anytim2utc(date+' '+time,/ecs)
	PRINT,'Adjusted hdr date_obs= ',anytim2utc(adj_dt.date+' '+adj_dt.time,/ecs)
	PRINT,'Now get center and roll for the adjusted date_obs:'
	IF(bind EQ aind) THEN BEGIN
		PRINT,'  Found a matching date_obs, center and roll. No need to interpolate.'
	ENDIF ELSE BEGIN
		PRINT,'  Interpolate for center and roll using these Before and After date_obs:'
		PRINT,'    Before = ',anytim2utc(tai2utc(c_tai(bind)-32.184),/ecs)
		PRINT,'    After  = ',anytim2utc(tai2utc(c_tai(aind)-32.184),/ecs)
	ENDELSE
	HELP,/ST,adjusted
  ENDIF

  IF fits_hdr THEN fxaddpar,hdr,'HISTORY',' '+strcompress(version2)+' last_day='+last_day
  
  RETURN, adjusted

END

