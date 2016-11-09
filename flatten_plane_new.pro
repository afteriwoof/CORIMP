; new version of flatten_plane.pro

pro flatten_plane_new,file,x,y,z,p1,p2,p3,p4,a,b,c,s,t,angle1,angle2,angle3,angle4,p1_init,pauses=pauses,noplot=noplot

xmin=-10
xmax=20
ymin=-15
ymax=15
zmin=-10
zmax=10

angle_x=50
angle_z=50

; these should be from scc_measure and are in Stonyhurst Heliographic coords
; phi = longitude, theta = latitude, r = distance from Sun centre
readcol, file, phi, theta, r, f='D,D,D'

; Write out a file with all the transformation for reading in to unflatten_plane.pro
openw, lun, /get_lun, 'transformations.txt', error=err
free_lun, lun
; convert latitude into spherical
theta = 90.d0 - theta
; convert degrees into radians for idl operators sin, cos.
phi = phi*!dpi/180.d0
theta = theta*!dpi/180.d0

; NEED TO SPECIFY THE CASE FOR WHEN THE LOWEST AND HIGHEST ARE BESIDE EACH OTHER DON'T LABEL THEM p1 AND p4 (they must be opposite each other)!

x = r*sin(theta)*cos(phi)
y = r*sin(theta)*sin(phi)
z = r*cos(theta)
print, 'x, y, z: ', x, y, z

save, x,y,z,f='vertices.sav'

p1 = [x[0],y[0],z[0]]
p2 = [x[1],y[1],z[1]]
p3 = [x[2],y[2],z[2]]
p4 = [x[3],y[3],z[3]]
print, 'before checking order'
print, 'p1: ',p1
print, 'p2: ',p2
print, 'p3: ',p3
print, 'p4: ',p4
openu, lun, 'transformations.txt', /append
printf, lun, '# Before checking order p1,p2,p3,p4'
printf, lun, p1
printf, lun, p2
printf, lun, p3
printf, lun, p4
free_lun, lun

; This if statement says if p1 is the lowest point in the y-direction then I can determine if p4 is opposite by the slopes
if p1[1] lt p2[1] && p1[1] lt p3[1] && p1[1] lt p4[1] then begin
	count = -1
	jump1:
	count += 1
	print, 'count ', count
	case count of
		0:	begin
			p1 = [x[0],y[0],z[0]]
			p2 = [x[1],y[1],z[1]]
			p3 = [x[2],y[2],z[2]]
			p4 = [x[3],y[3],z[3]]
			end
		1:	begin
			p1 = [x[0],y[0],z[0]]
			p2 = [x[1],y[1],z[1]]
			p3 = [x[3],y[3],z[3]]
			p4 = [x[2],y[2],z[2]]
			end
		2:	begin
			p1 = [x[0],y[0],z[0]]
			p2 = [x[3],y[3],z[3]]
			p3 = [x[2],y[2],z[2]]
			p4 = [x[1],y[1],z[1]]
			end
	endcase
	print, 'p1 ', p1 & print, 'p2 ', p2 & print, 'p3 ', p3 & print, 'p4 ', p4
	
	slope_p1p2 = (p2[1]-p1[1]) / (p2[0]-p1[0])
	slope_p1p3 = (p3[1]-p1[1]) / (p3[0]-p1[0])
	slope_p1p4 = (p4[1]-p1[1]) / (p4[0]-p1[0])
	print, 'slope_p1p2 ', slope_p1p2 & print, 'slope_p1p3 ', slope_p1p3 & print, 'slope_p1p4 ', slope_p1p4
	angle_p1p2= atan(slope_p1p2) * 180.d0/!dpi
	angle_p1p3= atan(slope_p1p3) * 180.d0/!dpi
	angle_p1p4= atan(slope_p1p4) * 180.d0/!dpi
	if angle_p1p2 lt 0 then angle_p1p2 += 180.d0
	if angle_p1p3 lt 0 then angle_p1p3 += 180.d0
	if angle_p1p4 lt 0 then angle_p1p4 += 180.d0
	print, 'angle_p1p2 ', angle_p1p2 & print, 'angle_p1p3 ', angle_p1p3 & print, 'angle_p1p4 ', angle_p1p4
	
	if ~keyword_set(noplot) then begin
		surface, dist(5), /nodata, /save, xrange=[xmin,xmax], yrange=[ymin,ymax], zrange=[zmin,zmax], $
		        xstyle=1, ystyle=1, zstyle=1, charsize=2, ax=50,az=20,/xs,/ys,/zs
		plots, x, y, z, color=1, psym=2, /t3d
		plots, p1, color=1, psym=1, /t3d ;plus
		xyouts,p1[0],p1[1],'p1',z=p1[2],/t3d,charsize=1
		plots, p2, color=1, psym=2, /t3d ;asterisk
		plots, p3, color=1, psym=4, /t3d ;
		plots, p4, color=1, psym=5, /t3d ;
		if keyword_set(pause) then pause
	endif
	if angle_p1p4 gt angle_p1p2 && angle_p1p4 gt angle_p1p3 then goto, jump1
	if angle_p1p4 lt angle_p1p2 && angle_p1p4 lt angle_p1p3 then goto, jump1
