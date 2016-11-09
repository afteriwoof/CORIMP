; Created: 10-08-10 from plot_slices_paper6.pro to just plot out the 1452 contrained front with span of measurements for kinematics.
; Created: 09-02-10 from plot_slices_paper4.pro to include a many fronts.
; Last Edited: 28-01-09
; Last Edited: 01-02-09 to include angle_x, angle_z inputs.
; Last Edited: 19-03-09 to be a for-loop over the slice folders where some are removed (bogus_slices).
; 26-03-09 to make the nolabels keyword.
; 28-04-09 to include the room_all keyword.
; Created plot_slices_paper.pro from plot_slices.pro to output image in paper format.

pro plot_slices_span1452, angle_x, angle_z, mov, nolabels=nolabels, zoom=zoom, no_ell=no_ell, plot_cone=plot_cone, pauses=pauses, no_proj=no_proj, over=over, room_all=room_all

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
	else surface, dist(5), /nodata, /save, xr=[-1,20], yr=[-8,8], zr=[-5,10], ztickinterval=5, $
	xstyle=1, ystyle=1, zstyle=1, charsize=3.5, ax=angle_x, az=angle_z, pos=[0.10,0.10,0.90,0.90], $
	xtit='!3X!DHEEQ!N(R'+sunsymbol()+')', ytit='!3Y!DHEEQ!N(R'+sunsymbol()+')', ztit='!3Z!DHEEQ!N(R'+sunsymbol()+')', $
	xticklen=0.06, yticklen=0.04, zticklen=0.04
if keyword_set(room_all) then surface, dist(5), /nodata, /save, xr=[0,40], yr=[-30,10], zr=[-20,25], $
	xstyle=1, ystyle=1, zstyle=1, charsize=2.5, ax=angle_x, az=angle_z, xtit='Solar Radii'


plotsym, 0, /fill ; making the plot points circles


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
plots, v, psym=8, symsize=0.2, linestyle=1, color=6, /t3d

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



cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/1452/my_scc_measure/slices_all'

constrained = [indgen(9+1),indgen(87-55+1)+55]

ellipse_count = 0

for k=2,88 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	if where(constrained eq ellipse_count) ne [-1] then begin
		plots, xe, ye, ze, /t3d, psym=8, symsize=0.5
	endif else begin
		front_section,x,y,z,xe,ye,ze,xf,yf,zf
		plots, xf, yf, zf, /t3d, psym=8, symsize=0.5
		if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d, psym=8, symsize=0.5
		if keyword_set(pauses) then pause
	endelse
	ellipse_count+=1
endfor

for k=90,91 do begin
	;print, 'slice'+int2str(k)
	restore, '../slice'+int2str(k)+'/vertices.sav'
	if ~keyword_set(no_proj) then begin
		for i=0,3 do plots, [xa,x[i]], [ya,y[i]], [za,z[i]], linestyle=1, color=3, /t3d
		for i=0,3 do plots, [xb,x[i]], [yb,y[i]], [zb,z[i]], linestyle=1, color=4, /t3d
	endif
	restore, '../slice'+int2str(k)+'/ell.sav'
	if where(constrained eq ellipse_count) ne [-1] then begin
		plots, xe, ye, ze, /t3d, psym=8, symsize=0.5
	endif else begin
		front_section,x,y,z,xe,ye,ze,xf,yf,zf
		plots, xf, yf, zf, /t3d, psym=8, symsize=0.5
		if ~keyword_set(no_ell) then plots, xe, ye, ze, /t3d, psym=8, symsize=0.5
		if keyword_set(pauses) then pause
	endelse
	ellipse_count+=1
endfor

;print,'***' & print, 'is the legend correct?'

; Back to 1122 folder
cd,'~/PhD/Data_Stereo/20081212/combining2/cor2/1122/my_scc_measure/slices_all'

restore,'spancoords.sav',/ver
plots, [0,topx], [0,topy], [0,topz], /t3d, color=3, linestyle=0
plots, [0,botx], [0,boty], [0,botz], /t3d, color=9, linestyle=0
plots,[0,midx],[0,0],[0,midz],/t3d,color=5;, linestyle=3
plots,[0,midtopx],[0,0],[0,midtopz],/t3d,color=3, linestyle=2
plots,[0,midbotx],[0,0],[0,midbotz],/t3d,color=9, linestyle=2


end
