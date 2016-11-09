; Created 25-01-11 from rm_inner.pro to change the header info keywords after reading data with mreadfits_corimp.pro

FUNCTION rm_inner_corimp, da, in, dr_px, thr=thr, plot=plot,fill=fill
	
    	;r_sun = in.rsun
	r_sun = ( pb0r( in.date_obs, /arcsec, /soho ) )[2]    	

	dx=in.cdelt1
	dy=in.cdelt2
	
	xcen=float(in.xcen)
	ycen=float(in.ycen)
	;xcen=546.140-31
	;ycen=534.760-25
	
	;xcen=511.
	;ycen=511.
	
	
	;xcen=511-(in.xcen/dx)
	;ycen=511-(in.ycen/dy)
    	
	;STOP
	xsize=(size(da))[1]
	ysize=(size(da))[2]
	
	
	mask=(da*0.)+1
	for i=0,xsize-1 do begin & $
    		for j=0,ysize-1 do begin & $
    			xoff=ABS(i-xcen)*dx & $
			yoff=ABS(j-ycen)*dy & $
			mask[i,j] = sqrt( xoff^2. + yoff^2. ) & $
    		endfor & $
	endfor
    
	;STOP
	IF KEYWORD_SET(plot) THEN BEGIN
	    plot_image,sigrange(da,/use_all)
	    contour,mask,level=thr*r_sun,/over ;thr solar radii
    	ENDIF

	IF KEYWORD_SET(thr) then thr=thr else thr=1.5

	IF KEYWORD_SET(fill) then fill=fill ELSE fill = 0
	
	
	mask[where(mask LT thr*r_sun)]=0
	mask[where(mask GE thr*r_sun)]=1
    	da(where(mask eq 0)) = fill
	daout=da
	;da=da*mask
	
	dr_px=where(mask eq 0)
	RETURN, da
	
END
			


