; Created	30-03-11	to combine the heights along separate position angles for a CME detection

; Last edited	01-04-11	to count up the outliers


pro combine_pa_heights, in, heights, image_no, new_heights, new_image_no

t = in[image_no].date_obs
time = anytim(t)

v = fltarr(n_elements(image_no)-1)

a = fltarr(n_elements(image_no)-2)

for i=0,n_elements(image_no)-2 do begin
	if image_no[i+1] gt image_no[i] then v[i] = (heights[i+1]-heights[i])/(time[i+1]-time[i])
endfor

for i=0,n_elements(image_no)-3 do begin
	if v[i+1] gt v[i] && v[i] ne 0 && v[i+1] ne 0 then a[i] = (v[i+1]-v[i])/(time[i+1]-time[i])
endfor

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
pause
inds1 = where(v gt x_cutoff1[0])
inds2 = where(v lt x_cutoff2[0])

all_inds = [inds1,inds1+1,inds2,inds2+1]

temp = 0
i_init = 0
while temp eq 0 do begin
	ind = where(all_inds eq all_inds[i_init])
	if n_elements(ind) gt 1 then begin
		outliers = all_inds[i_init]
		temp = 1
	endif
	i_init += 1
endwhile	

for i=i_init,n_elements(all_inds)-1 do begin
	ind = where(all_inds eq all_inds[i])
	if n_elements(ind) gt 1 then outliers = [outliers, all_inds[i]]
endfor	

plot, image_no, heights, psym=1
plots, image_no[outliers], heights[outliers], psym=6, color=3

;*** Efforts below don't seem to work!
help,outliers
new_image_no = fltarr(n_elements(image_no)-n_elements(outliers))
new_heights = fltarr(n_elements(image_no)-n_elements(outliers))
count = 0
for i=0,(n_elements(image_no)-n_elements(outliers))-1 do begin
	if where(heights[i] eq heights[outliers]) eq [-1] then begin
		new_image_no[count] = image_no[i]
		new_heights[count] = heights[i]
		count += 1
	endif
endfor
;*************************************


end
