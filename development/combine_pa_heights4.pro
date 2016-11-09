; Created	03-06-11	from combine_pa_heights3.pro to take out the median etc on the heights/vels/accels.

; Last edited	06-06-11	fo include keyword tog
;		07-06-11	to include keyword plot_quartiles.
;		29-08-11	to include keyword remove_outliers
;		08-09-11	to include keyword plot_median

pro combine_pa_heights4, in, heights, image_no, pos_angles, new_heights, new_image_no, new_pos_angles, gather_t_nows, gather_h_nows, gather_v_nows, gather_a_nows, tog=tog, plot_quartiles=plot_quartiles, plot_median=plot_median, remove_outliers=remove_outliers

print, '***
print, 'Error in this code output, notably for v_nows.sav, because it counts over the same points more than once giving too high a count.'
print, 'Look to using combine_pa_heights5_check.pro instead.'
print, '***
pause

set_line_color

char_color = 1

if keyword_set(tog) then begin
	toggle, /portrait, /color, f='combine_pa_heights4.ps'
	!p.background=1
	!p.charsize=3.0
	!p.charthick=5
	!p.thick=3
	char_color=0
endif

xs=800
ys=1200
;window, xs=xs, ys=ys
t = in[image_no].date_obs
time = anytim(t)
utbasedata = time[0]

km_arc = 6.955e8 / (1000.*in.rsun)
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

print, 'Saving kins.sav'
save, heights, v, a, time, f='kins.sav'

infvar = 3./0.
infs = where(v eq infvar)
if infs ne [-1] then begin
	print, 'Removing Inf values and replacing with maximums.'
	tempv = v
	remove, infs, tempv
	v[infs] = max(tempv)
endif

if keyword_set(remove_outliers) then begin
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

	inds = where(v le x_cutoff1[0] AND v ge x_cutoff2[0])
	
	all_inds = [inds, inds+1]
	delvarx, inds
	all_inds = all_inds[uniq(all_inds,sort(all_inds))]
	new_image_no = image_no[all_inds]
	new_heights = heights_km[all_inds]
	new_pos_angles = pos_angles[all_inds]
	new_t = t[all_inds]
endif else begin
	new_image_no = image_no
	new_heights = heights_km
	new_pos_angles = pos_angles
	new_t = t
endelse
;plot,image_no,heights,psym=1, xtit='Image No.', ytit='Height (arcsec)'
;plots, image_no[all_inds], heights[all_inds], psym=6, color=3
mov = fltarr(xs,ys,n_elements(new_pos_angles))
mov_count = 0
!p.multi=[0,1,3]
xls = (anytim(time[0]))-utbasedata+35000
xrs = (anytim(time[n_elements(time)-1]))-utbasedata+10000

; First plot the heights at all position angles
if keyword_set(remove_outliers) then print,'plotting outliers in red'
utplot, t, (heights_km/1000.), utbasedata, psym=1, ytit='Height (Mm)', pos=[0.15,0.70,0.95,0.98], $
	xr=[t[0]-xls,t[*]+xrs], /xs, /nolabel , xtickname=[' ',' ',' ',' ',' ',' ',' '], color=3
outplot, new_t, new_heights/1000., psym=1, color=char_color

;saving out info for plotting in figure_model_histograms
print, 'Saving heights.sav'
save, time, t, heights_km, utbasedata, new_t, new_heights, f='heights.sav'

; plot line to mark occulter edges/crossover 5.75-6 Rsun
if keyword_set(model) then begin
	horline, 2.25*700., linestyle=1
	horline, 5.75*700., linestyle=1
	horline, 6*700., linestyle=1
	horline, 16*700., linestyle=1
endif else begin
	horline, 2.25*700., linestyle=1
	horline, 5.95*700., linestyle=1
	;horline, 6*700., linestyle=1
	horline, 19.5*700., linestyle=1
endelse


gather_t_nows = '0'
gather_h_nows = 0
flag = 0
flag1 = 0
flag_init = 0
big_count = 0
while flag eq 0 do begin
	count = 0
	h_now = new_heights[big_count+count];the current height
	t_now = new_t[big_count+count]; the current time
	while new_image_no[big_count+count+1] gt new_image_no[big_count+count] do begin
		if (big_count+count+2) lt n_elements(new_image_no) then count += 1 else goto, jump1
		h_now = [h_now, new_heights[big_count+count]]
		t_now = [t_now, new_t[big_count+count]]
		gather_h_nows = [gather_h_nows, h_now]
		gather_t_nows = [gather_t_nows, t_now]
	endwhile
	big_count += count+1
	if big_count+count+1 ge n_elements(new_image_no) then flag=1
