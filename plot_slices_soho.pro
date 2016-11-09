; Created: 2013-04-03	from plot_slices.pro but copying one of the original plot_slices_soho.pro in the other folders, to generalise for any event.
;			This code is called from slices_all/ folder.


;INPUTS:	slice_begin	is the starting sliceN folder
;		slice_end	is the final sliceN folder
;		bogus_slice	is the file, '../bogus_slices/bogus_slices.txt'.
;		ledge		string to put as legend, containing instrument and date/time
;		angle_x/z	are just the 3D plot orientation angles.

;OUTPUTS:	mov		a movie file.


pro plot_slices_soho, slice_begin, slice_end, bogus_slices, ledge, angle_x, angle_z, mov, nolabels=nolabels, zoom=zoom, no_ell=no_ell, plot_cone=plot_cone, pauses=pauses, no_proj=no_proj, save_front=save_front, over=over, room_all=room_all

readcol, bogus_slices, bogus, f='B'

if ~keyword_set(over) then begin

window, 0, xs=800, ys=800

xr1 = -5
xr2 = 15
yr1 = -15
yr2 = 15
zr1 = -10
zr2 = 10

if ~keyword_set(zoom) then surface, dist(5), /nodata, /save, xrange=[-40,220], yrange=[-160,160], $
	zrange=[-100,100], xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x,az=angle_z, xtit='Solar Radii' $
	else surface, dist(5), /nodata, /save, xr=[-3,7], yr=[-5,5], zr=[-3,7], $
	xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x, az=angle_z, xtit='Solar Radii'
if keyword_set(room_all) then surface, dist(5), /nodata, /save, xr=[0,40], yr=[-30,10], zr=[-20,25], $
	xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x, az=angle_z, xtit='Solar Radii'

endif

legend, ledge, charsize=2, /left


plots, 0,0,0,psym=2, color=6, /t3d ;Sun
;if ~keyword_set(zoom) then xyouts, 0,3,'Sun',z=0,charsize=2,alignment=1,/t3d $
;	else xyouts, -1,1,'Sun',z=0,charsize=2,alignment=1,/t3d

plots, 215, 0,0,psym=5,color=5,/t3d ; Average distance to Earth

plots, 213.5, 0, 0, psym=6, color=6, /t3d ; L1 point (SOHO)

; Make sphere of the Sun
sphere = fltarr(21,21,21)
for x=0,20 do for y=0,20 do for z=0,20 do $
	sphere[x,y,z] = sqrt((x-10)^2.+(y-10)^2.+(z-10)^2.)
shade_volume, sphere, 10, v, p
v = (v/max(v))*2 - 1
plots, v, psym=3, color=6, /t3d

; Plot the SOHO Plane-of-sky (x=0)
for k=0,abs(zr2-zr1) do plots, [0,0],[yr1,yr2],[(k-abs(zr2-zr1)*0.5),(k-abs(zr2-zr1)*0.5)],/t3d
for k=0,abs(yr2-yr1) do plots, [0,0],[(k-abs(yr2-yr1)*0.5),(k-abs(yr2-yr1)*0.5)],[zr1,zr2],/t3d

restore, '../../ahead_location.sav'
plots, xa, ya, za, psym=5, color=3, /t3d
restore, '../../behind_location.sav'
plots, xb, yb, zb, psym=5, color=4, /t3d

if ~keyword_set(nolabels) then begin
if ~keyword_set(zoom) then xyouts, 0,3,'Sun',z=0,charsize=2,alignment=1,/t3d $
	else xyouts, -1,1,'Sun',z=0,charsize=2,alignment=1,/t3d
	xyouts, 220, 0, 'Earth', z=0, charsize=2,alignment=0, /t3d
	xyouts, 210, -10, 'SOHO', z=0, charsize=2, alignment=1, /t3d
	xyouts, xa-1, ya+6, 'STEREO-A', z=za, charsize=2, alignment=1, /t3d
	xyouts, xb-5, yb-8, 'STEREO-B', z=zb, charsize=2, alignment=1, /t3d
endif

for k=slice_begin,slice_end do begin
	if where(bogus eq k) eq [-1] then begin
		print, 'slice'+int2str(k)
		restore, '../slice'+int2str(k)+'/vertices.sav'
		if ~keyword_set(no_proj) then begin
			for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
			for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
		endif
		restore, '../slice'+int2str(k)+'/ell.sav'
		front_section,x,y,z,xe,ye,ze,xf,yf,zf
		plots, xf, yf, zf, /t3d
		help,xf,yf,zf
		if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
		if keyword_set(pauses) then pause

		; trying to project the ellipse points into SOHO plane-of-sky (the x=0 plane).
		openw, lun, /get_lun, 'proj_soho_ell.txt', error=err
		free_lun, lun

		project_soho_ellipse, lun, xe, ye, ze

	endif
endfor


print,'***' & print, 'is the legend correct?'


end
