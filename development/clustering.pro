; Created	20120224	to use the IDL cluster.pro

;Last edited	20120229	to include /normalise keyword
;		2012-07-24	to iterate over the number of clusters, i.e., investigate the span of each cluster and reduce n_clusters if appropriate.
;		2012-08-22	to include keyword /group_clusters

; INPUTS	ix:		first array coords
;		iy:		second array coords (2D clustering)
;		n_clusters:	how many clusters to determine.
;		out_dir		the output directory

; OUTPUTS
;		fail		if the points can't be satisfactorily clustered.

;KEYWORDS	group_clusters	test the span of the cluster and see if they overlap to group them and run again with reduced n_clusters value.


pro clustering, ix, iy, fail, cme_count=cme_count, out_dir=out_dir, n_clusters=n_clusters, normalise=normalise, group_clusters=group_clusters

; Does not work on integers
ix = double(ix)
iy = double(iy)

; Number being entered
input_no = indgen(n_elements(ix))

; Jump here if the n_clusters has been reduced after first run of code.
jump2:

print, 'n_clusters ', n_clusters

if size(ix,/dim) ne size(iy,/dim) then print, 'Array inputs must be of same size.'

zeros = where(ix eq 0 or iy eq 0)
if n_elements(zeros) eq n_elements(ix) then begin
	fail = 1
	goto, jump_end
endif
if zeros ne [-1] then remove, zeros, ix, iy, input_no
sz = size(ix, /dim)
; if there's only one point then it can't be clustered!
if sz lt 3 then begin
	fail = 1
	goto, jump_end
endif

if exist(iz) then array=dblarr(3,sz[0]) else array=dblarr(2,sz[0])

;Normalise the array ranges
if keyword_set(normalise) then begin
	ix = (ix - min(ix))/max(ix-min(ix))
	iy = (iy - min(iy))/max(iy-min(iy))
	if exist(iz) then iz = (iz - min(iz))/max(iz-min(iz))
endif

array[0,*] = ix
array[1,*] = iy
if exist(iz) then array[2,*] = iz

help, array, ix, iy

weights = clust_wts(array, n_clusters=n_clusters)

result = cluster(array, weights, n_clusters=n_clusters)

; PLOT
plot, array[0,*], array[1,*], psym=3, /iso, /nodata
set_line_color
for i=0,n_clusters-1 do begin
	plots,weights[0,i],weights[1,i],psym=2,color=2
	loc = where(result eq i,count)
	if count ne 0 then begin
		temp = array[*,loc]
		plots, temp, psym=(i mod 4)+4, color=(i mod 10)+1
	endif
endfor
pause

; image for testing the circular span of each cluster for overlaps
if keyword_set(group_clusters) then begin
	testim = dblarr(100,100)
	mask = dblarr(100,100)

	; The cluster entries
	;openw, lun, /get_lun, 'cluster_entries.txt'
	;printf, lun, '# n_clusters ' + num2str(n_clusters)
	;free_lun, lun

	cluster_count = 0
	
	plot, array[0,*], array[1,*], psym=3, /iso, /nodata
	for i=0,n_clusters-1 do begin
		print, 'i ', i, ' of ', n_clusters-1
		plots,weights[0,i],weights[1,i],psym=2,color=2
		loc = where(result eq i,count)
	;	openu, lun, 'cluster_entries.txt', /append
	;	printf, lun, '# cluster ' + num2str(i)
	;	printf, lun, loc, ix[loc], iy[loc]
	;	free_lun, lun
		;if count ne 0 then plots,array[*,loc],psym=(i mod 4)+4,color=(i mod 10)+1
		if count ne 0 then begin
			temp = array[*,loc]
			plots, temp, psym=(i mod 4)+4, color=(i mod 10)+1
			if n_elements(loc) eq 2 then print, 'One cluster has only 2 points!'
			cluster_radius = max(sqrt((array[0,loc]-weights[0,i])^2.+(array[1,loc]-weights[1,i])^2.))
			if round(cluster_radius*100) eq 0 then goto, jump1
			draw_circle, weights[0,i], weights[1,i], cluster_radius;, /fill
			theta = indgen(10000L) * 2 * !pi / 10000L
			xx = cluster_radius * sin(theta) + weights[0,i]
			yy = cluster_radius * cos(theta) + weights[1,i]
			for ii=0,99 do begin
				for jj=0,99 do begin
					xoff = abs(ii-weights[0,i]*100)
					yoff = abs(jj-weights[1,i]*100)
					mask[ii,jj] = sqrt(xoff^2. + yoff^2.)
				endfor
			endfor
			mask /= max(mask)
			new_mask = mask
			if where(mask lt cluster_radius) ne [-1] then new_mask[where(mask lt cluster_radius)] = 1
			if where(mask ge cluster_radius) ne [-1] then new_mask[where(mask ge cluster_radius)] = 0
			testim += new_mask
			pause
		endif
		jump1:
	endfor
	
	labels = label_region(testim)
	print, 'Number of clusters should be ', max(labels)
	if max(labels) lt n_clusters then begin
		n_clusters = max(labels)
		goto, jump2
	endif 
endif

;Once the clusters have been decided, list out which entries are in each.
for i=0,n_clusters-1 do begin
	loc = where(result eq i, count)
	if count ne 0 then begin
		cluster_inds = loc+input_no[0]
		print, 'Saving cluster_inds to ', out_dir+'/cluster_'+num2str(cme_count)+'_'+num2str(i)+'.sav'
		save, cluster_inds, f=out_dir+'/cluster_'+num2str(cme_count)+'_'+num2str(i)+'.sav'
	endif
endfor
	
jump_end:

end
