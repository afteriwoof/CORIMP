; Code to readin the saved files from ellipsoid_any_plane.pro and run the ellipse fit to spit out the kinematics parameters to copy to text file angle_slices.txt.

; Created: 07-04-09


pro readin_ell_planes, in, da

read, 'How many angle planes? ', n
read, 'Start from? ', i
i = round(i)
n = round(n)

for k=i,n do begin
	restore,'ell_any_plane_'+int2str(k)+'.sav', /ver
	yesrna = yesrn*in.rsun
	zesna = zesn*in.rsun
	front_ell_kins, yesrna, zesna, 1, in, da, 2, /arcsec, /noflank
	pause
endfor




end
