
pro atrous,  image, decomposition = decomp, filter = filter, $
	             n_scales = n_scales, check = check, mirror=mirror
	     ;+
	     ; NAME:
	     ;   ATROUS
	     ; PURPOSE:
	     ;   Perform a 2-D "a trous" wavelet decomposition on an image.
	     ;
	     ; CALLING SEQUENCE:
	     ;   ATROUS, image [, decomposition = decomposition, $
		     ;                 filter = filter, n_scales = n_scales, /check]
	     ;
	     ; INPUTS:
	     ;   IMAGE -- A 2-D Image to Filter
	     ;
	     ; KEYWORD PARAMETERS:
	     ;   FILTER -- A 1D (!!) array representing the filter to be used.
	     ;             Defaults to a B_3 spline filter (see Stark & Murtaugh
	     ;             "Astronomical Image and Data Analysis", Spinger-Verlag,
	     ;             2002, Appendix A)
	     ;   N_SCALES -- Set to name of variable to receive the number of
	     ;               scales performed by the decomposition.
	     ;   CHECK -- Check number of scales to be performed and return.
	     ;   MIRROR -- This is a workaround for the lack of edge mirroring in 
	     ;				IDL's CONVOL routine.  Depends on pad_image and 
	     ;				depad_image to expand and unexpand the images.
	     ; OUTPUTS: 
	     ;   DECOMPOSITION -- A 3-D array with scale running along the 3rd axis
	     ;                    (large scales -> small scales). The first plane
	     ;                    of the array is the smoothed image. To recover
	     ;                    the image at any scale, just total the array
	     ;                    along the 3rd dimension up to the scale desired.
	     ;                  
	     ;
	     ; RESTRICTIONS:
	     ;   Uses FFT convolutions which edge-wrap instead of mirroring the
	     ;   edges as suggested by Stark & Mutaugh.  Wait for it.
	     ;	-Russ: Maybe not anymore.  Mirroring is super slow though due to an
	     ;			order of magnitude increase in the size of the image being convolved.
	     ;
	     ; MODIFICATION HISTORY:
	     ;
	     ;       Mon Oct 6 11:49:50 2003, Erik Rosolowsky <eros@cosmic>
	     ;		Written.
	     ;		09-jun-2005, Russ Hewett (rhewett@vt.edu)
	     ;			-Added Mirror keyword
	     ;
	     ;-
	     
	     
	     ; Start with simple filter
	     ;  filter = [0.25, 0.5, 0.25]
	     
	     
if n_elements(filter) eq 0 then filter = 1./[16, 4, 8/3., 4, 16]
fmat = filter#transpose(filter)
if keyword_set(mirror) then im=pad_image(image) else im=image
sz = size(im)
	     
;  n_scales = floor(alog((sz[1] < sz[2])/n_elements(filter))/alog(2))
	     
div_factor = 1
if keyword_set(mirror) then div_factor=3
   
n_scales = floor(alog((sz[1] < sz[2])/div_factor)/alog(2)) - floor(alog(n_elements(filter))/alog(2)) + 1 
		     
if keyword_set(check) then return
decomp = fltarr(sz[1]/div_factor, sz[2]/div_factor, n_scales+1)
	        
;im = image
for k = 0, n_scales-1 do begin
			     
	; Smooth image with a convolution by a filter    
	smooth = convolve(im, fmat)
	if keyword_set(mirror) then begin
		decomp[*, *, n_scales-k] = depad_image(im) - depad_image(smooth)
	endif else begin
		decomp[*, *, n_scales-k] = im - smooth
	endelse
															    
	im = smooth
														    
        ; Generate new filter
	newfilter = fltarr(2*n_elements(filter)-1) 
        newfilter[2*findgen(n_elements(filter))] = filter
										    
	; note filter is padded with zeros between the images
        fmat = newfilter#transpose(newfilter)
	filter = newfilter
									      
endfor
																		      
; Stick last smoothed image into end of array
if keyword_set(mirror) then begin
	decomp[*, *, 0] = depad_image(smooth)
endif else begin
	decomp[*, *, 0] = smooth
endelse
																															  
																										
return

end
																															  
																			
