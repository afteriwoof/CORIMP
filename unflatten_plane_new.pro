; Trying to reverse the transformations in flatten_plane.pro

; Created: 18-09-08
; Last Edited: 18-09-08

pro unflatten_plane_new, ell, angle1, angle2, angle3, angle4, p1_init, xe, ye, ze, pauses=pauses

; all rotations happen about point p1

xe_org = transpose(ell[0,*])
ye_org = transpose(ell[1,*])

sz = size(xe_org, /dim)
xe = dblarr(sz[0])
ye = dblarr(sz[0])
ze = dblarr(sz[0])
ze_org = dblarr(sz[0])
ze_org[*] = 5.0e-16

angle4 = -angle4
for k=0,sz[0]-1 do begin
	xe[k] = xe_org[k]*cos(angle4) - ye_org[k]*sin(angle4)
	ye[k] = xe_org[k]*sin(angle4) + ye_org[k]*cos(angle4)
	xe_org[k] = xe[k]
	ye_org[k] = ye[k]
endfor

if ~keyword_set(noplot) then plots, xe, ye, ze, /t3d, color=4
if keyword_set(pauses) then pause

angle3 = -angle3
for k=0,sz[0]-1 do begin
	xe[k] = xe_org[k]*cos(angle3) - ze_org[k]*sin(angle3)
	ze[k] = xe_org[k]*sin(angle3) + ze_org[k]*cos(angle3)
	xe_org[k] = xe[k]
	ze_org[k] = ze[k]
endfor

if ~keyword_set(noplot) then plots, xe, ye, ze, /t3d, color=3
if keyword_set(pauses) then pause

angle2 = -angle2
for k=0,sz[0]-1 do begin
	ye[k] = ye_org[k]*cos(angle2) - ze_org[k]*sin(angle2)
	ze[k] = ye_org[k]*sin(angle2) + ze_org[k]*cos(angle2)
	ye_org[k] = ye[k]
	ze_org[k] = ze[k]
endfor

if ~keyword_set(noplot) then plots, xe, ye, ze, /t3d, color=2
if keyword_set(pauses) then pause

angle1 = -angle1
for k=0,sz[0]-1 do begin
	xe[k] = xe_org[k]*cos(angle1) - ye_org[k]*sin(angle1)
	ye[k] = xe_org[k]*sin(angle1) + ye_org[k]*cos(angle1)
endfor

xe += p1_init[0]
ye += p1_init[1]
ze += p1_init[2]

if ~keyword_set(noplot) then plots, xe, ye, ze, /t3d, color=1
;if keyword_set(pauses) then pause


save, xe, ye, ze, f='ell.sav'

end
