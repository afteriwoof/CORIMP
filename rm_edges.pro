FUNCTION rm_edges, da, in, dr_px, edge=edge, plot=plot,fill=fill
	
	;r_sun =  ( pb0r( in.DATE_D$OBS, /arc, /soho ) )[ 2 ]
    	r_sun =  ( pb0r( in.DATE_OBS, /arc, /soho ) )[ 2 ]

    	
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
  
	mask[0:edge, *] = 0.
	mask[(xsize-edge):(xsize-1), *] = 0.
	mask[*, 0:edge] = 0.
	mask[*, (ysize-edge):(ysize-1)] = 0.
       	
	;STOP
	IF KEYWORD_SET(plot) THEN BEGIN
	    plot_image,sigrange(da)
	    contour,mask,level=edge*r_sun,/over ;edge solar radii
    	ENDIF
    
	IF KEYWORD_SET(edge) then edge=edge else edge=1.5

	IF KEYWORD_SET(fill) then fill=fill ELSE fill = 0
	
	
	;mask[where(mask LT edge*r_sun)]=1
	;mask[where(mask GE edge*r_sun)]=0
    	da(where(mask eq 0)) = fill
	daout=da
	;da=da*mask
	
	dr_px=where(mask eq 0)
	RETURN, da
	
END
			


