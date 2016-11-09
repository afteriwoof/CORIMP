; Created: 10-08-09 from plot_slices_paper3.pro to include a 4th frame of many fronts.
; Last Edited: 28-01-09
; Last Edited: 01-02-09 to include angle_x, angle_z inputs.
; Last Edited: 19-03-09 to be a for-loop over the slice folders where some are removed (bogus_slices).
; 26-03-09 to make the nolabels keyword.
; 28-04-09 to include the room_all keyword.
; Created plot_slices_paper.pro from plot_slices.pro to output image in paper format.

pro plot_slices_paper4, angle_x, angle_z, mov, nolabels=nolabels, zoom=zoom, no_ell=no_ell, plot_cone=plot_cone, pauses=pauses, no_proj=no_proj, over=over, room_all=room_all

if ~keyword_set(over) then begin

!p.multi=[0,1,4]

!p.charthick=4.5
!p.thick=3.5
!x.thick=3.5
!y.thick=3.5
!z.thick=3.5

!x.tickinterval=2
!y.tickinterval=2
!z.tickinterval=2
!x.minor=2
!y.minor=2
!z.minor=2

;window, 0, xs=700, ys=1200

if ~keyword_set(zoom) then surface, dist(5), /nodata, /save, xrange=[-40,220], yrange=[-160,160], $
	zrange=[-100,100], xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x,az=angle_z, xtit='Solar Radii' $
	else surface, dist(5), /nodata, /save, xr=[-2,12], yr=[-3,3], zr=[-2,4], $
	xstyle=1, ystyle=1, zstyle=1, charsize=5, ax=angle_x, az=angle_z, pos=[0.40,0.75,1.0,1.0], $
	xtickname=[' ',' ',' ',' ',' ',' ',' ',' '], ytickname=[' ',' ',' ',' ',' '], ztickname=[' ',' ',' ',' ',' ',' ',' '], $
	xticklen=0.2, yticklen=0.04, zticklen=0.04
if keyword_set(room_all) then surface, dist(5), /nodata, /save, xr=[0,40], yr=[-30,10], zr=[-20,25], $
	xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x, az=angle_z, xtit='Solar Radii'

endif

;legend, 'COR2 2008/12/12 11:22', charsize=2


;plots, 0,0,0,psym=2, color=6, /t3d ;Sun
;if ~keyword_set(zoom) then xyouts, 0,3,'Sun',z=0,charsize=2.5,alignment=1,/t3d $
;	else xyouts, -1,1,'Sun',z=0,charsize=2,alignment=1,/t3d

plots, 215, 0,0,psym=5,color=5,/t3d ; Average distance to Earth

plots, 213.5, 0, 0, psym=6, color=6, /t3d ; L1 point (SOHO)

; Make sphere of the Sun
sphere = fltarr(21,21,21)
for x=0,20 do for y=0,20 do for z=0,20 do $
	sphere[x,y,z] = sqrt((x-10)^2.+(y-10)^2.+(z-10)^2.)
shade_volume, sphere, 10, v, p
v = (v/max(v))*2 - 1
plots, v, psym=-3, linestyle=1, color=6, /t3d

cd,'~/PhD/Data_Stereo/20081212/combining/cor2/1122/my_scc_measure/slices_all'

restore, '../../ahead_location.sav'
plots, xa, ya, za, psym=5, color=3, /t3d
restore, '../../behind_location.sav'
plots, xb, yb, zb, psym=5, color=5, /t3d

if ~keyword_set(nolabels) then begin
if ~keyword_set(zoom) then xyouts, 0,3,'Sun',z=0,charsize=2,alignment=1,/t3d $
	else xyouts, 0.3,-1,'Sun',z=0,charsize=1.5,alignment=1
	xyouts, 220, 0, 'Earth', z=0, charsize=3,alignment=0, /t3d
	xyouts, 210, -10, 'SOHO', z=0, charsize=2, alignment=1, /t3d
	xyouts, xa-1, ya+6, 'STEREO-A', z=za, charsize=2, alignment=1, /t3d
	xyouts, xb-5, yb-8, 'STEREO-B', z=zb, charsize=2, alignment=1, /t3d
endif


for k=25,25 do begin
	print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=0, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=0, color=5, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor


if ~keyword_set(zoom) then surface, dist(5), /nodata, /save, xrange=[-40,220], yrange=[-160,160], $
	zrange=[-100,100], xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x,az=angle_z, xtit='Solar Radii' $
	else surface, dist(5), /nodata, /save, xr=[-2,12], yr=[-3,3], zr=[-2,4], $
	xstyle=1, ystyle=1, zstyle=1, charsize=5, ax=angle_x+1, az=angle_z+1, pos=[0.40,0.2,1.0,0.40], $
	xtickname=[' ',' ',' ',' ',' ',' ',' ',' '], ytickname=[' ',' ',' ',' ',' '], ztickname=[' ',' ',' ',' ',' ',' ',' '], $
	xticklen=0.2, yticklen=0.04, zticklen=0.04
