; My Notes on James' code from canny_atrous2d and canny_atrous.pro

; n_scales = 7
; Takes the rows and columns of the image seperately.
; Calls canny_atrous to perform a convolution across the rows 
; (then the columns) which involves a convolution of the B3-spline
; used in atrous for smoothing, and a gradient operator to pull out
; the edges, the result being the coeffs which are placed in array 
; decomp.
; Each time the filter is passed it is padded with zeros (idea behind
; atrous) so that the higher decomp corresponds to the higher scales 
; of detail.
; This decomp is performed for each row (and column) and the res variable
; is obtained (correcting for edge effects by mirror padding; this is
; what the reverse(reform) shenanigans is all about!.
; The modgrad is obtained from the sqrt(rows^2+columns^2) for each scale.
; The alpgrad is simply the arctan of the rows and columns for each scale.
; There is a condition that any zeroes are changed to a tolerance value.


;based on atrous.pro inside canny_atrous.pro

;calculates the 1D DOG in horizontal and vertical
;allow for mirroring of data
;the combines these to get the modulus and angle.
;see mallat and zhong 1992
;murtagh and starck papers
;also young and gallagher, ApJ, 2008 CME paper.

PRO canny_atrous2d, im, modgrad, alpgrad, rows=rows, columns=columns


    im=float(im)
    sz_x=(size(im))[1]
    sz_y=(size(im))[2]

    n_scales = floor(alog((sz_x )/5.)/alog(2))

    rows=fltarr(sz_x,sz_y,n_scales+1)
    columns=fltarr(sz_x,sz_y,n_scales+1)

    ;calculate the rows WT
    for i=0,sz_y -1 do begin & $
       ;canny_atrous,reform(im[*,i]),decomp=res & $
       canny_atrous,[reverse(reform(im[*,i])),reform(im[*,i]),$
        reverse(reform(im[*,i]))],$
            decomp=res, /mirror_padded & $

       rows[*,i,*]=res[sz_x:(2*sz_x)-1,*] & $
    endfor


   ;calculate the columns WT
    for i=0,sz_x -1 do begin & $
       ;canny_atrous,reform(im[i,*]),decomp=res & $
       canny_atrous,[reverse(reform(im[i,*])),reform(im[i,*]),$
        reverse(reform(im[i,*]))],$
            decomp=res ,/mirror_padded & $
       columns[i,*,*]=res[sz_y:(2*sz_y)-1,*] & $
    endfor

    ;create the modulus and argument
    modgrad=rows*0.
    alpgrad=rows*0.
    for i=0,n_scales do begin & $
        modgrad[*,*,i] = sqrt(rows[*,*,i]^2.+columns[*,*,i]^2.) & $

       zeros=where(rows[*,*,i] eq 0, zero_count) & $
       if zero_count ne 0 then begin & $
         temp = rows[*,*,i] & $
            temp[zeros] = 3e-8 & $
            arctan,temp,columns[*,*,i],a,adeg
            alpgrad[*,*,i] = adeg  & $
       endif else begin
         arctan,rows[*,*,i],columns[*,*,i],a,adeg
       alpgrad[*,*,i] = adeg  &$
       endelse
    endfor

    


END
