pro canny_atrous,  image, decomposition = decomp, filter = filter, $
             n_scales = n_scales, check = check, mirror_padded=mirror_padded

;based on the atrous.pro (see documentation below)
;but with a DOG filter (carry out the gaussian smoothing and then
;take derivative. also allow for mirroring of data to reduce egde effects.

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
;
; MODIFICATION HISTORY:
;
;       Mon Oct 6 11:49:50 2003, Erik Rosolowsky <eros@cosmic>
;     Written.
;   	    Feb 2007 R.T.James McAteer, convert to Canny atrous 
;-


; Start with simple filter
;  filter = [0.25, 0.5, 0.25]


  if n_elements(filter) eq 0 then begin
    filter = 1./[16, 4, 8/3., 4, 16]
    grad=[-0.5,0.5]
  endif
  ;fmat = filter#transpose(filter)
  sz = size(image)
  if keyword_set(mirror_padded) THEN fac=3. ELSE fac=1.

  n_scales = floor(alog((sz[1] )/(n_elements(filter)*fac))/alog(2))

  if keyword_set(check) then return
  decomp = fltarr(sz[1], n_scales+1)

  im = image
  for k = 0, n_scales-1 do begin
; Smooth image with a convolution by a filter
	smooth = convolve(im, filter)
    coeffs = convolve(smooth,grad)
    decomp[*, n_scales-k] = coeffs
    im = smooth

; Generate new filter
    newfilter = fltarr(2*n_elements(filter)-1)
    newfilter[2*findgen(n_elements(filter))] = filter
; note filter is padded with zeros between the images
    ;fmat = newfilter#transpose(newfilter)
    filter = newfilter
  endfor

                                ; Stick last smoothed image into end of array
  decomp[*, 0] = smooth

  return
end
