; Test out the way cluster_tree works.

; Created:	20111128

pro test_clustering

; Given a set of points in two-dimensional space.  
DATA = [ $  
[1, 1], $  
[1, 3], $  
[2, 2.2], $  
[4, 1.75], $  
[4, 4], $  
[5, 1], $  
[5.5, 3]]  

; Compute the Euclidean distance between each point.  
DISTANCE = DISTANCE_MEASURE(data)  
  
; Now compute the cluster analysis.  
CLUSTERS = CLUSTER_TREE(distance, linkdistance)  
 
help, data, distance, clusters
 
PRINT, 'Item#  Item#  Distance'  
PRINT, [clusters, TRANSPOSE(linkdistance)], $  
   FORMAT='(I3, I7, F10.2)'  

plot, data[0,*], data[1,*], psym=1, xr=[0,6], yr=[0,5]

for i=0,n_elements(clusters[0,*])-1 do begin
	print, 'i, clusters[i], clusters[0,i], clusters[1,i], (transpose(linkdistance))[i]'
	print, i, clusters[i], clusters[0,i], clusters[1,i], (transpose(linkdistance))[i]
	print, 'n_elements(clusters[0,*] ', n_elements(clusters[0,*])
        print, 'n_elements(clusters[1,*] ', n_elements(clusters[1,*])
	if clusters[0,i] lt n_elements(data[0,*]) AND clusters[1,i] lt n_elements(data[1,*]) then begin
                plots, data[0,clusters[0,i]], data[1,clusters[0,i]], psym=1, color=(i mod 7)+2, thick=3, symsize=2
                pause
                plots, data[0,clusters[1,i]], data[1,clusters[1,i]], psym=1, color=(i mod 7)+2, thick=3, symsize=2
                pause
        endif else begin
                print, 'group'
		print, 'clusters[0,i] ', clusters[0,i]
		print, 'clusters[1,i] ', clusters[1,i]
		print, 'clusters[0,i] mod n_elements(data[0,*]) ', clusters[0,i] mod n_elements(data[0,*])
	        print, 'clusters[1,i] mod n_elements(data[1,*]) ', clusters[1,i] mod n_elements(data[1,*])
                pause
		if clusters[0,i] ge n_elements(data[0,*]) then begin
			print, 'clusters[0,i] ', clusters[0,i]
			clust1 = clusters[0,clusters[0,i] mod n_elements(data[0,*])]
			print, 'clusters[0,clusters[0,i] mod n_elements(data[0,*])] ', clusters[0,clusters[0,i] mod n_elements(data[0,*])]
			if clust1 ge n_elements(data[0,*]) then begin
				clust11 = clusters[0,clust1 mod n_elements(data[0,*])]
				clust12 = clusters[1,clust1 mod n_elements(data[0,*])]
				print, 'clusters[0,clust1 mod n_elements(data[0,*])] ', clusters[0,clust1 mod n_elements(data[0,*])]
			endif
			clust2 = clusters[1,clusters[0,i] mod n_elements(data[0,*])]
			if clust2 ge n_elements(data[0,*]) then begin
                                clust21 = clusters[0,clust2 mod n_elements(data[0,*])]
                                clust22 = clusters[1,clust2 mod n_elements(data[0,*])]
                        endif
		endif
		if clusters[1,i] ge n_elements(data[1,*]) then begin
                        clust3 = clusters[0,clusters[1,i] mod n_elements(data[1,*])]
			if clust3 ge n_elements(data[1,*]) then begin
                                clust31 = clusters[0,clust3 mod n_elements(data[1,*])]
                                clust32 = clusters[1,clust3 mod n_elements(data[1,*])]
                        endif
                        clust4 = clusters[1,clusters[1,i] mod n_elements(data[1,*])]
			if clust4 ge n_elements(data[1,*]) then begin
                                clust41 = clusters[0,clust4 mod n_elements(data[1,*])]
                                clust42 = clusters[1,clust4 mod n_elements(data[1,*])]
                        endif
                endif
		help, clust1, clust2, clust3, clust4, clust11,clust12,clust21,clust22,clust31,clust32,clust41,clust42
		if exist(clust11) then begin
			plots, data[0,clust11], data[1,clust11], psym=1, color=(i mod 4)+4, thick=3, symsize=3
			pause
			plots, data[0,clust12], data[1,clust12], psym=1, color=(i mod 4)+4, thick=3, symsize=3
			pause
		endif else begin
			if exist(clust1) then plots, data[0,clust1], data[1,clust1], psym=1, color=(i mod 4)+4, thick=3, symsize=3 $
			else plots, data[0,clusters[1,i]], data[1,clusters[1,i]], psym=1, color=(i mod 4)+4, thick=3, symsize=3
			pause
		endelse
		if exist(clust21) then begin
			plots, data[0,clust21], data[1,clust21], psym=1, color=(i mod 4)+4, thick=3, symsize=3
                        pause
                        plots, data[0,clust22], data[1,clust22], psym=1, color=(i mod 4)+4, thick=3, symsize=3
                        pause
                endif else begin
			if exist(clust2) then plots, data[0,clust2], data[1,clust2], psym=1, color=(i mod 4)+4, thick=3, symsize=3 $
			else plots, data[0,clusters[1,i]], data[1,clusters[1,i]], psym=1, color=(i mod 4)+4, thick=3, symsize=3
			pause
		endelse
		if exist(clust31) then begin
                        plots, data[0,clust31], data[1,clust31], psym=1, color=(i mod 4)+4, thick=3, symsize=3
                        pause
                        plots, data[0,clust32], data[1,clust32], psym=1, color=(i mod 4)+4, thick=3, symsize=3
                        pause
                endif else begin
                        if exist(clust3) then plots, data[0,clust3], data[1,clust3], psym=1, color=(i mod 4)+4, thick=3, symsize=3 $
			else plots, data[0,clusters[1,i]], data[1,clusters[1,i]], psym=1, color=(i mod 4)+4, thick=3, symsize=3
                        pause
                endelse
                if exist(clust41) then begin
                        plots, data[0,clust41], data[1,clust41], psym=1, color=(i mod 4)+4, thick=3, symsize=3
                        pause
                        plots, data[0,clust42], data[1,clust42], psym=1, color=(i mod 4)+4, thick=3, symsize=3
                        pause
                endif else begin
                        if exist(clust4) then plots, data[0,clust4], data[1,clust4], psym=1, color=(i mod 4)+4, thick=3, symsize=3 $
			else plots, data[0,clusters[1,i]], data[1,clusters[1,i]], psym=1, color=(i mod 4)+4, thick=3, symsize=3
                        pause
                endelse

	endelse
endfor
	

end
