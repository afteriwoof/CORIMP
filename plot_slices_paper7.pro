; Created: 16-02-10 from plot_slices_paper5.pro to go to combining2/.
; Last Edited: 28-01-09
; Last Edited: 01-02-09 to include angle_x, angle_z inputs.
; Last Edited: 19-03-09 to be a for-loop over the slice folders where some are removed (bogus_slices).
; 26-03-09 to make the nolabels keyword.
; 28-04-09 to include the room_all keyword.
; Created plot_slices_paper.pro from plot_slices.pro to output image in paper format.

pro plot_slices_paper7, angle_x, angle_z, mov, nolabels=nolabels, zoom=zoom, no_ell=no_ell, plot_cone=plot_cone, pauses=pauses, no_proj=no_proj, over=over, room_all=room_all

print, 'Need to use this code from the ~/PhD/Data_Stereo/20081212/combining2/cor2/1122/my_scc_measure/slices_all/ folder'

!p.multi=0

!p.charthick=4.5
!p.thick=3.5
!x.thick=3.5
!y.thick=3.5
!z.thick=3.5

;window, 0, xs=1200, ys=1000





;******************************
; Fourth image


if ~keyword_set(zoom) then surface, dist(5), /nodata, /save, xrange=[-40,220], yrange=[-160,160], $
	zrange=[-100,100], xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x,az=angle_z, xtit='Solar Radii' $
	else surface, dist(5), /nodata, /save, xr=[-1,50], yr=[-20,25], zr=[-15,20], $
	xstyle=1, ystyle=1, zstyle=1, charsize=3.5, ax=angle_x, az=angle_z, pos=[0.10,0.10,0.90,0.90], $
	xtickname=[' ',' ',' ',' ',' ',' '], ytickname=[' ',' ',' ',' ',' '], ztickname=[' ',' ',' ',' ',' ',' ',' ',' '], $
	xticklen=0.06, yticklen=0.04, zticklen=0.04

if keyword_set(room_all) then surface, dist(5), /nodata, /save, xr=[0,40], yr=[-30,10], zr=[-20,25], $
	xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x, az=angle_z, xtit='Solar Radii'



;legend,[COR1 06:15,COR2 08:22,COR2 11:22,COR2 14:52,HI1   18:49,HI1   01:29], charsize=2, /left


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
plots, xb, yb, zb, psym=5, color=4, /t3d

if ~keyword_set(nolabels) then begin
if ~keyword_set(zoom) then xyouts, 0,3,'Sun',z=0,charsize=2,alignment=1,/t3d $
	else xyouts, 7,-1.5,'Sun',z=0,charsize=1.5,alignment=1
	xyouts, 220, 0, 'Earth', z=0, charsize=3,alignment=0, /t3d
	xyouts, 210, -10, 'SOHO', z=0, charsize=2, alignment=1, /t3d
	xyouts, xa-1, ya+6, 'STEREO-A', z=za, charsize=2, alignment=1, /t3d
	xyouts, xb-5, yb-8, 'STEREO-B', z=zb, charsize=2, alignment=1, /t3d
endif

goto,jump2
print, '1122'
for k=3,77 do begin ;removed 78
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor


cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/1052/my_scc_measure/slices_all'
print, '1052'
for k=7,86 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/1022/my_scc_measure/slices_all'
print, '1022'
for k=3,66 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/0952/my_scc_measure/slices_all'

for k=1,59 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/0922/my_scc_measure/slices_all'
print, '0922'
for k=1,1 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=3,40 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=43,53 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=55,73 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

jump2:

cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/0852/my_scc_measure/slices_all'
print, '0852'
for k=13,15 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

for k=17,97 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

goto, jump3

cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/0822/my_scc_measure/slices_all'
print, '0822'
for k=13,98 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

jump3:

cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/1452/my_scc_measure/slices_all'
print, '1452'
num = [5,7]
for i=0,1 do begin
	k = num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

for k=9,76 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

for k=78,95 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/1152/my_scc_measure/slices_all'
print, '1152'
for k=1,1 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor


for k=4,85 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

goto, jump6
cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/1222/my_scc_measure/slices_all'
print, '1222'
for k=1,67 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor



