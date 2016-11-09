; Code to calculate the kinematics & dynamics of the ellipsoid in the plane w.r.t. its centre and the Sun (centre or s.r.)

; Created: 10-03-09
; Last Edited: 10-03-09

pro ellipsoid_sun_plane, xes, yes, zes

; Condition to be sure I'm not including the origin
ind = where(xes ne 0 and yes ne 0 and zes ne 0)
xes = xes[ind]
yes = yes[ind]
zes = zes[ind]

angle_x = 90
angle_z = 0
surface, dist(5), /nodata, /save, xrange=[-20,20], yrange=[-20,20], $
	zrange=[-20,20], xstyle=1, ystyle=1, zstyle=1, charsize=2, ax=angle_x, az=angle_z, xtit='Solar Radii'
plots, xes, yes, zes, psym=3, /t3d

; could actually input any coordinate for xa,ya,za and rotate the ellipsoid into that plane! Here taking average(centre).
xa = ave(xes[where(finite(xes) ne 0)])
ya = ave(yes[where(finite(yes) ne 0)]) ;finite thing is to not include any NaN arrays from faulty slices!
za = ave(zes[where(finite(zes) ne 0)])
plots, xa, ya, za, psym=2, color=3, /t3d ;Ellipsoid Centre
plots, 0,0,0, psym=2, color=2, /t3d ;Sun Centre

; rotate all the points on the ellipse into the sun/ellipsoid-centre plane.

; compute the angle of rotation
if (xa gt 0 && ya lt 0) || (xa lt 0 && ya gt 0) then print, 'Should Rotate Clockwise'
if (xa lt 0 && ya lt 0) || (xa gt 0 && ya gt 0) then print, 'Should Rotate Counter-Clockwise'
m = xa / ya ;slope
alpha = atan(m) ;radian
alpha_deg = atan(m) * 180/!pi ;convert to degrees
print, 'Rotation alpha_deg: ', alpha_deg

xesr = xes*cos(alpha)-yes*sin(alpha)
yesr = xes*sin(alpha)+yes*cos(alpha)

plots, xesr, yesr, zes, psym=3, color=4, /t3d

save, alpha_deg, xesr, yesr, zes, f='sun_ellipsoid_centre_plane.sav'


end
