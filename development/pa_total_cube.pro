; Create a data cube of the detections through image sequence

; Created	2011-09-21

; INPUTS:	fls-	the list of plots_*.sav

pro pa_total_cube, fls, cube

; cube of pos_angle v time v height
;height compressed from [0,2e4] to [0,200]

cube = intarr(360,n_elements(fls),200)

for i=0,n_elements(fls)-1 do begin
	restore, fls[i]
	heights = (sqrt((res[0,*]-in.xcen)^2.+(res[1,*]-in.ycen)^2.))*in.pix_size
	heights /= 100.
	fronts = (sqrt((xf_out-in.xcen)^2.+(yf_out-in.ycen)^2.))*in.pix_size
	fronts /= 100.
	recpol, xf_out-in.xcen, yf_out-in.ycen, rf_out, af_out, /degrees
	recpol, res[0,*]-in.xcen, res[1,*]-in.ycen, res_r, res_theta, /degrees
	res_theta = (res_theta+90) mod 360
	af_out = (af_out+90) mod 360
	cube[res_theta, i, heights] += 1
	cube[af_out, i, fronts] += 1
endfor




end
