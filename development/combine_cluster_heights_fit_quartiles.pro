; Created	2012-08-10	from combine_pa_heights6_fit_quartiles.pro to take in the output as in Log_clustering.rtf



pro combine_cluster_heights_fit_quartiles, datetimes, def_xs, def_ys, pos_angles, new_heights, new_def_xs, new_pos_angles, gather_t_nows, gather_h_nows, gather_v_nows, gather_a_nows, tog=tog, plot_quartiles=plot_quartiles, plot_median=plot_median, remove_outliers=remove_outliers, saves=saves, model=model

pos_angles_init = pos_angles

xls_fac = 28000
xrs_fac = 4500

vel_max_range = 1100
accel_max_range = 299

loadct, 39

if keyword_set(tog) then begin
	toggle, /portrait, /color, f='combine_cluster_heights_fit_quartiles.ps'
	!p.background=1
	!p.charsize=3.0
	!p.charthick=5
	!p.thick=3
endif

xs=800
ys=1200
;window, xs=xs, ys=ys
time = anytim(datetimes)
utbasedata = time[0]

;km_arc = 6.955e8 / (1000.*in.rsun)
km_arc = 6.955e8 / (1000.*983)  ; where in.rsun should be specified individually, this is just an avereage.
heights_km = fltarr(n_elements(def_ys))
;for i=0,n_elements(def_ys)-1 do heights_km[i] = def_ys[i]*km_arc[image_no[i]]
for i=0L,n_elements(def_ys)-1 do heights_km[i] = def_ys[i]*km_arc

pos_angles = (pos_angles+180) mod 360

v = fltarr(n_elements(def_ys)-1)

a = fltarr(n_elements(def_ys)-2)

for i=0L,n_elements(def_ys)-2 do begin
	if def_xs[i+1] gt def_xs[i] then v[i] = (def_ys[i+1]-def_ys[i])/(time[i+1]-time[i])
endfor

for i=0,n_elements(image_no)-3 do begin
	if v[i+1] gt v[i] && v[i] ne 0 && v[i+1] ne 0 then a[i] = (v[i+1]-v[i])/(time[i+1]-time[i])
endfor

print, 'Saving kins.sav'
save, def_ys, v, a, time, f='kins.sav'

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
	new_def_xs = def_xs[all_inds]
	new_heights = heights_km[all_inds]
	new_pos_angles = pos_angles[all_inds]
	new_time = time[all_inds]
endif else begin
	new_def_xs = def_xs
	new_heights = heights_km
	new_pos_angles = pos_angles
	new_time = time
endelse

;***

; Include interquartile ranges

gather_t_nows = '0'
gather_h_nows = 0
flag = 0
flag1 = 0
flag_init = 0
big_count = 0.
while flag eq 0 do begin
	count = 0
	h_now = new_heights[big_count+count];the current height
	time_now = new_time[big_count+count]; the current time
	while new_def_xs[big_count+count+1] gt new_def_xs[big_count+count] do begin
		if (big_count+count+2) lt n_elements(new_def_xs) then count += 1 else goto, jump1
		h_now = [h_now, new_heights[big_count+count]]
		time_now = [time_now, new_time[big_count+count]]
		gather_h_nows = [gather_h_nows, h_now]
		gather_t_nows = [gather_t_nows, time_now]
	endwhile
	big_count += count+1
	if big_count+count+1 ge n_elements(new_def_xs) then flag=1
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

;***


pos_angles = new_pos_angles

if keyword_set(saves) then begin
	print, 'new_heights_info.sav'
	save, new_heights, time, heights_km, utbasedata, new_time, f='new_heights_info.sav'
endif

mov = fltarr(xs,ys,n_elements(new_pos_angles))
mov_count = 0
!p.multi=[0,1,3]
xls = (anytim(time[0]))-utbasedata + xls_fac
xrs = (anytim(time[n_elements(time)-1])) - utbasedata + xrs_fac

; First plot the heights at all position angles
utplot, time, (heights_km/1000.), utbasedata, psym=1, ytit='Height (Mm)', pos=[0.15,0.60,0.95,0.88],yr=[0,1.3e4],/ys, $
	xr=[time[0]-xls,time[*]+xrs], /xs, /nolabel , xtickname=[' ',' ',' ',' ',' ',' ',' '], /nodata;color=3

