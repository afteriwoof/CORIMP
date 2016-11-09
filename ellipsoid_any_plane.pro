; Code to calculate the kinematics & dynamics of the ellipsoid in the plane w.r.t. its centre and the Sun (centre or s.r.)

; Created: 31-03-09 from ellipsoid_sun_plane.pro.
; Last Edited: 07-04-09 to finish off calling in the project_ell and saving the results.

pro ellipsoid_any_plane, xes, yes, zes

angle_x = 90
angle_z = 0
surface, dist(5), /nodata, /save, xrange=[-20,20], yrange=[-20,20], $
	zrange=[-20,20], xstyle=1, ystyle=1, zstyle=1, charsize=2, ax=angle_x, az=angle_z, xtit='Solar Radii'
plots, xes, yes, zes, psym=3, /t3d


; Taking the angular extent of the ellipsoid in (x,y).
recpol, xes, yes, r, a, /degrees
a_min = min(a)
a_max = max(a)
print, 'a_min: ', a_min & print, 'a_max: ', a_max

; Take slice at every 5 degrees say
steps = intarr(72) ;360/5
steps[0] = 0
for i=1,71 do steps[i] = steps[i-1] + 5
ind = where(steps gt a_min and steps lt a_max)
print, 'The angles being taken: ', steps[ind]
steps = steps[ind]
save, steps, f='slice_angles.sav'

for i=0,n_elements(steps)-1 do begin
	alpha = (270-steps[i]) * !pi/180 ;rotate it to the x=0 plane which is at angle 270 (or 90).
	xesr = xes*cos(alpha) - yes*sin(alpha)
	yesr = xes*sin(alpha) + yes*cos(alpha)
	plots, xesr, yesr, zes, psym=3, color=((i mod 6)+1), /t3d
	wait, 0.1

	; Now have to take only the points from behind the slice
	project_ell, xesr, yesr, zes, xesrn, yesrn, zesn
	plots, xesrn, yesrn, zesn, psym=2, color=((i mod 6)+1), /t3d
	wait, 0.1

	save, xesrn, yesrn, zesn, f='ell_any_plane_'+int2str(i)+'.sav'
	
	
endfor


end
