; Code to look at a time-profile of all the detected points of CME structure.

; Created:	2011-09-21

;INPUTS:	fls-	the list of plots_*.sav

pro profile_all_detection_points, fls, front=front

plot, indgen(10), /nodata, xr=[0,n_elements(fls)-1],/xs,yr=[0,2e4],/ys

set_line_color

for i=0,n_elements(fls)-1 do begin

	restore,fls[i]
	heights = (sqrt((res[0,*]-in.xcen)^2.+(res[1,*]-in.ycen)^2.))*in.pix_size
	oplot,replicate(i,n_elements(heights)),heights,psym=3,color=1
	
	if keyword_set(front) then begin
		fronts = (sqrt((xf_out-in.xcen)^2.+(yf_out-in.ycen)^2.))*in.pix_size
		oplot,replicate(i,n_elements(heights)),fronts,psym=1,color=3
	endif

endfor






end
