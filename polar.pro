function polar,image,xcen,ycen
	sz = size(image)
	xmax = max([abs(sz[1]-xcen-1.),xcen])
	ymax = max([abs(sz[2]-ycen-1.),ycen])
	rmax = sqrt(xmax^2. + ymax^2.)
	nr = round(rmax)+1.
	r = findgen(nr) # replicate(1.,360.)
	theta = replicate(!dtor,nr) # findgen(360)
	i = fix(r*cos(theta) + xcen)
	j = fix(r*sin(theta) + ycen)
	w = where((i lt 0) or (i ge sz[1]) or (j lt 0) or (j ge sz[2]))
	if sz[0] eq 3 then nz=sz[3] else nz=1
	result = fltarr(nr,360,nz)

	for k=0,nz-1 do begin
		temp = image(*,*,k)
		temp = temp(i,j)
		temp[w] = -100
		result(0,0,k) = temp
	endfor
	
	return, result
end
			 
