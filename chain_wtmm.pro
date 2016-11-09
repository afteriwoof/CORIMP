

;+
;
;PRO chain_wtmm
;
;Groups wavelet transform modulus maxima (wtmm) pixels into individual chains
;
;INPUT: wtmm	    -binary mask identifying wtmm pixels, output from calc_wtmm2
;   	md  	    -the modulus of selected scale of the wavelet transform of the image
;   	al  	    -the angle of maximum gradient of selected scale of the wavelet transform of the image
;
;OUTPUT chains	    -image where each all pixels along a chain have the same value
;   	linked-wtmm -image of linked wtmm pixels	
;
;uses region growing on the binary image wtmm to grow the chains. Initially links non-wtmm pixels 
;where both teh md and al are similar. Passes this linked binary image into the region growing routine
;
;known faults:  (1)dependent on the chosen threshold value for the region growing
;   	    	(2)can also introduce need for line connecting two pixels to be perpendicular to angle
;   	    	at both.
;   	    	(3) can be improved by running 'binary_mask' to extract disprate edges and the connecting
;
;USAGE: canny_atrous2d, image, md,al
;   	calc_wtmm2, reform(md[*,*,5]), reform(al[*,*,5]), wtmm5
;   	chain_wtmm, wtmm, reform(md[*,*,5]), reform(al[*,*,5]), chains5, linked_wtmm5
;EXTENSIONS:	edge1 = binary_mask(chains,val=chains5[274,563])
;   	    	edge2 = binary_mask(chains,val=chains5[189,546])
;   	    	edge=edge1+edge2
;   	    	;so now 'edge' is a binary mark of the edges starting at  [274,563] and [189,546]
;
;-











PRO chain_wtmm, wtmm, md, al, chains, linked_wtmm
    
    
    ;make temporary wtmm
    wtmm_temp=wtmm
    
    ;for debugging purposes, identify linked pixels and quantity
    links=wtmm_temp*0.
    linked_num=0.
    
    ;in order for the region growing to work, introduce a chain link
    ;this allow single ' non-wtmm' pixels between two chains, to be
    ;redefined as 'wtmm' IF the angle is similar to the two connectors
    ;and the wt value is similar to the two connectors
    
    FOR i=1,1022 DO BEGIN
    	FOR j=1,1022 DO BEGIN
	    this_wtmm_value =wtmm[i,j]
	    IF this_wtmm_value NE 0 THEN GOTO, no_link
	    surrounding_wtmm=wtmm[i-1:i+1,j-1:j+1]
	    possible_conectors = where( surrounding_wtmm NE 0, count)
	    IF count LT 2 THEN GOTO, no_link	
	    this_wt_value=md[i,j]
	    surrounding_wtmm = (surrounding_wtmm[possible_conectors])/this_wt_value
	    IF MIN(surrounding_wtmm) LT 0.9 THEN GOTO, no_link
	    IF MAX(surrounding_wtmm) GT 1.1  THEN GOTO, no_link
    	    
	    this_angle_value = al[i,j]
	    surrounding_angles = al[i-1:i+1,j-1:j+1]
	    surrounding_angles = surrounding_angles[possible_conectors]-this_angle_value
	    IF MIN(surrounding_angles) LT -15. THEN GOTO, no_link
	    IF MAX(surrounding_angles) GT 15. THEN GOTO, no_link
    	    	   
	    wtmm_temp[i,j]=md[i,j]
	    
	    links[i,j]=1
	    linked_num=linked_num+1
	    no_link:
	ENDFOR
    ENDFOR
    
    ;save the linked chains for an output
    linked_wtmm=wtmm_temp
    
    ;create the binary image for the region growing
    wtmm_temp_binary=wtmm_temp*0
    wtmm_temp_binary[where(wtmm_temp NE 0)]=1
    
    ;display the images
    ;window,4,xsize=800,ysize=800
    ;!p.multi=[2,2]
    ;tv,wtmm
    ans=''
    ;read, '->', ans
    ;tv,wtmm_temp
    ;read, '-->', ans
    ;tv,wtmm_temp_binary
    ;read, '--->', ans
    
    ;create the empty 'chains' array
    chains=wtmm*0
    
    ;set counter for number of chains
    i=1
    
    ;arbitray hard threshold of 1/4 of maximum vale - soft thresholding along each chain will be much better
    wtmm_thr=MAX(wtmm_temp)/4. 
    
    
    ;carry out the region growing
    WHILE (MAX(wtmm_temp) GT wtmm_thr ) DO BEGIN
    
    	seed_pix=where(wtmm_temp eq max(wtmm_temp))
    
    	;region grow the binary image
	Result = REGION_GROW(wtmm_temp_binary, seed_pix,/all,thresh=[0.9,1.1])
    
    	chains[result]=i
    	i=i+1
    	wtmm_temp[result]=0
    
    ENDWHILE
        
    ;display the 'chains' image
    tv,chains
    !p.multi=[1,1]
        	
END
