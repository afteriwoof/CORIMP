; Created	04-04-11	from combine_pa_heights.pro to combine the heights along separate position angles for a CME detection

; Last edited	31-05-11	to include the case of Inf values appearing in the v.


pro combine_pa_heights2, in, heights, image_no, pos_angles, new_heights, new_image_no, new_pos_angles, remove_endpoints=remove_endpoints

set_line_color

!p.charsize=2.5
xs=800
ys=1200
window, xs=xs, ys=ys
t = in[image_no].date_obs
time = anytim(t)
utbasedata = time[0]

km_arc = 6.96e8 / (1000.*in.rsun)
heights_km = fltarr(n_elements(heights))
for i=0,n_elements(heights)-1 do heights_km[i] = heights[i]*km_arc[image_no[i]]

v = fltarr(n_elements(image_no)-1)

a = fltarr(n_elements(image_no)-2)

for i=0,n_elements(image_no)-2 do begin
	if image_no[i+1] gt image_no[i] then v[i] = (heights[i+1]-heights[i])/(time[i+1]-time[i])
endfor

for i=0,n_elements(image_no)-3 do begin
	if v[i+1] gt v[i] && v[i] ne 0 && v[i+1] ne 0 then a[i] = (v[i+1]-v[i])/(time[i+1]-time[i])
endfor

infvar = 3./0.
infs = where(v eq infvar)
if infs ne [-1] then begin
	print, 'Removing Inf values and replacing with maximums.'
	tempv = v
	remove, infs, tempv
	v[infs] = max(tempv)
endif
plot_hist,v,x,y;,bin=0.1
newx=fltarr(n_elements(x)-1)
newy=fltarr(n_elements(y)-1)
if where(x eq 0) ne 0 then begin
	newx[0:where(x eq 0)-1]=x[0:where(x eq 0)-1]
	newx[where(x eq 0):*]=x[(where(x eq 0)+1):*]
	newy[0:where(x eq 0)-1]=y[0:where(x eq 0)-1]
	newy[where(x eq 0):*]=y[(where(x eq 0)+1):*]
	x = newx
	y = newy
	delvarx, newx, newy
endif else begin
	x = x[1:*]
	y = y[1:*]
endelse

y_max = max(y)
ind = where(y eq y_max)
x_max = x[ind]
count = 1
while y[ind+count] lt y[ind+count-1] do begin
	x_cutoff1 = x[ind+count]
	count += 1
endwhile
count = 1
x_cutoff2 = x[ind-count]
while y[ind-count] lt y[ind-count+1] do begin
	x_cutoff2 = x[ind-count]
	count += 1
endwhile
print, x_cutoff1, x_cutoff2
verline, x_cutoff1
verline, x_cutoff2
;stop
;pause

inds = where(v le x_cutoff1[0] AND v ge x_cutoff2[0])

all_inds = [inds, inds+1]
delvarx, inds
all_inds = all_inds[uniq(all_inds,sort(all_inds))]
new_image_no = image_no[all_inds]
new_heights = heights_km[all_inds]
new_pos_angles = pos_angles[all_inds]
new_t = t[all_inds]
;plot,image_no,heights,psym=1, xtit='Image No.', ytit='Height (arcsec)'
;plots, image_no[all_inds], heights[all_inds], psym=6, color=3
flag = 0
flag1 = 0
big_count = 0
mov = fltarr(xs,ys,n_elements(new_pos_angles))
mov_count = 0
!p.multi=[0,1,3]
xls = 0.5e5
xrs = 1.0e5
while flag eq 0 do begin
	utplot, t, (heights_km/1000.), utbasedata, psym=1, ytit='Height (Mm)', pos=[0.15,0.70,0.95,0.98], $ 
		xr=[t[0]-xls,t[*]+xrs], /xs, /nolabel , xtickname=[' ',' ',' ',' ',' ',' ',' ']
	outplot, t[all_inds], (heights_km[all_inds]/1000.), psym=1, color=4
	;plot, image_no, heights, psym=1
	;plots, image_no[all_inds], heights[all_inds], psym=1, color=4
	count = 0
	h_now = new_heights[big_count+count] ;the current height
	t_now = new_t[big_count+count] ;the current time
	while new_image_no[big_count+count+1] gt new_image_no[big_count+count] do begin
		outplot, new_t[(big_count+count):(big_count+count+1)], new_heights[(big_count+count):(big_count+count+1)]/1000., psym=-6, color=3
		;plots, new_image_no[(big_count+count):(big_count+count+1)], new_heights[(big_count+count):(big_count+count+1)], psym=-6, color=3
		legend, 'Pos. angle: '+int2str(round(new_pos_angles[big_count+count])), /bottom, /right, charsize=2
		count += 1
		h_now = [h_now, new_heights[big_count+count]]
		t_now = [t_now, new_t[big_count+count]]
		if n_elements(h_now) gt 2 then begin
			v_now = deriv((anytim(t_now)-anytim(t_now[0])), h_now)
			a_now = deriv((anytim(t_now)-anytim(t_now[0])), v_now)
			flag1 = 1
		endif
		if big_count+count+1 ge n_elements(new_image_no) then goto, jump1
	endwhile
	jump1:
	if flag1 eq 1 then begin
		utplot, t_now, v_now, utbasedata, psym=-2, ytit='Velocity (km s!U-1!N)', xr=[t[0]-xls,t[*]+xrs], /xs, $
			yr=[0,2000], /ys, pos=[0.15,0.42,0.95,0.70], /nolabel, xtickname=[' ',' ',' ',' ',' ',' ',' ']
		utplot, t_now, a_now*1000., utbasedata, psym=-2, ytit='Accel. (m s!U-2!N)', xr=[t[0]-xls,t[*]+xrs], $
			/xs, yr=[-300,300], /ys, pos=[0.15,0.14,0.95,0.42]
	endif else begin
		utplot, t_now, h_now, utbasedata, /nodata, xr=[t[0]-xls,t[*]+xrs], /xs, yr=[0,2000], /ys, $
			ytit='Velocity (km s!U-1!N)',pos=[0.15,0.42,0.95,0.70], /nolabel, xtickname=[' ',' ',' ',' ',' ',' ',' ']
		utplot, t_now, h_now, utbasedata, /nodata, xr=[t[0]-xls,t[*]+xrs], /xs, yr=[-300,300], /ys, $
			ytit='Accel. (m s!U-2!N)', pos=[0.15,0.14,0.95,0.42]
	endelse
	flag1 = 0
	mov[*,*,mov_count] = tvrd()
	mov_count += 1
	big_count += count+1	
	if big_count eq n_elements(new_image_no) then flag=1
;	pause
endwhile

mov = mov[*,*,0:mov_count-1]
xmovie, mov
;stop


end
