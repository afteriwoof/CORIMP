; Created	2014-03-20	from  /volumes/data/solarsoft/ssw/soho/lasco/lasco/convert/read_occ_dat.pro  to manually fix the NRL_LIB environment call.

;+
; NAME:
;         READ_OCC_DAT
;
; PURPOSE:
;         Returns an array of structures containing LASCO occulter centers, and EIT Sun Centers
;
; CATEGORY:
;         LASCO CONVERT
;
; CALLING SEQUENCE:
;         Result = READ_OCC_DAT ()
;
; INPUTS:
;         None
;
; OUTPUTS:
;         Result = 4 by 5 by 2 element array of structures containing:
;			 4 for C1,C2,C3,EIT
;			 5 for filter position
;			 2 for valid dates (now have only two)
;                   Result.xcen    ;double: x center of occulter
;                   Result.ycen    ;double: y center of occulter
;                   Result.mjd     ;long: start date of validity
;
; RESTRICTIONS:
;         The file occulter_center.dat must exist in $NRL_LIB/lasco/convert
;
; MODIFICATION HISTORY:
;         Written,  SE Paswaters, NRL
;         Version 1  sep  30 Aug 1996
;         Version 2  rah  27 Nov 1998	added valid date
;	11 Jan 2002, nbr - Change path for windows compatibility
;       Karl Battams   2 Nov 2005 - Add swap_if_little_endian keyword for opening binary data files
;
; 11/02/05 @(#)read_occ_dat.pro	1.9 :NRL Solar Physics
;
;
;-

FUNCTION READ_OCC_DAT_jpb

   occ = {occ, xcen:0.0D, ycen:0.0D, mjd:0L }
   occ_cen = REPLICATE(occ,4,5,2)

   ;f = FILEPATH('occulter_center.dat', ROOT_DIR='$NRL_LIB', SUBDIRECTORY='lasco/convert')
   ;f = FILEPATH('occulter_center.dat', ROOT_DIR='$NRL_LIB', SUBDIRECTORY=['lasco','convert'])
   ;f = FILEPATH('occulter_center.dat', ROOT_DIR=GETENV('NRL_LIB'), SUBDIRECTORY=['idl','convert']) ;JPB
   f = FILEPATH('occulter_center.dat', ROOT_DIR='/volumes/data/solarsoft/ssw/soho/lasco', SUBDIRECTORY=['idl','convert']) ;JPB

   OPENR, lu, f, /GET_LUN,/swap_if_little_endian
   str = ''
   first = 1
   READF, lu, str
   i = 0
   j = 0
   WHILE NOT(EOF(lu)) DO BEGIN
      READF, lu, str
      IF (STRLEN(str) GT 0)  THEN BEGIN
         xcen = DOUBLE(STRMID(str, 0, 7))
         ycen = DOUBLE(STRMID(str, 8, 7))
         datest = STRMID(str,16,10)
         dte = STR2UTC(datest)
         occ_cen(i/5,i MOD 5,j).xcen = xcen
         occ_cen(i/5,i MOD 5,j).ycen = ycen
         occ_cen(i/5,i MOD 5,j).mjd = dte.mjd
      ENDIF
      IF (j EQ 1)  THEN BEGIN
         i = i+1
         j = 0
      ENDIF ELSE BEGIN
         j = 1
      ENDELSE
   ENDWHILE

   CLOSE, lu
   FREE_LUN, lu

   RETURN, occ_cen

END
