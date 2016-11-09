
;+
;
;PRO calc_wtmm2
;
;Flags pixel which are the modulus maxima of the wavelet transform at input wavelet scale
;
;INPUT: md-the modulus of selected scale of the wavelet transform of the image
;   	al-the angle of maximum gradient of selected scale of the wavelet transform of the image
;
;OUTPUT wtmm-binary mask,   pixel value=1 corresponds to a modulus maxima pixel
;   	    	    	    pixel value=0 correpsonds to a non-modulus maxima pixel
;
;modulus maxima pixels are those which are locally maxima in the direciotn indicated by
;the input angle. For every pixel, the values of the 8 nearest neighbours are interpolated to 
;the input angle. If the value of md is greater than the interpolated value at both al and al+180
;the pixel is flagged as a modulus maxima pixel 
;
;USAGE: canny_atrous2d, image, md,al
;   	calc_wtmm2, reform(md[*,*,5]), reform(al[*,*,5]), wtmm
;-


PRO calc_wtmm2, md, al, wtmm


md_mask=md*0

al2=al

gt_180=where(al GT 180)
le_180=where(al LE 180)
al2[gt_180] = al2[gt_180]-180
al2[le_180] = al2[le_180]+180
angles=[0,45,90,135,180,225,270,315,360]
	

FOR i=1,1022 DO BEGIN
    FOR j=1,1022 DO BEGIN
	
	IF md[i,j] eq 0 THEN GOTO, zeroed
	
	mod_vals=[md[i+1,j],md[i+1,j+1],md[i,j+1],md[i-1,j+1],$
	    	md[i-1,j],md[i-1,j-1],md[i,j-1],md[i+1,j-1],md[i+1,j]]
	
	grad_value1 = INTERPOL( mod_vals , angles, al[i,j])
	grad_value2 = INTERPOL( mod_vals , angles, al2[i,j])
	;print,grad_value1,grad_value2,md[i,j]
	
	IF md[i,j] GT grad_value1 AND md[i,j] GT grad_value2 THEN md_mask[i,j] =1
	zeroed:
	
	ENDFOR
ENDFOR	

wtmm=md*md_mask

END