endif else begin
	p1 = [x[0],y[0],z[0]]
        p2 = [x[1],y[1],z[1]]
        p3 = [x[2],y[2],z[2]]
        p4 = [x[3],y[3],z[3]]
endelse
;********************************

print, 'After checking order'
print, 'p1: ', p1 & print, 'p2: ', p2 & print, 'p3: ', p3 & print, 'p4: ', p4
if ~keyword_set(noplot) then begin
	surface, dist(5), /nodata, /save, xrange=[xmin,xmax], yrange=[ymin,ymax], zrange=[zmin,zmax], $
	        xstyle=1, ystyle=1, zstyle=1, charsize=2, ax=angle_x,az=angle_z
	;plots, x, y, z, color=1, psym=2, /t3d
	plots, p1, color=1, psym=1, /t3d 
	xyouts,p1[0]+1,p1[1]+1,'1',z=p1[2],/t3d,charsize=2,alignment=1
	plots, p2, color=1, psym=2, /t3d
	xyouts,p2[0]+1,p2[1]+1,'2',z=p2[2],/t3d,charsize=2,alignment=1
	plots, p3, color=1, psym=4, /t3d
	xyouts,p3[0]+1,p3[1]+1,'3',z=p3[2],/t3d,charsize=2,alignment=1
	plots, p4, color=1, psym=5, /t3d 
	xyouts,p4[0]+1,p4[1]+1,'4',z=p4[2],/t3d,charsize=2,alignment=1
	if keyword_set(pauses) then pause
endif

save,p1,p2,p3,p4,f='p1-4_init.sav'

openu, lun, 'transformations.txt', /append
printf, lun, '# After checking order p1,p2,p3,p4)'
printf, lun, p1[0], p1[1], p1[2]
printf, lun, p2[0], p2[1], p2[2]
printf, lun, p3[0], p3[1], p3[2]
printf, lun, p4[0], p4[1], p4[2]
free_lun, lun

; move all the points to have p1 at the origin
p1_init = p1
p2 -= p1
p3 -= p1
p4 -= p1
p1 -= p1

print, 'p1 ', p1 & print, 'p2 ', p2 & print, 'p3 ', p3 & print, 'p4 ', p4

; Rotate p1 and p4 into alignment through angle1 then drop by angle2.
angle1 = atan((p4[1]-p1[1])/(p4[0]-p1[0])) ; this is in radians
; Then have to rotate all the points before doing another angle calculation.
;print, 'angle1_radians: ', angle1
print, 'angle1_degrees: ', angle1*180.d0/!dpi
angle1 *= (180.d0/!dpi) ; computations for rotation require degrees
if angle1 gt 0 then angle1 = (90.d0-angle1)
if angle1 lt 0 then angle1 = -(90.d0+angle1)
angle1 *= (!dpi/180.d0)
print, 'angle1_rot: ', angle1*180/!dpi

openu, lun, 'transformations.txt', /append
printf, lun, '# angle1 angle2 angle3 angle4 (radians)'
printf, lun, angle1
free_lun, lun

temp_p2 = p2
temp_p3 = p3
temp_p4 = p4
temp_p2[0] = p2[0]*cos(angle1) - p2[1]*sin(angle1)
temp_p2[1] = p2[0]*sin(angle1) + p2[1]*cos(angle1)
p2 = temp_p2
temp_p3[0] = p3[0]*cos(angle1) - p3[1]*sin(angle1)
temp_p3[1] = p3[0]*sin(angle1) + p3[1]*cos(angle1)
p3 = temp_p3
temp_p4[0] = p4[0]*cos(angle1) - p4[1]*sin(angle1)
temp_p4[1] = p4[0]*sin(angle1) + p4[1]*cos(angle1)
p4 = temp_p4

print, 'p1 ', p1 & print, 'p2 ', p2 & print, 'p3 ', p3 & print, 'p4 ', p4

save,p1,p2,p3,p4,f='p1-4_second.sav'

