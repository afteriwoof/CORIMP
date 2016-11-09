; Created	06-04-11	from combine_pa_heights2.pro to overplot the kinematics as if combining them to compare all pos_angles.

; Last edited


pro combine_pa_heights3, in, heights, image_no, pos_angles, new_heights, new_image_no, new_pos_angles, remove_endpoints=remove_endpoints

set_line_color

!p.charsize=3.5
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

save, heights, v, a, time, f='kins.sav'

infvar = 3./0.
infs = where(v eq infvar)
if infs ne [-1] then begin
	print, 'Removing Inf values and replacing with maximums.'
	tempv = v
	remove, infs, tempv
	v[infs] = max(tempv)
endif
plot_hist,v,x,y,bin=0.1
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
mov = fltarr(xs,ys,n_elements(new_pos_angles))
mov_count = 0
!p.multi=[0,1,3]
xls = 0.21e5
xrs = 0.2e4

; First plot the heights at all position angles
utplot, t, (heights_km/1000.), utbasedata, psym=1, color=3, ytit='Height (Mm)', pos=[0.15,0.70,0.95,0.98], $
	xr=[t[0]-xls,t[*]+xrs], /xs, /nolabel , xtickname=[' ',' ',' ',' ',' ',' ',' ']
outplot, new_t, new_heights/1000., psym=1, color=1
; Then plot the velocities, which needs looping over each position angle.
flag = 0
flag1 = 0
flag_init = 0
big_count = 0
while flag eq 0 do begin
	count = 0
	h_now = new_heights[big_count+count];the current height
	t_now = new_t[big_count+count]; the current time
	while new_image_no[big_count+count+1] gt new_image_no[big_count+count] do begin
		count += 1
		h_now = [h_now, new_heights[big_count+count]]
		t_now = [t_now, new_t[big_count+count]]
		if n_elements(h_now) gt 2 then begin
			v_now = deriv((anytim(t_now)-anytim(t_now[0])), h_now)
			if flag_init eq 0 then utplot, t_now, v_now, utbasedata, psym=1, ytit='Velocity (km s!U-1!N)', $
				xr=[t[0]-xls,t[*]+xrs], /xs, yr=[0,1000], /ys, pos=[0.15,0.42,0.95,0.70], /nolabel, xtickname=[' ',' ',' ',' ',' ',' ',' '] else $
				outplot, t_now, v_now, utbasedata, psym=1
			flag_init = 1
		endif
	endwhile
	big_count += count+1
	if big_count+count+1 ge n_elements(new_image_no) then flag=1

endwhile

; Then plot the accelerations, which needs looping over each position angle.
flag = 0
flag1 = 0
flag_init = 0
big_count = 0
while flag eq 0 do begin
        count = 0
        h_now = new_heights[big_count+count];the current height
        t_now = new_t[big_count+count]; the current time
        while new_image_no[big_count+count+1] gt new_image_no[big_count+count] do begin
                count += 1 
                h_now = [h_now, new_heights[big_count+count]]
                t_now = [t_now, new_t[big_count+count]]
                if n_elements(h_now) gt 2 then begin
                        v_now = deriv((anytim(t_now)-anytim(t_now[0])), h_now)
                        a_now = deriv((anytim(t_now)-anytim(t_now[0])), v_now)
			if flag_init eq 0 then utplot, t_now, a_now*1000., utbasedata, psym=1, ytit='Accel. (m s!U-2!N)', $
                                xr=[t[0]-xls,t[*]+xrs], /xs, yr=[-400,400], /ys, pos=[0.15,0.14,0.95,0.42] $
				else outplot, t_now, a_now*1000., utbasedata, psym=1
                        flag_init = 1
                endif
        endwhile
        big_count += count+1
        if big_count+count+1 ge n_elements(new_image_no) then flag=1

endwhile


end
