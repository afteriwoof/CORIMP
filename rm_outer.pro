FUNCTION rm_outer, da, in, dr_px, thr=thr, plot=plot,fill=fill
	
	case in.instrume of
	'LASCO':	r_sun =  ( pb0r( in.DATE_OBS, /arcsec, /soho ) )[ 2 ]
    	'SECCHI':	r_sun = in.rsun
	'SWAP':		r_sun = in.rsun_arc
	'AIA_3':	r_sun = in.r_sun*ave([in.cdelt1,in.cdelt2])
	endcase
    	
	dx=in.cdelt1
	dy=in.cdelt2
	
	xcen=float(in.crpix1)
	ycen=float(in.crpix2)
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
	    plot_image,sigrange(da)
	    contour,mask,level=thr*r_sun,/over ;thr solar radii
    	ENDIF
	    
	IF KEYWORD_SET(thr) then thr=thr else thr=1.5

	IF KEYWORD_SET(fill) then fill=fill ELSE fill = 0
	
	
	mask[where(mask LT thr*r_sun)]=1
	mask[where(mask GE thr*r_sun)]=0
    	da(where(mask eq 0)) = fill
	daout=da
	;da=da*mask
	
	dr_px=where(mask eq 0)
	RETURN, da
	
END
			


