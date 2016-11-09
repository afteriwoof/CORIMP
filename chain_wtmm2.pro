
;fiddling wtih the craeting the chain
;incomplete

PRO chain_wtmm2, wtmm, md, al, chains, linked_wtmm
    
    
    
    
    ;make temporary wtmm
    ;reseed:
    wtmm_temp=wtmm
    
    links=wtmm_temp*0.
    linked_num=0.
    
    ;in order for the region growing to work, introduce a chain link
    ;this allow single pixels between two chains, originally defined as 'non wtmm' to be
    ;defined as 'wtmm' IF the angle is similar to the two connectors
    ;and the wt value is similar to the two connectors
    
    FOR i=1,1022 DO BEGIN
    	FOR j=1,1022 DO BEGIN
	    this_wtmm_value =wtmm[i,j]
	    ;IF this_wtmm_value NE 0 THEN GOTO, no_link
	    
	    seed_pix_value = wtmm[i,j]
	    
	    WHILE (MAX(seed_pix_value))NE 0 DO BEGIN
	    
	    	surrounding_wtmm=wtmm[i-2:i+2,j-2:j+2]
	    	
		possible_conectors = where( surrounding_wtmm NE 0, count)
	    	IF count LT 2 THEN GOTO, no_link	
	    	
		this_wt_value=md[i,j]
	    	surrounding_wtmm = (surrounding_wtmm[possible_conectors])/this_wt_value
	    	IF MIN(surrounding_wtmm) LT 0.9 THEN GOTO, no_link
	    	IF MAX(surrounding_wtmm) GT 1.1  THEN GOTO, no_link
    	    
	    	this_angle_value = al[i,j]
	    	surrounding_angles = al[i-1:i+1,j-1:j+1]
	    	surrounding_angles = surrounding_angles[possible_conectors]-this_angle_value
	    	IF MIN(surrounding_angles) LT -20. THEN GOTO, no_link
	    	IF MAX(surrounding_angles) GT 20. THEN GOTO, no_link
    	    	
		FOR i=0, count
		
		
		
		
		
		   
	    	wtmm_temp[i,j]=md[i,j]
	    
	    	links[i,j]=1
	    	linked_num=linked_num+1
	    	no_link:
	    	wtmm[seed_pix]=0
	    ENDWHILE
	
	
	ENDFOR
    ENDFOR
    
    linked_wtmm=wtmm_temp
    ;STOP
    
    wtmm_mask=wtmm*0
    i=1
    
    WHILE (MAX(wtmm_temp) GT 10 ) DO BEGIN
    
    ;sort_pix=reverse(sort(wtmm_temp))
    
    ;identify seed pixel
    seed_pix=where(wtmm_temp eq max(wtmm_temp))
    ;printxy,wtmm_temp,seed_pix,x,y
    
    ;identify new growth candidates
    ;growth_window = wtmm[x-1:x+1,y-1:y+1]/replicate(wtmm[x,y],[3,3])
    
    ;growth_pixels=where( growth_window GT 0.9 AND growth_window LT 1.1,count )
    
    ;IF count eq 0 THEN BEGIN
    ;	wtmm_temp[x,y]=0
	;GOTO, reseed
    ;ENDIF
    
    
    
    
    ;next_pixel=
    
    
    
    
    ;res=watershed(MAX(wtmm)-wtmm,conn=8) ;doesn;t work as it goes all the way into the valley
    	    	    	    	    	    ;instead of staying on the ridge
    
    ;Result = REGION_GROW(wtmm_temp, seed_pix,/all,thresh=[0.7*wtmm_temp[seed_pix],$
    	;1.3*wtmm_temp[seed_pix]])
    Result = REGION_GROW(wtmm_temp, seed_pix,/all,thresh=[0.1,$
    	wtmm_temp[seed_pix]])
    
    wtmm_mask[result]=i
    i=i+1
    wtmm_temp[result]=0
    ;STOp
    ;
    ENDWHILE
    
    chains=wtmm_mask
    
    ;connect close chains which have similar md and al
    
    ;lvls=[1]
    ;for i=1,MAX(ch) do if N_ELEMENTS(where(ch eq i)) GT 10 then lvls=[lvls,i]
    ;lvls=lvls[1:*]
    
    
    
    	


END
