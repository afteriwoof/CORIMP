function ellipsefit, x, y, ellipse

; Fitting ellipse as determined in contour8.bat

	sz_x = size(x, /dim)
	sz_y = size(y, /dim)
	dim = 0
	if sz_x[0] eq 1 then dim=1
	
	; simply making my points into two arrays of 100 points.
	tempx = fltarr(100)
		tempy = fltarr(100)
		steps = sz_x[dim] / 100.
		for t=0,99 do begin
		        tempx[t] = x[t*steps]
		        tempy[t] = y[t*steps]
		endfor
		x = tempx
		y = tempy
		sz_x = size(tempx, /dim)
		sz_y = size(tempy, /dim)

		sumx = 0.
		sumy = 0.
		sumxx = 0.
		sumyy = 0.
		sumxy = 0.
		t=0.
		npts = sz_x[0]

		; make my summations over the points
		while(t lt npts) do begin
		        sumx = sumx + x(t) 
		        sumy = sumy + y(t) 
		        sumxx = sumxx + x(t)*x(t) 
		        sumyy = sumyy + y(t)*y(t) 
		        sumxy = sumxy + x(t)*y(t) 
		        t=t+1 
		endwhile
	
		x_bar = sumx / npts
		y_bar = sumy / npts

		varx = sumxx / npts
		vary = sumyy / npts
		covarxy = sumxy / npts

		t=0.
		z=fltarr(npts,2)
		temp1=fltarr(2)
		temp2=fltarr(2,2)
		total = fltarr(2,2)

		while(t lt npts) do begin 

		        ; Take the vector (x-xbar, y-ybar)
		        z[t,0] = ( x[t] - x_bar ) 
		        z[t,1] = ( y[t] - y_bar ) 

		        ; Multiply each by its transpose
		        temp1[0] = z[t,0] 
		        temp1[1] = z[t,1] 

		        temp2 = transpose(temp1)##temp1 

		        total = total + temp2 

		        t=t+1 

		endwhile

		dx = z[*,0]
		dy = z[*,1]
		sumdxdx=0.
		sumdydy=0.
		sumdxdy=0.
		t = 0.
		while(t lt npts) do begin 
		        sumdxdx = sumdxdx + dx[t]*dx[t] 
		        sumdydy = sumdydy + dy[t]*dy[t] 
		        sumdxdy = sumdxdy + dx[t]*dy[t] 
		        t=t+1 
		endwhile
				
		;u = c*dx - s*dy
		;v = s*dx + c*dy
		;sumuu = 0.
		;sumvv = 0.
		;t = 0.
		;while(t lt npts) do begin
		;        sumuu = sumuu + u[t]*u[t] 
		;        sumvv = sumvv + v[t]*v[t] 
		;        t=t+1 
		;endwhile

		;varu = sumuu / npts
		;varv = sumvv / npts

		tensor = [[sumdxdx, sumdxdy], [sumdxdy, sumdydy]]
		evals = eigenql(tensor, eigenvectors=evecs)
		semimajor = sqrt(evals[0])/6.
		semiminor = sqrt(evals[1])/6.
		major = semimajor*2.
		minor = semiminor*2.
		semiaxes = [semimajor, semiminor]
		axes = [major, minor]
		evec = evecs[*,1]
		orient = atan(evec[1],evec[0])*180./!pi-90.
		npoints = 120.
		phi = 2*!pi*(findgen(npoints)/(npoints-1))
		ang = orient/!radeg
		cosang=cos(ang)
		sinang=sin(ang)
		a=semimajor*cos(phi)
		b=semiminor*sin(phi)
		aprime=x_bar+(a*cosang)-(b*sinang)
		bprime=y_bar+(a*sinang)+(b*cosang)
	
		ellipse = [aprime, bprime]
		ellipse = [[ellipse], x_bar, y_bar]

; End of ellipse fitting
	
	
return, ellipse
	

end
