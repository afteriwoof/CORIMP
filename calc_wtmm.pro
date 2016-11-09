PRO calc_wtmm, md, al, wtmm

;create the masks referring to each direction

;dir_masks=[ [[1,1,0],[0,1,1],[0,1,1]],$
;    	    [[0,1,1],[1,1,0],[1,1,0]],$
;    	    [[1,1,0],[1,1,0],[0,1,1]],$
;    	    [[0,1,1],[0,1,1],[1,1,0]]  ]

; James' original mask
;dir_masks=[ [[0,0,0],[0,1,1],[0,1,1]],$
;    	    [[0,0,0],[1,1,0],[1,1,0]],$
;    	    [[1,1,0],[1,1,0],[0,0,0]],$
;    	    [[0,1,1],[0,1,1],[0,0,0]]  ]

; Jason's mask
dir_masks=[ [[0,1,1],[0,1,1],[0,0,0]], $
	    [[1,1,0],[1,1,0],[0,0,0]], $
	    [[0,0,0],[1,1,0],[1,1,0]], $
	    [[0,0,0],[0,1,1],[0,1,1]] ]
    	    	
dir_mask_index=al*0

;idenfifuy each angle with a specific mask
dir_mask_index[where(al GE 0 AND al LT 90)]=0
dir_mask_index[where(al GE 90 AND al LT 180)]=1
dir_mask_index[where(al GE 180 AND al LT 270)]=2
dir_mask_index[where(al GE 270 AND al LT 360)]=3

IF (where(al EQ 360))[0] NE -1. THEN $
    dir_mask_index[where(al EQ 360)]=3

md_mask=md*0

FOR i=1,1022 DO BEGIN
    FOR j=1,1022 DO BEGIN
	
	IF md[i,j] eq 0 THEN GOTO, zeroed
	;identify which mask applies to this pixel
	this_mask =  dir_masks [*,*, dir_mask_index[i,j]]
	;multiply md by the mask
    	this_mask = md[i-1:i+1,j-1:j+1]*this_mask
	;find if the centre pixel is the biggest value
	;IF this_mask[1,1] GE  MAX( this_mask ) then md_mask[i,j] =1 
    	;STOP
	sorted=reverse(sort(this_mask))
    	IF where(sorted eq 5) EQ 1 then md_mask[i,j] =1
	zeroed:
	
    ENDFOR
ENDFOR	

wtmm=md*md_mask


END