flag_init = 0
never_v_fwd = 0
flag_v_fit = 0

for i=min(pos_angles),max(pos_angles) do begin
	pos_ind = where(abs(pos_angles-i) lt 0.5, cnt) ;finding the locations of just these pos_angles (since all others will differ by 1 and greater).
	if cnt gt 0 then begin
		outplot, new_time[pos_ind], new_heights[pos_ind]/1000.,$
			color=(i-min(pos_angles)) * (255./(max(pos_angles)-min(pos_angles))), psym=1
		t_now = new_time[pos_ind]
		h_now = new_heights[pos_ind]
		print, 'First h_now: ', h_now[0]/1000.
		print, 'Last h_now: ', h_now[n_elements(h_now)-1]/1000.
		print, 'First t_now: ', t_now[0]
		print, 'Last t_now: ', t_now[n_elements(t_now)-1]
		print, 'height gap ', h_now[n_elements(h_now)-1]-h_now[0]
		print, 'time gap ', anytim(t_now[n_elements(t_now)-1])-anytim(t_now[0])
		v_fwd = (h_now[n_elements(h_now)-1]-h_now[0])/(anytim(t_now[n_elements(t_now)-1])-anytim(t_now[0]))
		print, 'v_fwd: ', v_fwd
		; loop through for every v_fwd
		if never_v_fwd eq 0 then begin
			temp = fltarr(n_elements(h_now)-1)
			for count_fwd=0,n_elements(h_now)-2 do begin	
				temp[count_fwd] = (h_now[count_fwd+1]-h_now[count_fwd])/(anytim(t_now[count_fwd+1])-anytim(t_now[count_fwd]))
			endfor
			v_fwd_all = temp
			never_v_fwd = 1
		endif else begin
			temp = fltarr(n_elements(h_now)-1)
			for count_fwd=0,n_elements(h_now)-2 do begin
				temp[count_fwd] = (h_now[count_fwd+1]-h_now[count_fwd])/(anytim(t_now[count_fwd+1])-anytim(t_now[count_fwd]))
			endfor
			v_fwd_all = [v_fwd_all, temp]
		endelse

		if n_elements(t_now) ge 3 then begin
			v_now = deriv(anytim(t_now)-anytim(t_now[0]),h_now)
			print, 'v_now ', v_now
			a_now = deriv(anytim(t_now)-anytim(t_now[0]),v_now)
			if flag_init eq 1 then begin
				v_fwds = [v_fwds, v_fwd]
				v_all = [v_all, v_now]
				v_all_angles = [v_all_angles, replicate(i,n_elements(v_now))]
				a_all = [a_all, a_now]
				t_all = [t_all, t_now]
				kins_counter = [kins_counter,n_elements(pos_ind)]
				kins_color = [kins_color, (i-min(pos_angles)) * (255./(max(pos_angles)-min(pos_angles)))]
			endif else begin
				v_fwds = v_fwd
				v_all = v_now
				v_all_angles = replicate(i,n_elements(v_now))
				a_all = a_now
				t_all = t_now
				kins_counter = n_elements(pos_ind)
				kins_color = (i-min(pos_angles)) * (255./(max(pos_angles)-min(pos_angles)))
				flag_init = 1
			endelse
		endif
	
		; polynomial fit to the points:
;	        outplot, new_t[pos_ind], new_heights[pos_ind]/1000., psym=2, color=255
;	        pause

;		!p.multi=[0,1,3]
		t_param = (new_time[pos_ind])
		h_param = new_heights[pos_ind] 
		save, t_param, h_param, f='temp.sav'
		t_param = anytim(t_param)
		h_param /= 1000.
