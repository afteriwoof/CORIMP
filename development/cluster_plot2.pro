; Test out the way cluster_tree works in a better coded way than test_clustering.pro

; Created:	20111206

pro cluster_plot2, data

; Given a set of points in two-dimensional space.  
;DATA 

sz = n_elements(data[0,*]) ; same as n_elements(data[1,*])

; Compute the Euclidean distance between each point.  
DISTANCE = DISTANCE_MEASURE(data)  
  
; Now compute the cluster analysis.  
CLUSTERS = CLUSTER_TREE(distance, linkdistance)  

number = transpose(indgen(sz-1)+sz)
 
help, data, distance, clusters, number
 
;PRINT, 'No. Item#  Item#  Distance'  
;PRINT, [number, clusters, TRANSPOSE(linkdistance)], $  
;   FORMAT='(I3, I3, I7, F10.2)'  
PRINT, 'No. Item#  Item#'
PRINT, [number, clusters], $
   FORMAT='(I3, I7, I7)'

for i=0,n_elements(clusters[0,*])-1 do begin
;for i=7,n_elements(clusters[0,*])-1 do begin

PRINT, 'No. Item#  Item#'
PRINT, [number, clusters], $
   FORMAT='(I3, I7, I7)'

	flag = 0
	jump2_flag = 0

	plot, data[0,*], data[1,*], psym=1, /iso;, xr=[0,6], yr=[0,5]
	
	print, '*************************************************************'
	print, 'i, clusters[0,i], clusters[1,i]';, (transpose(linkdistance))[i]'
	print, i, clusters[0,i], clusters[1,i];, (transpose(linkdistance))[i]
	print, '*************************************************************'
	if clusters[0,i] lt sz AND clusters[1,i] lt sz then begin
		; case where the clusters are single points
                ;print, 'plots, data[0,clusters[0,i]], data[1,clusters[0,i]]'
                ;plots, data[0,clusters[0,i]], data[1,clusters[0,i]], psym=1, color=(i mod 7)+2, thick=3, symsize=2
		;pause
                ;print, 'plots, data[0,clusters[1,i]], data[1,clusters[1,i]]'
                ;plots, data[0,clusters[1,i]], data[1,clusters[1,i]], psym=1, color=(i mod 7)+2, thick=3, symsize=2
		;pause
		if exist(final_test0) then final_test0=[final_test0,clusters[0,i]] else final_test0=clusters[0,i]
                if exist(final_test1) then final_test1=[final_test1,clusters[1,i]] else final_test1=clusters[1,i]
        endif else begin
		; case where the clusters are groups of points.
		; First check how many clusters there are in the first instance
		; case where the first pair have to be ignored until the end so that just the test0 row is done then the test1.
		if clusters[0,i] ge sz then begin
			test0 = clusters[0,clusters[0,i] mod sz]
			test1 = clusters[1,clusters[0,i] mod sz]
			print, '0a: test0 ', test0
			print, '0a: test1 ', test1
			flag = 1
		endif else begin
			if clusters[1,i] ge sz then begin
				test0 = clusters[0,clusters[1,i] mod sz]
				test1 = clusters[1,clusters[1,i] mod sz]
				print, '0b: test0 ', test0
				print, '0b: test1 ', test1
			endif else begin
				test0 = clusters[0,i]
				test1 = clusters[1,i]
				print, '0c: test0 ', test0
                                print, '0c: test1 ', test1
			endelse
		endelse
		count_test0 = 0
		count_test1 = 0
		jump2:
		if jump2_flag eq 1 then begin
			test0 = [test0, clusters[0,clusters[1,i] mod sz]]
			test1 = [test1, clusters[1,clusters[1,i] mod sz]]
			print, '0d: test0 ', test0
			print, '0d: test1 ', test1
			count_test0 = n_elements(test0)-1
			count_test1 = n_elements(test1)-1
			flag = 0
		endif
		;if flag eq 2 then begin
		;	test0 = clusters[0,clusters[1,i] mod sz]
		;	test1 = clusters[1,clusters[1,i] mod sz]
		;	print, '6: test0 ', test0
		;	print, '6: test1 ', test1
		;endif
		;flag_count_test1 = 0
		; first column first, then second.
		jump1:
		print, 'count_test0 ', count_test0
		print, 'count_test1 ', count_test1
		print, 'test0[count_test0] ', test0[count_test0]
		while test0[count_test0] ge sz do begin
			; while the cluster number is larger than the number of single points
			count_test0 += 1
			test0 = [test0, clusters[0,test0[count_test0-1] mod sz]]
			test1 = [test1, clusters[1,test0[count_test0-1] mod sz]]
			print, '1: test0 ', test0
			print, '1: test1 ', test1
			;if test1[count_test0] ge sz then begin
			;	if flag_count_test1 eq 0 then count_test1 = count_test0-1
			;	flag_count_test1 = 1
			;endif
		endwhile
		; loop over the test1 row until a hit is found
		for ind=count_test1,n_elements(test0)-1 do begin
			print, 'ind ', ind
			print, 'test1[ind] ', test1[ind]
			if test1[ind] ge sz then begin
				test0 = [test0, clusters[0,test1[ind] mod sz]]
				test1 = [test1, clusters[1,test1[ind] mod sz]]
				print, '2: test0 ', test0
				print, '2: test1 ', test1
				count_test1 = ind+1
				count_test0 += 1
				print, 'goto, jump1'
				;pause
				goto, jump1
			endif
		endfor

		print, 'flag ', flag
		if flag eq 1 AND clusters[1,i] ge sz then begin
			print, 'jump back to text clusters[1,i] which is ', clusters[1,i], ' and goto, jump2'
			jump2_flag = 1
			goto, jump2
		endif
		print, 'count_test0 ', count_test0
		print, 'count_test1 ', count_test1
		print, 'test0[count_test0] ', test0[count_test0]
		print, 'test1[count_test1] ', test1[count_test1]

		;pause

	endelse

	if exist(test0) then final_test0 = [clusters[0,i], test0] else final_test0 = clusters[0,i]
	if exist(test1) then final_test1 = [clusters[1,i], test1] else final_test1 = clusters[1,i]

	print, '**** FINAL ****'
	print, 'final_test0 '
	print, final_test0
	print, 'final_test1 '
	print, final_test1

	if where(final_test0 lt sz) ne [-1] then begin
                collapse_test0 = final_test0[where(final_test0 lt sz)]
                collapse_test0 = collapse_test0[uniq(collapse_test0, sort(collapse_test0))]
                print, 'collapse_test0 ', collapse_test0
                plots, data[0,collapse_test0], data[1,collapse_test0], psym=1, color=(i mod 7)+2, thick=3, symsize=2
        endif
	if where(final_test1 lt sz) ne [-1] then begin
                collapse_test1 = final_test1[where(final_test1 lt sz)]
                collapse_test1 = collapse_test1[uniq(collapse_test1, sort(collapse_test1))]
                print, 'collapse_test1 ', collapse_test1
                plots, data[0,collapse_test1], data[1,collapse_test1], psym=1, color=(i mod 7)+2, thick=3, symsize=2
        endif
	
	;wait, 0.05

	delvarx, test0, test1, count_test0, count_test1, collapse_test0, collapse_test1, final_test0, final_test1
endfor

end
