
;+
;
;FUNCTION binary_mask
;
;INPUT: image_in: a 2d image
;   	
;KEYWORD INPUT: val=val -creates a mask where 
;   	    	    	only pixel of intentity 'val' are slected   
;   	    	if not switched, defaults to all non-negative values
;OUTPUT:    binary_out -    the binary image of selected pixels
;
;USAGE:     bin_image=binary_mask(image)    	;all non-negative pixels
;   	    bin_image=binary_mask(image,val=10) ;all pixels with intensity '10'
;   	    bin_image=binary_mask(image,val=image[200,200]) ; all pixels with the same intensity as pixel[200,200]
;-



FUNCTION binary_mask, image_in,val=val

	binary_out=image_in*0
	
	IF KEYWORD_SET(val) THEN $
		binary_out[where(image_in EQ val)] =1 $
	ELSE $
		binary_out[where(image_in GT 0)] =1 
    	
	RETURN,binary_out
END