endwhile
jump1:
t_nows = gather_t_nows[1:*]
h_nows = gather_h_nows[1:*]
t_bins = t_nows[uniq(t_nows,sort(t_nows))]
h_right_now = h_nows[where(t_nows eq t_bins[0])]
h_meds = median(h_right_now)
h_q1s = median(h_right_now[where(h_right_now ge h_meds)]);upper quartile
h_q3s = median(h_right_now[where(h_right_now le h_meds)]);lower quartile
h_iqr = h_q1s - h_q3s ;interquartile range
lowerfence = h_q1s - 1.5*h_iqr
upperfence = h_q3s + 1.5*h_iqr
for i=1,n_elements(t_bins)-1 do begin
	h_right_nows = h_nows[where(t_nows eq t_bins[i])]
	h_meds = [h_meds,median(h_right_nows)]
	h_q1s = [h_q1s,median(h_right_nows[where(h_right_nows ge h_meds[i])])]
	h_q3s = [h_q3s,median(h_right_nows[where(h_right_nows le h_meds[i])])]
	h_iqr = h_q1s[i] - h_q3s[i]
	lowerfence = [lowerfence, h_q1s[i] - 1.5*h_iqr]
	upperfence = [upperfence, h_q3s[i] + 1.5*h_iqr]
endfor
if keyword_set(plot_quartiles) then begin
	outplot, t_bins, h_meds/1000., utbasedata, psym=-3, thick=3, color=3
	outplot, t_bins, h_q1s/1000., utbasedata, psym=-3, thick=3, color=4
	outplot, t_bins, h_q3s/1000., utbasedata, psym=-3, thick=3, color=2
	outplot, t_bins, lowerfence/1000., utbasedata, psym=-3, thick=2, color=5
	outplot, t_bins, upperfence/1000., utbasedata, psym=-3, thick=2, color=6
endif else begin
	if keyword_set(plot_median) then outplot, t_bins, h_meds/1000., utbasedata, psym=-3, thick=3, color=3
endelse

; Then plot the velocities, which needs looping over each position angle.
gather_t_nows = '0'
gather_v_nows = 0
flag = 0
flag1 = 0
flag_init = 0
big_count = 0
while flag eq 0 do begin
	count = 0
	h_now = new_heights[big_count+count];the current height
	t_now = new_t[big_count+count]; the current time
	while new_image_no[big_count+count+1] gt new_image_no[big_count+count] do begin
		if (big_count+count+2) lt n_elements(new_image_no) then count += 1 else goto, jump2
		h_now = [h_now, new_heights[big_count+count]]
		t_now = [t_now, new_t[big_count+count]]
		if n_elements(h_now) gt 2 then begin
			v_now = deriv((anytim(t_now)-anytim(t_now[0])), h_now)
			if flag_init eq 0 then utplot, t_now, v_now, utbasedata, psym=1, ytit='Velocity (km s!U-1!N)', $
				xr=[t[0]-xls,t[*]+xrs], /xs, yr=[0,1000], /ys, pos=[0.15,0.42,0.95,0.70], /nolabel, $
				xtickname=[' ',' ',' ',' ',' ',' ',' '], color=char_color $
				else outplot, t_now, v_now, utbasedata, psym=1, color=char_color
			gather_t_nows = [gather_t_nows, t_now]
			gather_v_nows = [gather_v_nows, v_now]
			flag_init = 1
		endif
	endwhile
	big_count += count+1
	if big_count+count+1 ge n_elements(new_image_no) then flag=1
endwhile
jump2:
t_nows = gather_t_nows[1:*]
v_nows = gather_v_nows[1:*]
print, 'Saving v_nows.sav'
save, v_nows, f='v_nows.sav'
t_bins = t_nows[uniq(t_nows,sort(t_nows))]
v_right_now = v_nows[where(t_nows eq t_bins[0])]
v_meds = median(v_right_now)
v_q1s = median(v_right_now[where(v_right_now ge v_meds)]);upper quartile
v_q3s = median(v_right_now[where(v_right_now le v_meds)]);lower quartile
v_iqr = v_q1s - v_q3s ;interquartile range
lowerfence = v_q1s - 1.5*v_iqr
upperfence = v_q3s + 1.5*v_iqr
for i=1,n_elements(t_bins)-1 do begin
	v_right_nows = v_nows[where(t_nows eq t_bins[i])]
	v_meds = [v_meds, median(v_right_nows)]
	v_q1s = [v_q1s,median(v_right_nows[where(v_right_nows ge v_meds[i])])]
	v_q3s = [v_q3s,median(v_right_nows[where(v_right_nows le v_meds[i])])]
	v_iqr = v_q1s[i] - v_q3s[i]
        lowerfence = [lowerfence, v_q1s[i] - 1.5*v_iqr]
        upperfence = [upperfence, v_q3s[i] + 1.5*v_iqr]
