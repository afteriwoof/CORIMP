function occltr_cntr_jpb,hdr
;
;+
; NAME:
;	OCCLTR_CNTR
;
; PURPOSE:
;	This function returns the center of the occulting disk (for LASCO)
;       and Sun Centers (for EIT) as a 2 element array of the column and
;       row numbers.  The number starts at 0.  The definition in the FITS
;	header is starting from 1.
;       
;
; CATEGORY:
;	LASCO_ANALYSIS
;
; CALLING SEQUENCE:
;	Result = OCCLTR_CNTR (Hdr)
;
; INPUTS:
;	Hdr:	A FITS header for the image that the center is desired. 
;               It can be either a string header  or a structure header.
;
; OUTPUTS:
;	This function returns the occulter center as a two element array
;	in which the first element is the column center and the second
;	element is the row center.
;
; RESTRICTIONS:
;	Returns the center for the readout port "C"
;
; PROCEDURE:
;       occulter_center.dat file is used first but if related data is 
;       not found, then default values that have been determined by
;       other means and put into a table, here, are used.
;
; MODIFICATION HISTORY:
; 	Written by:	R.A. Howard, 14 March 1996
;	17 Oct 96	RAH, Revised C1 coords
;	04 Dec 96	RAH, Corrected case statement default value
;       01 Dec 98       AEE, added code to use occulter_center.dat before 
;                            attempting to use the defaults in this file.
;                            Also added defaults for EIT in the case statement.
;	14 Mar 01	NBR, Use different method to retrieve C3 center using
;				time-varying points
;	 3 Dec 01	NBR, Change path to Windows and SSW compatible for GSV
;
;	12/07/01, @(#)occltr_cntr.pro	1.9 - LASCO NRL IDL LIBRARY
;-

; no corrections for port yet

shdr= hdr
IF (DATATYPE(hdr) EQ 'STC')  THEN shdr= STRUCT2FITSHDR(hdr)

tel = STRTRIM( strupcase( fxpar (shdr,'DETECTOR') ) ,2 )
;port = STRTRIM( strupcase ( fxpar (shdr,'READPORT') ) ,2 )
filt = STRTRIM( strupcase ( fxpar (shdr,'FILTER') ) ,2 )
sect = STRTRIM( strupcase ( fxpar (shdr,'SECTOR') ) ,2 )
datest = STRTRIM( strupcase ( fxpar (shdr,'DATE-OBS') ) ,2 )
dte= STR2UTC(datest)
mjd= dte.mjd

IF tel EQ 'C3' THEN BEGIN
   ;file = FILEPATH('c3_occltr_cntr.dat', ROOT_DIR='$NRL_LIB', SUBDIRECTORY=['lasco','convert'])
   ;file = FILEPATH('c3_occltr_cntr.dat', ROOT_DIR=getenv('NRL_LIB'), SUBDIRECTORY=['idl','convert'])
   file = FILEPATH('c3_occltr_cntr.dat', ROOT_DIR='/volumes/data/solarsoft/ssw/soho/lasco', SUBDIRECTORY=['idl','convert'])
   list = READLIST(file)
   n = n_elements(list)
   dates = LONARR(n-2)
   xpos  = FLTARR(n-2)
   ypos  = xpos
   FOR i=2,n-1 DO BEGIN
	parts = STR_SEP(list[i],' ')
	utcdte = STR2UTC(parts[0])
	dates[i-2]=utcdte.mjd
	xpos[i-2]=FLOAT(parts[1])
	ypos[i-2]=FLOAT(parts[2])
   ENDFOR
   indx = FIND_CLOSEST(mjd,dates)
   return,[xpos[indx],ypos[indx]]
ENDIF

all_occ= READ_OCC_DAT_jpb ()

;Get all the center rows for the current "telescope and filter". Each row has
;a different mjd date (in asscending order) but last row may be blank (row's 
;mjd may be zero).

cams = ['C1','C2','C3','EIT']
loc= where(cams eq tel,cnt)
IF(cnt eq 0) THEN BEGIN
  print,'%OCCLTR_CNTR, Telescope not recognized '+tel
  ctr= -1
ENDIF ELSE BEGIN
  camera= loc(0)
  IF (camera EQ 3) THEN filter = CNVRT_POLAR(camera, sect) $
                   ELSE filter = CNVRT_FILTER(camera, filt)

  filter= filter(0) 
  tel_fil= all_occ(camera,filter,*)
  loc= where(tel_fil.mjd le mjd and tel_fil.mjd ne 0,cnt)
  IF (cnt gt 0) THEN BEGIN
    row= cnt-1  
    ctr= [tel_fil(loc(row)).xcen,tel_fil(loc(row)).ycen]   
  ENDIF ELSE BEGIN
    IF (camera EQ 3) THEN tf= tel+','+strtrim(sect,2) $
                     ELSE tf= tel+','+strtrim(filt,2)
    print,'%OCCLTR_CNTR, Occultation center not found ('+tf+').'
    ctr= -1 
  ENDELSE
ENDELSE

IF(ctr(0) eq -1) THEN BEGIN
  print,'%OCCLTR_CNTR, Using default occultation center.'
  CASE tel OF
  'C1':  CASE filt OF
           'FE X':    ctr = [511.029,494.521]	;10/17/96
           'FE XIV':  ctr = [510.400,495.478]	;10/17/96
           else:      ctr = [511,495]
         ENDCASE
  'C2':  CASE filt OF
           'ORANGE':  ctr = [512.634,505.293]	;3/18/96
           else:      ctr = [512.634,505.293]	;3/18/96
         ENDCASE
  'C3':  CASE filt OF
           'ORANGE':  ctr = [516.284,529.489]	;3/18/96
           'CLEAR':   ctr = [516.284,529.489]	;3/18/96
           else:      ctr = [516.284,529.489]	;3/18/96
         ENDCASE
  'EIT': CASE sect OF
           '195A':    ctr = [505.500,514.300]
           else:      ctr = [505.500,514.300]
         ENDCASE
  else: BEGIN
          print,'%OCCLTR_CNTR, No default occultation center for '+tel
        END
  ENDCASE
ENDIF

RETURN,ctr

END
