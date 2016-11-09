; Trying to reverse the transformations in flatten_plane.pro

; Created: 18-09-08
; Last Edited: 18-09-08

pro unflatten_vertices_new, p1,p2,p3,p4, angle1, angle2, angle3, angle4, p1_init, xe, ye, ze, pauses=pauses

; all rotations happen about point p1

angle4 = -angle4
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

print, 'p1 ', p1 & print, 'p2 ', p2 & print, 'p3 ', p3 & print, 'p4 ', p4

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

angle3 = -angle3
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

angle2 = -angle2
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

print, 'p1 ', p1 & print, 'p2 ', p2 & print, 'p3 ', p3 & print, 'p4 ', p4

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

angle1 = -angle1
temp_p2 = p2
temp_p3 = p3
temp_p4 = p4
temp_p2[0] = p2[0]*cos(angle1) - p2[1]*sin(angle1)
temp_p2[1] = p2[0]*sin(angle1) + p2[1]*cos(angle1)
p2 = temp_p2 + p1_init
temp_p3[0] = p3[0]*cos(angle1) - p3[1]*sin(angle1)
temp_p3[1] = p3[0]*sin(angle1) + p3[1]*cos(angle1)
p3 = temp_p3 + p1_init
temp_p4[0] = p4[0]*cos(angle1) - p4[1]*sin(angle1)
temp_p4[1] = p4[0]*sin(angle1) + p4[1]*cos(angle1)
p4 = temp_p4 + p1_init
p1 = p1_init

print, 'p1 ', p1 & print, 'p2 ', p2 & print, 'p3 ', p3 & print, 'p4 ', p4

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


stop


	xe[k] = xe_org[k]*cos(-angle4) - ye_org[k]*sin(-angle4)
	ye[k] = xe_org[k]*sin(-angle4) + ye_org[k]*cos(-angle4)
	xe_org[k] = xe[k]
	ye_org[k] = ye[k]


if ~keyword_set(noplot) then plots, xe, ye, ze, /t3d, color=4
if keyword_set(pauses) then pause

for k=0,sz[0]-1 do begin
	xe[k] = xe_org[k]*cos(-angle3); - ze_org[k]*sin(-angle3)
	ze[k] = xe_org[k]*sin(-angle3); + ze_org[k]*cos(-angle3)
	xe_org[k] = xe[k]
	ze_org[k] = ze[k]
endfor

if ~keyword_set(noplot) then plots, xe, ye, ze, /t3d, color=3
if keyword_set(pauses) then pause

for k=0,sz[0]-1 do begin
	ye[k] = ye_org[k]*cos(-angle2) - ze_org[k]*sin(-angle2)
	ze[k] = ye_org[k]*sin(-angle2) + ze_org[k]*cos(-angle2)
	ye_org[k] = ye[k]
	ze_org[k] = ze[k]
endfor

if ~keyword_set(noplot) then plots, xe, ye, ze, /t3d, color=2
if keyword_set(pauses) then pause

for k=0,sz[0]-1 do begin
	xe[k] = xe_org[k]*cos(-angle1) - ye_org[k]*sin(-angle1)
	ye[k] = xe_org[k]*sin(-angle1) + ye_org[k]*cos(-angle1)
	xe[k] += p1_init[0]
	ye[k] += p1_init[1]
	ze[k] += p1_init[2]
endfor

if ~keyword_set(noplot) then plots, xe, ye, ze, /t3d, color=1
;if keyword_set(pauses) then pause


save, xe, ye, ze, f='ell.sav'

end
