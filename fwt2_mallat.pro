function fwt2_mallat, x, n, varargout
; Perform 2d separate wavelet transform using the algorithm from
; "Characterization of Signals from Multiscale Edges", Mallat et al., 1992.
; Rewritten by Jason Byrne from Alex Young.

if n gt 9 then begin
	print, 'Error: This code can decompose the signal up to the 9th level of decomposition. You have to change the code if you want to use a deeper level.'
endif

; Preserve inital size.
s = size(x, /dim)

; Filters as in the paper.
lo = [0, 0, 1, 3, 3, 1, 0]*(sqrt(2)/4.)
hi = [0, 0, 0, -2, 2, 0, 0]*(sqrt(2)/4.)
d = [0, 0, 0, 1, 0, 0, 0]

; Set DWT_mode to 'per'.
; old_modeDWT = dwtmode('status', 'nodisp')
; modeDWT = 'per'
; dwtmode(modeDWT, 'nodisp')

; Compute stationary wavelet coefficients.
evenoddVal = 0
a = fltarr(s[0],s[1],n)
h = fltarr(s[0],s[1],n)
v = fltarr(s[0],s[1],n)

l_shift=[0, 4, 11, 25, 53, 53+32, 53+32+40, 53+32+40+48, 53+32+40+48+56]

for k=0,n-1 do begin

	lf = size(lo, /dim)
	l_keep = (3*lf+1)/2

	if k gt 1 then l_keep = l_keep + 2^(k-2)

	x = 






end