;********
;The COR1 frames


cd,'~/PhD/Data_Stereo/20081212/combining2/cor1/0735/my_scc_measure/slices_all'
print, '0735'
num=[3,8,10,11,12,14,79,80,81,82,83,84,87,91]

for i=0,5 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=16,77 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for i=6,13 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

cd,'~/PhD/Data_Stereo/20081212/combining2/cor1/0715/my_scc_measure/slices_all'
print, '0715'
num = [9,11,12,15,16,83,84,85,87,88,89,90,91,92,94,96,99]
for i=0,4 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=18,81 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for i=5,16 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

cd,'~/PhD/Data_Stereo/20081212/combining2/cor1/0705/my_scc_measure/slices_all'
print, '0705'
num = [5,7,9,11,13,14,15,16,17,82,83,84,85,87,89,90,92,94,96]
for i=0,18 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=19,80 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

cd,'~/PhD/Data_Stereo/20081212/combining2/cor1/0655/my_scc_measure/slices_all'
print, '0655'
num = [6,8,10,12]
for i=0,3 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=14,96 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

cd,'~/PhD/Data_Stereo/20081212/combining2/cor1/0645/my_scc_measure/slices_all'
print, '0645'
num = [7,9,11,12,13,15,78,79,80,81,82,83,84,85,86,87,89,90,91,92,94,96,97]
for i=0,22 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=17,76 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

cd,'~/PhD/Data_Stereo/20081212/combining2/cor1/0635/my_scc_measure/slices_all'
print, '0635'
num = [5,8,10,11,13,15,16,17,92,93,96,98,99]
for i=0,12 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=19,90 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
jump6:
cd,'~/PhD/Data_Stereo/20081212/combining2/cor1/0625/my_scc_measure/slices_all'
print, '0625'
num=[9,11,13,76,77,78,79,81,82,83,87,88,89]

for j=0,2 do begin
	k = num[j]
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

for k=15,74 do begin
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

for j=3,12 do begin
	k = num[j]
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

goto, jump4
cd,'~/PhD/Data_Stereo/20081212/combining2/cor1/0615/my_scc_measure/slices_all'
print, '0615'
num=[2,3,5,7,8,9,10,11,59,60,61,62,63,64,65,66,68,69,70,73]
for i=0,7 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=13,57 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for i=8,19 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

cd,'~/PhD/Data_Stereo/20081212/combining2/cor1/0605/my_scc_measure/slices_all'
print, '0605'
num=[2,3,4,6,64,66,67,68,70]

for j=0,3 do begin
	k = num[j]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

for k=8,62 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

for j=4,8 do begin
	k = num[j]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d
	if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

jump4:


;**************
; The HI-1 frames


cd,'~/PhD/Data_Stereo/20081212/combining/HI1/0129/my_scc_measure/slices_all'
print, '0129'
num=[1,3,4,7,8,10,11,13,14,15,16,17,18,19,87,88,89,91,92,93,95] ;removed 99
for i=0,13 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=21,85 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for i=14,20 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

goto, jump5
cd,'~/PhD/Data_Stereo/20081212/combining/HI1/2129/my_scc_measure/slices_all'
print, '2129'
num = [2,4,82,83,84,85,86,88,89]
for i=0,8 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=6,80 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
jump5:
cd,'~/PhD/Data_Stereo/20081212/combining/HI1/1849/my_scc_measure/slices_all'
print, '1849'
num = [7,91]
for i=0,0 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for k=9,89 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor
for i=1,1 do begin
	k=num[i]
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor

goto, jump1
cd,'~/PhD/Data_Stereo/20081212/combining/HI1/1649/my_scc_measure/slices_all'
print, '1649'
for k=9,83 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	;if ~keyword_set(no_proj) then begin
	;	for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
	;	for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	;endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	front_section,x,y,z,xe,ye,ze,xf,yf,zf
	plots, xf, yf, zf, /t3d, psym=-3, linestyle=1
	;if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d
	if keyword_set(pauses) then pause
endfor




jump1:


print,'***' & print, 'is the legend correct?'


; Back to 1122 folder
cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/1122/my_scc_measure/slices_all'


end