;		utplot, t_param, h_param, psym=2, ytit='Height (m)'
		t = t_param - min(t_param)
		yf = 'p[0]*(x^2.) + p[1]*x + p[2]'
		f = mpfitexpr(yf, t, h_param)
		t_coords = make_coordinates(11,minmax(t))
		h_fit = f[0]*(t_coords^2.) + f[1]*t_coords + f[2]
		;v_fit = f[0]*t_coords+f[1]
		v_fit = deriv(t_coords, h_fit)
		if flag_v_fit eq 0 then begin
			v_fit_all = v_fit
			v_fit_angles = replicate(i,n_elements(v_fit))
			flag_v_fit = 1
		endif else begin
			v_fit_all = [v_fit_all, v_fit]
			v_fit_angles = [v_fit_angles, replicate(i,n_elements(v_fit))]
		endelse
;		plot, t_param, h_param, psym=2, ytit='Height (m)'
;		oplot, t_coords+min(t_param), h_fit, psym=-3
		if n_elements(h_param) ge 3 AND where(finite(v) eq 0) ne [-1] then begin
			v = deriv(t, h_param)
			print, v, t_param	
;			plot, t_param, v*1000., psym=2, ytit='Vel. (km/s)'
;			oplot, t_coords+min(t_param), v_fit*1000., psym=-3
		endif
		;pause
		
	endif

endfor

;***
if keyword_set(plot_quartiles) then begin
	set_line_color
	if keyword_set(tog) then c=0 else c=1
	outplot, t_bins, h_meds/1000., utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, h_q1s/1000., utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, h_q3s/1000., utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, lowerfence/1000., utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, upperfence/1000., utbasedata, psym=-3, thick=1, color=c, line=0
endif
;***

if keyword_set(model) then begin
        horline, 2.25*700., linestyle=1
        horline, 5.75*700., linestyle=1
        horline, 6*700., linestyle=1
        horline, 16*700., linestyle=1
endif else begin
        horline, 2.25*700., linestyle=1
        horline, 5.95*700., linestyle=1
        ;horline, 6*700., linestyle=1
        ;horline, 19.5*700., linestyle=1
endelse

if keyword_set(tog) then begin
	loadct, 39
	colorbar, minra=min(pos_angles),maxra=max(pos_angles),ncol=255,pos=[0.4,0.93,0.7,0.95],$
	tit='Position Angle (deg.)', charsize=2
endif

; Plot the velocity corresponding to the heights at each position angle
utplot, t_all[0:kins_counter[0]-1], v_all[0:kins_counter[0]-1], utbasedata, psym=1, ytit='Velocity (km s!U-1!N)', $
	xr=[t[0]-xls,t[n_elements(t)-1]+xrs], /xs, yr=[0,vel_max_range], /ys, pos=[.15,0.32,0.95,0.60], /nolabel, $
	xtickname=[' ',' ',' ',' ',' ',' ',' '];, color=kins_color[0]

if n_elements(kins_counter) gt 1 then last_t = kins_counter[0]+(kins_counter[1]-1) else last_t = kins_counter

for i=1,n_elements(kins_counter)-1 do begin
	outplot, t_all[(last_t+1):(last_t+1)+(kins_counter[i]-1)], v_all[(last_t+1):(last_t+1)+(kins_counter[i]-1)],psym=1,$
		color=kins_color[i]
	last_t += (kins_counter[i]-1)
endfor

;***
; interquartiles
gather_t_nows = '0'
gather_v_nows = 0
flag = 0
flag1 = 0
flag_init = 0
big_count = 0.
while flag eq 0 do begin
	count = 0
	h_now = new_heights[big_count+count];the current height
	t_now = new_time[big_count+count]; the current time
	while new_def_xs[big_count+count+1] gt new_def_xs[big_count+count] do begin
		if (big_count+count+2) lt n_elements(new_def_xs) then count += 1 else goto, jump2
		h_now = [h_now, new_heights[big_count+count]]
		t_now = [t_now, new_time[big_count+count]]
		if n_elements(h_now) gt 2 then begin
			v_now = deriv((anytim(t_now)-anytim(t_now[0])), h_now)
			;if flag_init eq 0 then utplot, t_now, v_now, utbasedata, psym=1, ytit='Velocity (km s!U-1!N)', $
			;	xr=[t[0]-xls,t[*]+xrs], /xs, yr=[0,1000], /ys, pos=[0.15,0.42,0.95,0.70], /nolabel, $
			;	xtickname=[' ',' ',' ',' ',' ',' ',' '], color=char_color $
			;	else outplot, t_now, v_now, utbasedata, psym=1, color=char_color
			gather_t_nows = [gather_t_nows, t_now]
			gather_v_nows = [gather_v_nows, v_now]
			flag_init = 1
		endif
	endwhile
	big_count += count+1
	if big_count+count+1 ge n_elements(new_def_xs) then flag=1
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
	outplot, t_bins, v_meds, utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, v_q1s, utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, v_q3s, utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, lowerfence, utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, upperfence, utbasedata, psym=-3, thick=1, color=c, line=0