endfor
if keyword_set(plot_quartiles) then begin
	outplot, t_bins, v_meds, utbasedata, psym=-3, thick=3, color=3
	outplot, t_bins, v_q1s, utbasedata, psym=-3, thick=3, color=4
	outplot, t_bins, v_q3s, utbasedata, psym=-3, thick=3, color=2
	outplot, t_bins, lowerfence, utbasedata, psym=-3, thick=2, color=5
	outplot, t_bins, upperfence, utbasedata, psym=-3, thick=2, color=6
endif else begin
	if keyword_set(plot_median) then outplot, t_bins, v_meds, utbasedata, psym=-3, thick=3, color=3
endelse

; Then plot the accelerations, which needs looping over each position angle.
gather_t_nows = '0'
gather_a_nows = 0
flag = 0
flag1 = 0
flag_init = 0
big_count = 0
while flag eq 0 do begin
        count = 0
        h_now = new_heights[big_count+count];the current height
        t_now = new_t[big_count+count]; the current time
        while new_image_no[big_count+count+1] gt new_image_no[big_count+count] do begin
                if (big_count+count+2) lt n_elements(new_image_no) then count += 1 else goto, jump3
                h_now = [h_now, new_heights[big_count+count]]
                t_now = [t_now, new_t[big_count+count]]
                if n_elements(h_now) gt 2 then begin
                        v_now = deriv((anytim(t_now)-anytim(t_now[0])), h_now)
                        a_now = deriv((anytim(t_now)-anytim(t_now[0])), v_now)
			if flag_init eq 0 then utplot, t_now, a_now*1000., utbasedata, psym=1, ytit='Accel. (m s!U-2!N)', $
                                xr=[t[0]-xls,t[*]+xrs], /xs, yr=[-500,500], /ys, pos=[0.15,0.14,0.95,0.42], color=char_color $
				else outplot, t_now, a_now*1000., utbasedata, psym=1, color=char_color
                        gather_t_nows = [gather_t_nows, t_now]
                        gather_a_nows = [gather_a_nows, a_now*1000.]
			flag_init = 1
                endif
        endwhile
        big_count += count+1
        if big_count+count+1 ge n_elements(new_image_no) then flag=1
endwhile
jump3:
t_nows = gather_t_nows[1:*]
a_nows = gather_a_nows[1:*]
t_bins = t_nows[uniq(t_nows,sort(t_nows))]
a_right_now = a_nows[where(t_nows eq t_bins[0])]
a_meds = median(a_right_now)
a_q1s = median(a_right_now[where(a_right_now ge a_meds)]);upper quartile
a_q3s = median(a_right_now[where(a_right_now le a_meds)]);lower quartile
a_iqr = a_q1s - a_q3s ;interquartile range
lowerfence = a_q1s - 1.5*a_iqr
upperfence = a_q3s + 1.5*a_iqr
for i=1,n_elements(t_bins)-1 do begin
        a_right_nows = a_nows[where(t_nows eq t_bins[i])]
        a_meds = [a_meds, median(a_right_nows)]
        a_q1s = [a_q1s,median(a_right_nows[where(a_right_nows ge a_meds[i])])]
        a_q3s = [a_q3s,median(a_right_nows[where(a_right_nows le a_meds[i])])]
	a_iqr = a_q1s[i] - a_q3s[i]
        lowerfence = [lowerfence, a_q1s[i] - 1.5*a_iqr]
        upperfence = [upperfence, a_q3s[i] + 1.5*a_iqr]
endfor
if keyword_set(plot_quartiles) then begin
	outplot, t_bins, a_meds, utbasedata, psym=-3, thick=3, color=3
	outplot, t_bins, a_q1s, utbasedata, psym=-3, thick=3, color=4
	outplot, t_bins, a_q3s, utbasedata, psym=-3, thick=3, color=2
	outplot, t_bins, lowerfence, utbasedata, psym=-3, thick=2, color=5
	outplot, t_bins, upperfence, utbasedata, psym=-3, thick=2, color=6
endif else begin
	if keyword_set(plot_median) then outplot, t_bins, a_meds, utbasedata, psym=-3, thick=3, color=3
endelse


if keyword_set(tog) then toggle

end
