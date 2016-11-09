; Created:	20111117	to go through the saved cme_kin_prof_N_N.sav files output from find_pa_heights_masked.pro and inspecting their centres-of-gravity, along with the count_kin_profs_N.sav, to group the profiles as being part of the same CME.

;INPUTS		-fls			the list of cme_kin_prof_N_N.sav files
;		-count_kin_profs	the file count_kin_profs_N.sav depending on which one is being studied.


pro group_cme_kins, fls, ave_def_xs, ave_def_ys, slopes ; count_kin_profs

sz = n_elements(fls)

ave_def_xs = dblarr(sz)
ave_def_ys = dblarr(sz)
slopes = dblarr(sz)

set_line_color

for i=0,sz-1 do begin
	restore,fls[i]
	; calculate the centre-of-gravity of the points
        ave_def_xs[i] = ave(definite_x)
        ave_def_ys[i] = ave(definite_y)

	;cog[i] = sqrt(ave_def_xs[i]^2.+ave_def_ys[i]^2.)
	
	if n_elements(uniq(definite_x)) gt 1 then begin
		yf = 'p[0]*x + p[1]'
		f = mpfitexpr(yf, definite_x, definite_y, /quiet)
		model = f[0]*definite_x + f[1]

		slopes[i] = (model[n_elements(model)-1]-model[0])/(definite_x[n_elements(definite_x)-1]-definite_x[0])
		;print, 'Slope: ', slopes[i]

		plot, definite_x, definite_y, psym=2, xr=[0,415],/xs,yr=[0,2e4],/ys
		oplot, definite_x, model, psym=-3, color=3
	endif


;	pause

endfor


; Trying to cluster the points.

nonzeros = where(slopes ne 0)
adx = ave_def_xs[nonzeros]
slp = slopes[nonzeros]
data = dblarr(2,n_elements(slp))
data[0,*] = adx
data[1,*] = slp
; plotting the slopes against the average x-positions (without the zeros).
plot, data[0,*], data[1,*], psym=1

distance = distance_measure(data)
clusters = cluster_tree(distance, linkdistance)
help, data, distance, clusters

for i=0,n_elements(clusters[0,*])-1 do begin
	print, 'i ', i, ' of ', n_elements(clusters[0,*])-1
	; if the number assigned to this cluster is less than the data, then it's just a two-point-paired-cluster.
	if clusters[0,i] lt n_elements(data[0,*]) AND clusters[1,i] lt n_elements(data[1,*]) then begin
		plots, data[0,clusters[0,i]], data[1,clusters[0,i]], psym=1, color=(i mod 7)+2, thick=3, symsize=2
		pause
		plots, data[0,clusters[1,i]], data[1,clusters[1,i]], psym=1, color=(i mod 7)+2, thick=3, symsize=2
		pause
	endif else begin
		test = clusters[0,i]
		count_test = 0
		while test lt n_elements(data[0,*]) do begin
			count_test += 1
			test = clusters[0,test mod n_elements(data[0,*])]

		; STUFF UNFINISHED HERE
		endwhile
	endelse
endfor


end