if ~keyword_set(noplot) then begin
	;surface, dist(5), /nodata, /save, xrange=[xmin,xmax], yrange=[ymin,ymax], zrange=[zmin,zmax], $
	;        xstyle=1, ystyle=1, zstyle=1, charsize=2, ax=50,az=20
	;plots, x, y, z, color=1, psym=2, /t3d
	plots, p1, color=2, psym=1, /t3d 
	xyouts,p1[0]+1,p1[1]+1,'1',z=p1[2],/t3d,charsize=2,alignment=1,color=2
	plots, p2, color=2, psym=2, /t3d
	xyouts,p2[0]+1,p2[1]+1,'2',z=p2[2],/t3d,charsize=2,alignment=1,color=2
	plots, p3, color=2, psym=4, /t3d
	xyouts,p3[0]+1,p3[1]+1,'3',z=p3[2],/t3d,charsize=2,alignment=1,color=2
	plots, p4, color=2, psym=5, /t3d 
	xyouts,p4[0]+1,p4[1]+1,'4',z=p4[2],/t3d,charsize=2,alignment=1,color=2
	if keyword_set(pauses) then pause
endif

; With p1 and p4 aligned, check that p2 and p3 are clockwise in order of p1,p3,p4,p2. No check here though !!!?!!!

; Now want to flatten p4 into the z=0 plane with p1.

angle2 = atan((p4[2]-p1[2])/(p4[1]-p1[1]))
if angle2 lt 0 then angle2 = -angle2
print, 'angle2: ', angle2*180.d0/!dpi

temp_p2 = p2
temp_p3 = p3
temp_p4 = p4
temp_p2[1] = p2[1]*cos(angle2) - p2[2]*sin(angle2)
temp_p2[2] = p2[1]*sin(angle2) + p2[2]*cos(angle2)
p2 = temp_p2
temp_p3[1] = p3[1]*cos(angle2) - p3[2]*sin(angle2)
temp_p3[2] = p3[1]*sin(angle2) + p3[2]*cos(angle2)
p3 = temp_p3
temp_p4[1] = p4[1]*cos(angle2) - p4[2]*sin(angle2)
temp_p4[2] = p4[1]*sin(angle2) + p4[2]*cos(angle2)
p4 = temp_p4

if ~keyword_set(noplot) then begin
	;surface, dist(5), /nodata, /save, xrange=[xmin,xmax], yrange=[ymin,ymax], zrange=[zmin,zmax], $
	;        xstyle=1, ystyle=1, zstyle=1, charsize=2, ax=50,az=20
	;plots, x, y, z, color=1, psym=2, /t3d
	plots, p1, color=3, psym=1, /t3d 
	xyouts,p1[0]+1,p1[1]+1,'1',z=p1[2],/t3d,charsize=2,alignment=1,color=3
	plots, p2, color=3, psym=2, /t3d
	xyouts,p2[0]+1,p2[1]+1,'2',z=p2[2],/t3d,charsize=2,alignment=1,color=3
	plots, p3, color=3, psym=4, /t3d
	xyouts,p3[0]+1,p3[1]+1,'3',z=p3[2],/t3d,charsize=2,alignment=1,color=3
	plots, p4, color=3, psym=5, /t3d 
	xyouts,p4[0]+1,p4[1]+1,'4',z=p4[2],/t3d,charsize=2,alignment=1,color=3
	if keyword_set(pauses) then pause
endif

save,p1,p2,p3,p4,f='p1-4_third.sav'

; Now tilt the p2 and p3 points so the whole quadrilateral lies in the z=0 plane.

angle3 = atan((p3[2]-p2[2])/(p3[0]-p2[0]))
if angle3 lt 0 then angle3 = -angle3
print, 'angle3: ', angle3*180.d0/!dpi

temp_p2 = p2
temp_p3 = p3
temp_p2[0] = p2[0]*cos(angle3) - p2[2]*sin(angle3)
temp_p2[2] = p2[0]*sin(angle3) + p2[2]*cos(angle3)
p2 = temp_p2
temp_p3[0] = p3[0]*cos(angle3) - p3[2]*sin(angle3)
temp_p3[2] = p3[0]*sin(angle3) + p3[2]*cos(angle3)
p3 = temp_p3

print, 'p1 ', p1 & print, 'p2 ', p2 & print, 'p3 ', p3 & print, 'p4 ', p4