if keyword_set(room_all) then surface, dist(5), /nodata, /save, xr=[0,40], yr=[-30,10], zr=[-20,25], $
	xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x, az=angle_z, xtit='Solar Radii'



;legend, 'COR2 2008/12/12 11:22', charsize=2


;plots, 0,0,0,psym=2, color=6, /t3d ;Sun
;if ~keyword_set(zoom) then xyouts, 0,3,'Sun',z=0,charsize=2.5,alignment=1,/t3d $
;	else xyouts, -1,1,'Sun',z=0,charsize=2,alignment=1,/t3d

plots, 215, 0,0,psym=5,color=5,/t3d ; Average distance to Earth

plots, 213.5, 0, 0, psym=6, color=6, /t3d ; L1 point (SOHO)

; Make sphere of the Sun
sphere = fltarr(21,21,21)
for x=0,20 do for y=0,20 do for z=0,20 do $
	sphere[x,y,z] = sqrt((x-10)^2.+(y-10)^2.+(z-10)^2.)
shade_volume, sphere, 10, v, p
v = (v/max(v))*2 - 1
plots, v, psym=-3, linestyle=1, color=6, /t3d

restore, '../../ahead_location.sav'
plots, xa, ya, za, psym=5, color=3, /t3d
restore, '../../behind_location.sav'
plots, xb, yb, zb, psym=5, color=5, /t3d

if ~keyword_set(nolabels) then begin
if ~keyword_set(zoom) then xyouts, 0,3,'Sun',z=0,charsize=2,alignment=1,/t3d $
	else xyouts, 0.3,-1,'Sun',z=0,charsize=1.5,alignment=1
	xyouts, 220, 0, 'Earth', z=0, charsize=3,alignment=0, /t3d
	xyouts, 210, -10, 'SOHO', z=0, charsize=2, alignment=1, /t3d
	xyouts, xa-1, ya+6, 'STEREO-A', z=za, charsize=2, alignment=1, /t3d
	xyouts, xb-5, yb-8, 'STEREO-B', z=zb, charsize=2, alignment=1, /t3d
endif

for k=2,68,2 do begin
	print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=5, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

for k=70,73,2 do begin
	print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=5, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

goto, jump1

if ~keyword_set(zoom) then surface, dist(5), /nodata, /save, xrange=[-40,220], yrange=[-160,160], $
	zrange=[-100,100], xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x,az=angle_z, xtit='Solar Radii' $
	else surface, dist(5), /nodata, /save, xr=[-1,10], yr=[-2.5,2.5], zr=[-1,4], $
	xstyle=1, ystyle=1, zstyle=1, charsize=4, ax=angle_x, az=angle_z, pos=[0.40,0.10,1.20,0.30];, xtit='Solar Radii'
if keyword_set(room_all) then surface, dist(5), /nodata, /save, xr=[0,40], yr=[-30,10], zr=[-20,25], $
	xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x, az=angle_z, xtit='Solar Radii'



;legend, 'COR2 2008/12/12 11:22', charsize=2


;plots, 0,0,0,psym=2, color=6, /t3d ;Sun
;if ~keyword_set(zoom) then xyouts, 0,3,'Sun',z=0,charsize=2.5,alignment=1,/t3d $
;	else xyouts, -1,1,'Sun',z=0,charsize=2,alignment=1,/t3d

plots, 215, 0,0,psym=5,color=5,/t3d ; Average distance to Earth

plots, 213.5, 0, 0, psym=6, color=6, /t3d ; L1 point (SOHO)

; Make sphere of the Sun
sphere = fltarr(21,21,21)
for x=0,20 do for y=0,20 do for z=0,20 do $
	sphere[x,y,z] = sqrt((x-10)^2.+(y-10)^2.+(z-10)^2.)
shade_volume, sphere, 8, v, p
v = (v/max(v))*2 - 1
plots, v, psym=-3, linestyle=1, color=6, /t3d

restore, '../../ahead_location.sav'
plots, xa, ya, za, psym=5, color=3, /t3d
restore, '../../behind_location.sav'
plots, xb, yb, zb, psym=5, color=5, /t3d

if ~keyword_set(nolabels) then begin
if ~keyword_set(zoom) then xyouts, 0,3,'Sun',z=0,charsize=2,alignment=1,/t3d $
	else xyouts, 0.3,-1,'Sun',z=0,charsize=1.5,alignment=1
	xyouts, 220, 0, 'Earth', z=0, charsize=3,alignment=0, /t3d
	xyouts, 210, -10, 'SOHO', z=0, charsize=2, alignment=1, /t3d
	xyouts, xa-1, ya+6, 'STEREO-A', z=za, charsize=2, alignment=1, /t3d
	xyouts, xb-5, yb-8, 'STEREO-B', z=zb, charsize=2, alignment=1, /t3d
endif

for k=2,68 do begin
	print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=5, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

for k=70,73 do begin
	print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=5, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

jump1:

print,'***' & print, 'is the legend correct?'




end