endif


;***


; Plot the acceleration corresponding to the heights at each position angle
utplot, t_all[0:kins_counter[0]-1], a_all[0:kins_counter[0]-1]*1000., utbasedata, psym=1, ytit='Accel. (m s!U-2!N)', $
        xr=[t[0]-xls,t[n_elements(t)-1]+xrs], /xs, yr=[-accel_max_range,accel_max_range], /ys, pos=[0.15,0.04,0.95,0.32]; ,color=kins_color[0]
if n_elements(last_t) gt 1 then last_t = kins_counter[0]+(kins_counter[1]-1) else last_t = kins_counter

for i=1,n_elements(kins_counter)-1 do begin
        outplot, t_all[(last_t+1):(last_t+1)+(kins_counter[i]-1)], a_all[(last_t+1):(last_t+1)+(kins_counter[i]-1)]*1000.,psym=1,$
                color=kins_color[i]
        last_t += (kins_counter[i]-1)
endfor
horline, 0, linestyle=0, thick=1

;***
; interquartiles
gather_t_nows = '0'
gather_a_nows = 0
flag = 0
flag1 = 0
flag_init = 0
big_count = 0.
while flag eq 0 do begin
        count = 0
        h_now = new_heights[big_count+count];the current height
        t_now = new_time[big_count+count]; the current time
        while new_def_xs[big_count+count+1] gt new_def_xs[big_count+count] do begin
                if (big_count+count+2) lt n_elements(new_def_xs) then count += 1 else goto, jump3
                h_now = [h_now, new_heights[big_count+count]]
                t_now = [t_now, new_time[big_count+count]]
                if n_elements(h_now) gt 2 then begin
                        v_now = deriv((anytim(t_now)-anytim(t_now[0])), h_now)
                        a_now = deriv((anytim(t_now)-anytim(t_now[0])), v_now)
			;if flag_init eq 0 then utplot, t_now, a_now*1000., utbasedata, psym=1, ytit='Accel. (m s!U-2!N)', $
                        ;        xr=[t[0]-xls,t[*]+xrs], /xs, yr=[-500,500], /ys, pos=[0.15,0.14,0.95,0.42], color=char_color $
			;	else outplot, t_now, a_now*1000., utbasedata, psym=1, color=char_color
                        gather_t_nows = [gather_t_nows, t_now]
                        gather_a_nows = [gather_a_nows, a_now*1000.]
			flag_init = 1
                endif
        endwhile
        big_count += count+1
        if big_count+count+1 ge n_elements(new_def_xs) then flag=1
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
	outplot, t_bins, a_meds, utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, a_q1s, utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, a_q3s, utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, lowerfence, utbasedata, psym=-3, thick=1, color=c, line=0
	outplot, t_bins, upperfence, utbasedata, psym=-3, thick=1, color=c, line=0
endif

;***

if keyword_set(tog) then toggle

pos_angles = pos_angles_init

if keyword_set(saves) then begin
	print, 'saving v_fwd_all.sav'
	save, v_fwd_all, f='v_fwd_all.sav'
	print, 'saving v_all.sav'
	save, v_all, f='v_all.sav'
	print, 'Saving v_all_angles.sav'
	save, v_all_angles, f='v_all_angles.sav'
	print, 'saving v_fwds.sav'
	save, v_fwds, f='v_fwds.sav'
	print, 'Saving v_fit_all.sav'
	save, v_fit_all, f='v_fit_all.sav'
	print, 'Saving v_fit_angles.sav'
	save, v_fit_angles, f='v_fit_angles.sav'

endif

end
