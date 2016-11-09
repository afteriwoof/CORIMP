FUNCTION rm_sector, da, in, dr_px, thr1=thr1, thr2=thr2, fill=fill, mask
	
	;r_sun =  ( pb0r( in.DATE_D$OBS, /arc, /soho ) )[ 2 ]
    	r_sun =  ( pb0r( in.DATE_OBS, /arc, /soho ) )[ 2 ]

    	
	dx=in.cdelt1
	dy=in.cdelt2
	
	xcen=float(in.crpix1)
	ycen=float(in.crpix2)
	
	xsize=(size(da))[1]
	ysize=(size(da))[2]
	
	
	mask=(da*0.)+1
	
	;***
	; my sector bit
	for i=0,xsize-1 do begin
		for j=0,ysize-1 do begin
			polarx = (i-in.crpix1)*in.cdelt1
			polary = (j-in.crpix2)*in.cdelt2
			recpol, polarx, polary, r, a, /degrees
			if a lt thr1-5. then mask[i,j] = 0.
			if a gt thr2+5. then mask[i,j] = 0.
		endfor
	endfor
	;***
	

	IF KEYWORD_SET(thr1) then thr1=thr1 else thr1=1.5
	IF KEYWORD_SET(thr2) then thr2=thr2 else thr2=89.

	IF KEYWORD_SET(fill) then fill=fill ELSE fill = 0
	
	
    	da[where(mask eq 0)] = fill
	daout=da
	;da=da*mask
	
	dr_px=where(mask eq 0)
	RETURN, da
	
END
			


