function c2_warp_jpb,image0,header
;+
; NAME:
;       C2_WARP 
;
; PURPOSE:
;       This function distorts a C2 image and returns it. 
;
; CALLING SEQUENCE:
;       Result = C2_WARP(Image,Header) 
;
; INPUTS:
;       Image :   C2 image to be distorted
;       Header:   C2 image header 
;
;
; OUTPUTS:
;       The distorted FFV image is returned. Control points at every 32 pixels
;       are used for distortion. If input is a subfield, FFV is returned.
;
; COMMON BLOCKS:
;       NONE
;
; MODIFICATION HISTORY:
;               Written  Ed Esfandiari, NRL
;   Version 1   aee 19 Nov 1998    Initial release (based on C3_WARP)
;               aee 24 Nov 1998    changed get_sun_center call to occltr_cntr.
;               dw  10 Dec 1998    Corrected handling of summed images
;		NBR 24 Aug 2000	   Switch x/y and x0/y0 around in call to WARP_TRI;
;				   Add reduce_history COMMON block
;   	    	NBR 16 Nov 2012     Add reduce_std_size.pro to handle subfield.
;
; KNOWN BUGS:
;
; 1. Subfield images are not handled completely
;
;        '11/16/12 @(#)c2_warp.pro	1.6'
version= '11/16/12 @(#)c2_warp.pro	1.6' ; NRL LASCO IDL LIBRARY 
;
;-

COMMON reduce_history, cmnver, prev_a, prev_hdr, zblocks0

;ver = 'V1'
cmnver = strmid(version,4,strlen(version))


; Establish control points x and y at every 32 pixel:

  w= indgen(33*33)
  y= w/33
  x= w-y*33
  x= x*32 & y= y*32

; Find corresponding control points x0 and y0 from x and y: 
  
  hdr= header 
;  IF (DATATYPE(hdr) NE 'STC')  THEN hdr=LASCO_FITSHDR2STRUCT(hdr)
;  sun_cent= get_sun_center(hdr,/nocheck)
;  xc= sun_cent.xcen
;  yc= sun_cent.ycen

  image = reduce_std_size(image0,hdr, /no_rebin, /nocal)
  ; make sure is FFV

  IF (DATATYPE(hdr) EQ 'STC')  THEN hdr= STRUCT2FITSHDR(hdr)
  occ_cent= occltr_cntr_jpb(hdr)
  xc= occ_cent(0)
  yc= occ_cent(1)
  hdr= LASCO_FITSHDR2STRUCT(hdr)

  sumx= (hdr.lebxsum)*(hdr.sumcol > 1)
  sumy= (hdr.lebysum)*(hdr.sumrow > 1)
  if ( sumx gt 0 ) then begin
   x = x/sumx
   xc = xc/sumx
  endif
  if ( sumy gt 0 ) then begin 
   y = y/sumy
   yc = yc/sumy
  endif

  scalef = GET_SEC_PIXEL(hdr)
  r= sqrt((sumx*(x-xc))^2+(sumy*(y-yc))^2)
  r0= c2_distortion(r,scalef) / (sumx * scalef) ; convert from arcsec to pixel
  theta= atan((y-yc),(x-xc))
  x0= r0*cos(theta)+xc
  y0= r0*sin(theta)+yc

; Distort the image by shifting locations (x,y) to (x0,y0) and return it:

;  return, warp_tri(x0,y0,x,y,image)	
  return, warp_tri(x,y,x0,y0,image)	; NBR, 8/24/00

end
