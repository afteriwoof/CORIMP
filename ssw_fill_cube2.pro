pro ssw_fill_cube2, cube, ocube, orig_miss=orig_miss, final_miss=final_miss, $
    times=times, missing=missing, track_progress=track_progress, $
    window=window
;+
;   Name: ssw_fill_cube
;
;   Purpose: fill missing data with data from neighbors
;  
;   Input Parameters:
;      cube  - data cube (output if only one parameter passed)
;
;   Output Parameters:
;      ocube - optional - output (filled cube) - default replaces input
; 
;   Keyword Parameters:
;      missing - if set, pixel value considered 'missing' (default=0)
;      times   - vector of image times (not yet implemented)
;      track_progress - switch, if set, print correction status info 
;      window - limit window of neighbors to check (+/- limit)
;               (for large cubes, dont wander further than required 
;
;   Output Parameters:
;      orig_miss  - percent missing data in original cube [fltarr(nimages)]
;      final_miss - percent missing data in final cube 
;
;   Calling Sequence:
;      ssw_fill_cube,cube		; overwrite input with filled version
;      ssw_fill_cube,cube,ocube         ; filled version in ocube (orig saved)
;
;   Calling Examples:
;      ssw_fill_cube,cube, orig=orig, final=final
;      ssw_fill_cube,cube, mising='aa'x  ; AA(hex) is "missing" (ex: fill data)
;      ssw_fill_cube,cube, window=2      ; check neghbors within +2/-2 
;
;   Restrictions:
;      Assumes images are kindof like their neighbors 
;      (normalization, wavelenth, structure, registration, time, whatever)
;
;   History:
;      24-apr-2001 S.L.Freeland - ssw_fill_cube from eit_fill_cube
;
;   Previous History:
;
;      17-feb-1996 S.L.Freeland - wrote eit_fill_cube
;      18-Feb-1996 S.L.Freeland - add WINDOW keyword and function
;
;   
;   Side Effects:
;      Input array is filled ('clobbered') if only one parameter (for space)
;-

debug=keyword_set(track_progress)	; subtle difference,,,

if data_chk(cube,/ndim) ne 3 then begin
   message,/info,"Sorry, only works on a cube..."
   return
endif

if not keyword_set(missing) then missing=0		; default miss value
sdata=size(cube)
nimage=sdata(3)

orig_miss=fltarr(nimage)		; original quality (output keyword)
final_miss=fltarr(nimage)		; final quality    (output keyword)
npix=float(sdata(1)*sdata(2))

newcube=n_params() eq 2			; need an output copy?
if newcube then ocube=cube
exestr=(['cube(0,0,i)=image','ocube(0,0,i)=image'])(newcube)

if keyword_set(window) then nabors=window+1 else nabors=nimage-1  ;# neighbors
order=lonarr(nabors,nimage)		; "next image" pointers

; Form Nearest Neighbor pointer array
xorder=reform(transpose([lindgen(nabors)+1]#[1,-1]),(nabors)*2)

if n_elements(time) ne nimage then begin
   for i=0,nimage-1 do begin		
     next=xorder+i
     order(0,i)=(reform(next(where(next ge 0 and next le nimage-1))))(0:nabors-1)
   endfor
endif else begin
   message,/info,"not yet implemented....       ; use Time vector for order
endelse

for i=0, nimage-1 do begin		        ; for each image
   image=cube(*,*,i)				; extract
   miss=where(image eq missing,mcnt)	        ; flag missing data
   orig_miss(i)=float(mcnt)/npix*100.	        ; remember original missing %
   nn=-1				        ; neighbor pointer pointer
   if debug then print,'Image: ' + strtrim(i,2) + ' Original Percent Missing: ' + string(orig_miss(i),format='(F6.2)')

   while (mcnt gt 0) and nn lt nabors-1 do begin
      nn=nn+1
      next=order(nn,i)                          ; next neighbor to check
      nxtimage=cube(*,*,next)		        ; grab next neighbor
      image(miss)=nxtimage(miss) & image(miss-1)=nxtimage(miss-1) & image(miss+1)=nxtimage(miss+1)		; copy neighbor->current
      image(miss-sdata(1)-1)=nxtimage(miss-sdata(1)-1) & image(miss+sdata(1)+1)=nxtimage(miss+sdata(1)+1)
      miss=where(image eq missing,mcnt)         ; re-check composite
      if debug then print,'Image: ' + strtrim(i,2) + ' Neigbor' + strtrim(next,2) + ' Percent Missing: ' + string(float(mcnt)/npix*100.,format='(F6.2)')
   endwhile

   final_miss(i)=float(mcnt)/npix*100.
   insert=execute(exestr)			; composite -> output array
endfor

return
end