if ~keyword_set(noplot) then begin
	;surface, dist(5), /nodata, /save, xrange=[xmin,xmax], yrange=[ymin,ymax], zrange=[zmin,zmax], $
	;        xstyle=1, ystyle=1, zstyle=1, charsize=2, ax=50,az=20
	;plots, x, y, z, color=1, psym=2, /t3d
	plots, p1, color=4, psym=1, /t3d 
	xyouts,p1[0]+1,p1[1]+1,'1',z=p1[2],/t3d,charsize=2,alignment=1,color=4
	plots, p2, color=4, psym=2, /t3d
	xyouts,p2[0]+1,p2[1]+1,'2',z=p2[2],/t3d,charsize=2,alignment=1,color=4
	plots, p3, color=4, psym=4, /t3d
	xyouts,p3[0]+1,p3[1]+1,'3',z=p3[2],/t3d,charsize=2,alignment=1,color=4
	plots, p4, color=4, psym=5, /t3d 
	xyouts,p4[0]+1,p4[1]+1,'4',z=p4[2],/t3d,charsize=2,alignment=1,color=4
	if keyword_set(pauses) then pause
endif

; Now the quadrilateral should be sitting completely flat in z=0 plane with p1 at the origin.

; *************************

; Transform quadrilateral at origin with one side along the y-axis to give vertices:
; (0,0), (0,C), (A,B), (s,t)

slope_p2 = atan(p2[1]/p2[0])
slope_p3 = atan(p3[1]/p3[0])
print, 'slope_p2: ', slope_p2*180.d0/!dpi
print, 'slope_p3: ', slope_p3*180.d0/!dpi
if slope_p2 lt 0 then angle4 = slope_p2 else angle4 = slope_p3
print, 'angle4: ', angle4*180.d0/!dpi

temp_p2 = p2
temp_p3 = p3
temp_p4 = p4
temp_p2[0] = p2[0]*cos(angle4) - p2[1]*sin(angle4)
temp_p2[1] = p2[0]*sin(angle4) + p2[1]*cos(angle4)
p2 = temp_p2
temp_p3[0] = p3[0]*cos(angle4) - p3[1]*sin(angle4)
temp_p3[1] = p3[0]*sin(angle4) + p3[1]*cos(angle4)
p3 = temp_p3
temp_p4[0] = p4[0]*cos(angle4) - p4[1]*sin(angle4)
temp_p4[1] = p4[0]*sin(angle4) + p4[1]*cos(angle4)
p4 = temp_p4

;draw_circle,0,0,(sqrt(p2[0]^2.d0+p2[1]^2.d0))
;draw_circle,0,0,(sqrt(p3[0]^2.d0+p3[1]^2.d0))
;draw_circle,0,0,(sqrt(p4[0]^2.d0+p4[1]^2.d0))

if angle4 eq slope_p3 then begin
	print, 'rotated to (0,0), (A,B), (0,C), (s,t)'
	a=p2[0]
	b=p2[1]
	c=p3[1]
	s=p4[0]
	t=p4[1]
	print, 'p1 ', p1 & print, 'p2 ', p2 & print, 'p3 ', p3 & print, 'p4 ', p4
	print, 'a,b,c,s,t: ', a,b,c,s,t
	print, '***'
endif else begin
	print, 'rotated to (0,0), (0,C), (A,B), (s,t)'
	c=p2[1]
	a=p3[0]
	b=p3[1]
	s=p4[0]
	t=p4[1]
	print, 'p1 ', p1 & print, 'p2 ', p2 & print, 'p3 ', p3 & print, 'p4 ', p4
	print, 'a,b,c,s,t: ', a,b,c,s,t
	print, '***'
endelse

if ~keyword_set(noplot) then begin
	;surface, dist(5), /nodata, /save, xrange=[xmin,xmax], yrange=[ymin,ymax], zrange=[zmin,zmax], $
	;        xstyle=1, ystyle=1, zstyle=1, charsize=2, ax=50,az=20
	;plots, x, y, z, color=1, psym=2, /t3d
	plots, p1, color=5, psym=1, /t3d 
	xyouts,p1[0]+1,p1[1]+1,'1',z=p1[2],/t3d,charsize=2,alignment=1,color=5
	plots, p2, color=5, psym=2, /t3d
	xyouts,p2[0]+1,p2[1]+1,'2',z=p2[2],/t3d,charsize=2,alignment=1,color=5
	plots, p3, color=5, psym=4, /t3d
	xyouts,p3[0]+1,p3[1]+1,'3',z=p3[2],/t3d,charsize=2,alignment=1,color=5
	plots, p4, color=5, psym=5, /t3d 
	xyouts,p4[0]+1,p4[1]+1,'4',z=p4[2],/t3d,charsize=2,alignment=1,color=5
	if keyword_set(pauses) then pause
endif

end