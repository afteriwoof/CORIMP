FUNCTION NMS, inimage, orient, radius, im, location

sz = size(inimage, /dim)
rows = sz[0]
cols = sz[1]
im=fltarr(rows, cols)

iradius = ceil(radius)

temp = indgen(181)
angle = temp*!pi/180.
xoff = radius*cos(angle)
yoff = radius*sin(angle)

hfrac = xoff - floor(xoff)
vfrac = yoff - floor(yoff)

orient = fix(orient)

for row=(iradius+1),(rows-iradius) do begin
	for col=(iradius+1),(cols-iradius) do begin

		or = orient[i,j]
		x = col + xoff[or]
		y = row - yoff[or]

		fx = floor(x)
		cx = ceil(x)
		fy = floor(y)
		cy = ceil(y)
		tl = inimage[fy,fx]
		tr = inimage[fy,cx]
		bl = inimage[cy,fx]
		br = inimage[cy,cx]

		upperavg = tl + hfrac[or]*(tr - tl)
		loweravg = bl + hfrac[or]*(br - bl)
		v1 = upperavg + vfrac[or]*(loweravg - upperavg)

		if inimage[row,col] gt v1 then begin
			x = col - xoff[or]
			y = row + yoff[or]
			fx = floor(x)
			cx = ceil(x)
			fy = floor(y)
			cy = ceil(y)
			tl = inimage[fy,fx]
			tr = inimageg[fy,cx]
			bl = inimage[cy,fx]
			br = inimage[cy,cx]
			upperavg = tl + hfrac[or]*(tr - tl)
			loweravg = bl + hfrac[or]*(br - bl)
			v2 = upperavg + vfrac[or]*(loweravg - upperavg)

			if inimage[row,col] gt v2 then begin
				im[row,col] = inimage[row,col]

			endif

		endif

	endfor

endfor









END
