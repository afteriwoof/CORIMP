pro testcoord, hdr, im
	
	dtor = !dpi/180.0d
	radeg = 1.0d/dtor
	
	readcol, 'vertices.txt', lon, lat, rad, f='D, D, D'
	
	;cd, 'B/COR1
	;fls = file_search('*FINAL.fts')
	;imgs = sccreadfits(fls[3:10], hdrs)
	;cd, '../..'
	
	; Comvert from stony hurst to heeq
	rad = rad * 6.95508e8
	lon = lon*dtor
	lat = lat*dtor
	
	x0 = rad * cos(lon) * cos(lat)
	y0 = rad * sin(lon) * cos(lat)
	z0 = rad * sin(lat)
	
	coords0=transpose([[x0], [y0], [z0]]) ; Should be in HEEQ here
	
	coords1 = coords0
	
	convert_stereo_coord, hdr.date_obs, coords1, 'HEEQ', 'HEE',/meters;, spacecraft='A', /meters

	openw,lun,/get_lun,'out.txt',error=err
	free_lun,lun
	openu,lun,'out.txt',/append
	printf,lun,coords1
	free_lun,lun
stop
	
	coords2 = [coords1[1,*], coords1[2,*], coords1[0,*]]
	
	d0 = hdr.dsun_obs
	
	d = sqrt( coords2[0,*]^2 + coords2[1,*]^2 + ( d0 - coords2[2,*] )^2 )
	tx = atan( coords2[0,*] / ( d0 - coords2[2,*] ) )
	ty = asin( coords2[1,*] / d)
	
	coords3 = [tx, ty]*radeg*3600.0
help,coords3
	
	wcs = fitshead2wcs(hdr)
	;wcs = replicate(wcs, 8)
	;for i =0, 7 do wcs[i] = fitshead2wcs( hdrs[ i ] )
	coords4 = dblarr(2, 268)
	for i=0, 267 do coords4[*,i] = wcs_get_pixel(wcs, coords3[*,i])
	
;	for i =0, 7 do begin
;		plot_image, imgs[512:*,512:*,i]
;		set_line_color
;		plots, obx2[i+3]-512, oby2[i+3]-512, psym=1, symsize=3, color=5
;		plots, coords4[0,i]-512, coords4[1,i]-512, psym=6, symsize=3, color=7
;		loadct, 0
;		pause
;	endfor
	
	stop
	
end