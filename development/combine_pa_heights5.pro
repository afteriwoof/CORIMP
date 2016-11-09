; Created	09-09-11	from combine_pa_heights4.pro to show pos_angle info with colorbar.


pro combine_pa_heights5, in, heights, image_no, pos_angles, new_heights, new_image_no, new_pos_angles, gather_t_nows, gather_h_nows, gather_v_nows, gather_a_nows, tog=tog, plot_quartiles=plot_quartiles, plot_median=plot_median, remove_outliers=remove_outliers

pos_angles_init = pos_angles

xls_fac = 60000
xrs_fac = 55000

vel_max_range = 1500
accel_max_range = 600

loadct, 39

if keyword_set(tog) then begin
	toggle, /portrait, /color, f='combine_pa_heights5.ps'
	!p.background=1
	!p.charsize=3.0
	!p.charthick=5
	!p.thick=3
endif

xs=800
ys=1200
;window, xs=xs, ys=ys
t = in[image_no].date_obs
time = anytim(t)
utbasedata = time[0]

km_arc = 6.96e8 / (1000.*in.rsun)
heights_km = fltarr(n_elements(heights))
for i=0,n_elements(heights)-1 do heights_km[i] = heights[i]*km_arc[image_no[i]]

;pos_angles = (pos_angles+180) mod 360

new_image_no = image_no
new_heights = heights_km
new_pos_angles = pos_angles
new_t = t

mov = fltarr(xs,ys,n_elements(new_pos_angles))
mov_count = 0
!p.multi=[0,1,3]
xls = (anytim(time[0]))-utbasedata + xls_fac
xrs = (anytim(time[n_elements(time)-1])) - utbasedata + xrs_fac

; First plot the heights at all position angles
utplot, t, (heights_km/1000.), utbasedata, psym=1, ytit='Height (Mm)', pos=[0.15,0.60,0.95,0.88],yr=[0,1.5e4],/ys, $
	xr=[t[0]-xls,t[*]+xrs], /xs, /nolabel , xtickname=[' ',' ',' ',' ',' ',' ',' '], /nodata;color=3

flag_init = 0
for i=min(pos_angles),max(pos_angles) do begin
	pos_ind = where(abs(pos_angles-i) lt 0.5, cnt) ;finding the locations of just these pos_angles (since all others will differ by 1 and greater).
	if cnt gt 0 then begin
		outplot, new_t[pos_ind], new_heights[pos_ind]/1000.,$
			color=(i-min(pos_angles)) * (255./(max(pos_angles)-min(pos_angles))), psym=1
		t_now = new_t[pos_ind]
		h_now = new_heights[pos_ind]
		if n_elements(t_now) ge 3 then begin
			v_now = deriv(anytim(t_now)-anytim(t_now[0]),h_now)
			a_now = deriv(anytim(t_now)-anytim(t_now[0]),v_now)
			if flag_init eq 1 then begin
				v_all = [v_all, v_now]
				a_all = [a_all, a_now]
				t_all = [t_all, t_now]
				kins_counter = [kins_counter,n_elements(pos_ind)]
				kins_color = [kins_color, (i-min(pos_angles)) * (255./(max(pos_angles)-min(pos_angles)))]
			endif else begin
				v_all = v_now
				a_all = a_now
				t_all = t_now
				kins_counter = n_elements(pos_ind)
				kins_color = (i-min(pos_angles)) * (255./(max(pos_angles)-min(pos_angles)))
				flag_init = 1
			endelse
		endif
	endif
endfor

if keyword_set(model) then begin
        horline, 2.25*695.5, linestyle=1
        horline, 5.75*695.5, linestyle=1
        horline, 6*695.5, linestyle=1
        horline, 16*695.5, linestyle=1
endif else begin
        horline, 2.25*695.5, linestyle=1
        horline, 5.95*695.5, linestyle=1
        ;horline, 6*695.5, linestyle=1
        horline, 19.5*695.5, linestyle=1
endelse

if keyword_set(tog) then colorbar, minra=min(pos_angles),maxra=max(pos_angles),ncol=255,pos=[0.4,0.93,0.7,0.96],$
	tit='Position Angle (deg.)', charsize=2

; Plot the velocity corresponding to the heights at each position angle
utplot, t_all[0:kins_counter[0]-1], v_all[0:kins_counter[0]-1], utbasedata, psym=1, ytit='Velocity (km s!U-1!N)', $
	xr=[t[0]-xls,t[n_elements(t)-1]+xrs], /xs, yr=[0,vel_max_range], /ys, pos=[.15,0.32,0.95,0.60], /nolabel, $
	xtickname=[' ',' ',' ',' ',' ',' ',' '];, color=kins_color[0]

last_t = kins_counter[0]+(kins_counter[1]-1)

for i=1,n_elements(kins_counter)-1 do begin
	outplot, t_all[(last_t+1):(last_t+1)+(kins_counter[i]-1)], v_all[(last_t+1):(last_t+1)+(kins_counter[i]-1)],psym=1,$
		color=kins_color[i]
	last_t += (kins_counter[i]-1)
endfor

; Plot the acceleration corresponding to the heights at each position angle
utplot, t_all[0:kins_counter[0]-1], a_all[0:kins_counter[0]-1]*1000., utbasedata, psym=1, ytit='Accel. (m s!U-2!N)', $
        xr=[t[0]-xls,t[n_elements(t)-1]+xrs], /xs, yr=[-accel_max_range,accel_max_range], /ys, pos=[0.15,0.04,0.95,0.32]; ,color=kins_color[0]
last_t = kins_counter[0]+(kins_counter[1]-1)
for i=1,n_elements(kins_counter)-1 do begin
        outplot, t_all[(last_t+1):(last_t+1)+(kins_counter[i]-1)], a_all[(last_t+1):(last_t+1)+(kins_counter[i]-1)]*1000.,psym=1,$
                color=kins_color[i]
        last_t += (kins_counter[i]-1)
endfor
horline, 0, linestyle=2

if keyword_set(tog) then toggle

pos_angles = pos_angles_init

end
