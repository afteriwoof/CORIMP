function c3_warp_jpb,image0,header
;+
; NAME:
;       C3_WARP 
;
; PURPOSE:
;       This function distorts a C3 image and returns it. 
;
; CALLING SEQUENCE:
;       Result = C3_WARP(Image,Header) 
;
; INPUTS:
;       Image :   C3 image to be distorted
;       Header:   C3 image header 
;
;
; OUTPUTS:
;       The distorted image is returned. Control points at every 32 pixels
;       are used for distortion.
;
; COMMON BLOCKS:
;       reduce_history
;
; SIDE EFFECTS:
;	changes cmnver (procedure and version info) in reduce_history common block
;
; MODIFICATION HISTORY:
;               Written  Ed Esfandiari, NRL
;   Version 1   aee 28 Oct 1997    Initial release
;               aee 24 Nov 1998    changed get_sun_center call to occltr_cntr.
;               dw  10 Dec 1998    Corrected handling of summed images
;		NBR 24 Aug 2000	   Switch x/y and x0/y0 around in call to WARP_TRI;
;				   Add reduce_history COMMON block
;		NBR,  6 Nov 2001 - Simplify header handling
;		NBR, 14 Mar 2003 - Add subfield functionality
;   	    	NBR, 16 Nov 2012 - No change to code
;
; KNOWN BUGS:
;        '11/16/12 @(#)c3_warp.pro	1.9'
version= '11/16/12 @(#)c3_warp.pro	1.9' ; NRL LASCO IDL LIBRARY 
;
;-

COMMON reduce_history, cmnver, prev_a, prev_hdr, zblocks0

;ver = 'V1'
cmnver = strmid(version,4,strlen(version))

gridsize=32l
; Establish control points x and y at every 32 pixel:

  w= indgen(((1024/gridsize)+1)^2)
  y= w/((1024/gridsize)+1)
  x= w-y*((1024/gridsize)+1)
  x= x*gridsize & y= y*gridsize

; Find corresponding control points x0 and y0 from x and y: 
  
  hdr= header 
  IF (DATATYPE(hdr) NE 'STC')  THEN hdr=LASCO_FITSHDR2STRUCT(hdr)
  image = reduce_std_size(image0,hdr, /no_rebin, /savehdr)

;  sun_cent= get_sun_center(hdr,/nocheck)
;  xc= sun_cent.xcen
;  yc= sun_cent.ycen

  occ_cent= occltr_cntr_jpb(hdr)
  ; is for 1024x1024 FFV
  xc= occ_cent(0)
  yc= occ_cent(1)
  x1 = hdr.r1col-20
  x2 = hdr.r2col-20
  y1 = hdr.r1row-1
  y2 = hdr.r2row-1
  sumx= (hdr.lebxsum)*(hdr.sumcol > 1)
  sumy= (hdr.lebysum)*(hdr.sumrow > 1)
  if ( sumx gt 1 ) then begin
   x = x/sumx
   xc = xc/sumx
   x1 = x1/sumx
   x2 = x2/sumx
  endif
  if ( sumy gt 1 ) then begin 
   y = y/sumy
   yc = yc/sumy
   y1 = y1/sumx
   y2 = y2/sumx
  endif

  scalef = GET_SEC_PIXEL(hdr)
;print,scalef,xc,yc,sumx,sumy
;print,x(0:10)
;print,y(0:10)
  r= sqrt((sumx*(x-xc))^2+(sumy*(y-yc))^2)
;print,r(0:10)

  r0= c3_distortion(r,scalef) / (sumx * scalef) ; convert from arcsec to pixel
;print,r0(0:10)
  theta= atan((y-yc),(x-xc))
  x0= r0*cos(theta)+xc
  y0= r0*sin(theta)+yc

; Distort the image by shifting locations (x,y) to (x0,y0) and return it:

;print,x0(0:10)
;print,y0(0:10)
;  return, warp_tri(x0,y0,x,y,image)
	
  image = warp_tri(x,y,x0,y0,temporary(image))	; NBR, 8/24/00
  
  return, image[x1:x2,y1:y2]

end
