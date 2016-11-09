; Created:	20111117	to go through the saved cme_kin_prof_N_N.sav files output from find_pa_heights_masked.pro and inspecting their centres-of-gravity, along with the count_kin_profs_N.sav, to group the profiles as being part of the same CME.

;INPUTS		-fls			the list of cme_kin_prof_N_N.sav files
;		-count_kin_profs	the file count_kin_profs_N.sav depending on which one is being studied.
;		-out_dir		the output directory to save to.

;OUTPUTS	-fail			a binary (from clustering.pro) to indicate if the points cannot be satisfactorily clustered.


pro group_cme_kins, fls, ave_xs, ave_ys, slopes, pos_angs, fail, cme_count=cme_count, out_dir=out_dir ; count_kin_profs

fail = 0 ;initialise

sz = n_elements(fls)

ave_xs = dblarr(sz)
ave_ys = dblarr(sz)
slopes = dblarr(sz)
pos_angs = dblarr(sz)

set_line_color

for i=0,sz-1 do begin

	filename = file_basename(fls[i])
	pos_angs[i] = strmid(filename,19,3)
	
	restore,fls[i]
	; calculate the centre-of-gravity of the points
        ave_xs[i] = ave(definite_x)
        ave_ys[i] = ave(definite_y)

	;cog[i] = sqrt(ave_xs[i]^2.+ave_ys[i]^2.)
	
	if n_elements(uniq(definite_x)) gt 1 then begin
		yf = 'p[0]*x + p[1]'
		f = mpfitexpr(yf, definite_x, definite_y, /quiet)
		model = f[0]*definite_x + f[1]

		slopes[i] = (model[n_elements(model)-1]-model[0])/(definite_x[n_elements(definite_x)-1]-definite_x[0])
		;print, 'Slope: ', slopes[i]

		plot, definite_x, definite_y, psym=2, xr=[0,415],/xs,yr=[0,2e4],/ys
		oplot, definite_x, model, psym=-3, color=3
	endif

	;wait, 0.1
	;pause

endfor


; Trying to cluster the points.

nonzeros = where(slopes ne 0)
near_zeros = where(abs(slopes)-20 gt 0)
help, nonzeros, near_zeros
;pause
;adx = ave_xs[nonzeros]
;slp = slopes[nonzeros]
if near_zeros ne [-1] then begin
	print, 'Removing the slopes within 20 of zero.'
	ave_xs = ave_xs[near_zeros]
	slopes = slopes[near_zeros]
	; plotting the slopes against the average x-positions (without the zeros).
	;loadct, 39
	;plot, data[0,*], data[1,*], psym=1, /isotropic, /nodata
	;for i=min(pos_angs),max(pos_angs) do begin
	;	pos_ind = where(abs(pos_angs-i) lt 0.5, cnt)
	;	if cnt gt 0 then oplot, data[0,pos_ind], data[1,pos_ind], color=(i-min(pos_angs))*(255/(max(pos_angs)-min(pos_angs))), psym=1
	;endfor
	;pause
endif

data = dblarr(2,n_elements(slopes))
data[0,*] = ave_xs*10.
data[1,*] = slopes

loadct, 0
set_line_color

;clustering, adx,slp, n_clusters=5, /normalise
print, ave_xs, slopes
clustering, ave_xs, slopes, fail, cme_count=cme_count, out_dir=out_dir, n_clusters=5, /normalise;, /group_clusters

;if fail ne 1 then begin
;	distance = distance_measure(data)
;	clusters = cluster_tree(distance, linkdistance, linkage=3, data=data)
;endif
;cluster_plot2, data

end
