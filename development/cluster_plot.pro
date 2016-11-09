; Test out the way cluster_tree works in a better coded way than test_clustering.pro

; Created:	20111206

pro cluster_plot, data

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



;for i=0,n_elements(clusters[0,*])-1 do begin
for i=200,n_elements(clusters[0,*])-1 do begin

	plot, data[0,*], data[1,*], psym=1;, xr=[0,6], yr=[0,5]
	
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
			print, '0: test0 ', test0
			print, '0: test1 ', test1
			flag = 1
		endif else begin
			if clusters[1,i] ge sz then begin
				test0 = clusters[0,clusters[1,i] mod sz]
				test1 = clusters[1,clusters[1,i] mod sz]
				print, '0: test0 ', test0
				print, '0: test1 ', test1
			endif else begin
				test0 = clusters[0,i]
				test1 = clusters[1,i]
				print, '0: test0 ', test0
                                print, '0: test1 ', test1
			endelse
		endelse
		jump2:
		if flag eq 2 then begin
			test0 = clusters[0,clusters[1,i] mod sz]
			test1 = clusters[1,clusters[1,i] mod sz]
			print, '6: test0 ', test0
			print, '6: test1 ', test1
		endif
		count_test0 = 0
		count_test1 = 0
		flag_count_test1 = 0
		; first column first, then second.
		while test0[count_test0] ge sz do begin
			; while the cluster number is larger than the number of single points
			count_test0 += 1
			test0 = [test0, clusters[0,test0[count_test0-1] mod sz]]
			test1 = [test1, clusters[1,test0[count_test0-1] mod sz]]
			print, '1: test0 ', test0
			print, '1: test1 ', test1
			if test1[count_test0] ge sz then begin
				if flag_count_test1 eq 0 then count_test1 = count_test0-1
				flag_count_test1 = 1
			endif
		endwhile
		while test1[count_test1] ge sz do begin
			count_test1 += 1
			test0 = [test0, clusters[0,test1[count_test1-1] mod sz]]
			test1 = [test1, clusters[1,test1[count_test1-1] mod sz]]
			print, '2: test0 ', test0
			print, '2: test1 ', test1
		endwhile
		print, 'count_test0 ', count_test0
		print, 'count_test1 ', count_test1
		print, 'tot count ', count_test0+count_test1+1
		print, 'size test0 ', size(test0, /dim)
		print, 'size test1 ', size(test1, /dim)

		add_on_more = 0
		pen_test0 = 0
		; so the first count of columns is available to start looping through the potential rest.
		if count_test1 gt 0 then begin
			jump1:
			add_on0 = 0
			add_on1 = 0
			print, 'check ', test0[pen_test0:n_elements(test0)-1]
			print, 'check ', test1[pen_test0:n_elements(test1)-1]
			;****
			; this is where to now write loop over the columns to test and add to.
			; first test and add down test0
			if pen_test0 gt 0 then add_on_more=pen_test0-count_test0-1
			print, 'add_on_more restart', add_on_more
			print, '*** along test0 direction'
			print, 'for test_no = ', count_test0+1+add_on_more, ', ', n_elements(test0)-1
			loop_end = n_elements(test0)-1
			for test_no = (count_test0+1+add_on_more),loop_end do begin
				test0_before = n_elements(test0)
				print, 'test_no ', test_no
				print, 'test0[test_no] ', test0[test_no]
				if test0[test_no] ge sz then begin
					test0 = [test0, clusters[0,test0[test_no] mod sz]]
					test1 = [test1, clusters[1,test0[test_no] mod sz]]
					print, '2: test0 ', test0
					print, '2: test1 ', test1
				endif
				jump3:
				print, 'Will I need to loop test0 again?'
				if test0[n_elements(test0)-1] ge sz then begin
					current_test0 = test0[n_elements(test0)-1]
					print, 'Yes, from ', current_test0
					if test_no lt loop_end then begin
						print, 'But going to loop again anyway'
					endif else begin
						test0 = [test0, clusters[0,current_test0 mod sz]]
						test1 = [test1, clusters[1,current_test0 mod sz]]
						print, '3: test0 ', test0
                                        	print, '3: test1 ', test1
						add_on0 += 1
						print, 'add_on0 ', add_on0
						if test0[n_elements(test0)-1] ge sz then goto, jump3
					endelse
				endif else begin
					print, 'No.'
				endelse
			endfor
			pen_test0 = n_elements(test0) ;penultimate test0 size
			print, 'Penultimate n_elements(test0) ', pen_test0
			; now test down the second column
			print, '*** along test1 direction'
			print, 'for test_no = ', count_test1+1+add_on_more, ', ', n_elements(test0)-1
			for test_no = (count_test1+1+add_on_more),n_elements(test0)-1 do begin
				print, 'test_no ', test_no
				print, 'test1[test_no] ', test1[test_no]
				if test1[test_no] ge sz then begin
					test0 = [test0, clusters[0,test1[test_no] mod sz]]
					test1 = [test1, clusters[1,test1[test_no] mod sz]]
					print, '4: test0 ', test0
					print, '4: test1 ', test1
					print, 'n_elements(test1) ', n_elements(test1)
					print, 'Will I need to loop test1 again?'
					if test1[n_elements(test1)-1] ge sz then begin
						print, 'YES down test1 at ', test1[n_elements(test1)-1]
						test0 = [test0, clusters[0,test1[n_elements(test1)-1] mod sz]]
						test1 = [test1, clusters[1,test1[n_elements(test1)-1] mod sz]]
						print, '5: test0 ', test0
						print, '5: test1 ', test1
						add_on1 += 1
						print, 'add_on1 ', add_on1
					endif else begin
						print, 'No.'
						print, 'Then will I need to loop test0 again?'
						if test0[n_elements(test1)-1] ge sz then begin
							print, 'Yes, from ', test0[n_elements(test1)-1]
							goto, jump1
						endif
					endelse
				endif
			endfor

			print, 'Penultimate n_elements(test0) + add_on1 ', pen_test0, ' + ', add_on1
                        pen_test0 += add_on1
	
			print, 'Final add_on ', add_on0, add_on1

			if add_on1 gt 0 then begin
				print, 'loop again now inspecting '
				help, pen_test0, test0, test1
				goto, jump1
			
			endif
		endif
	
		if exist(flag) AND flag eq 1 then begin
			first_test0 = test0
			first_test1 = test1
			if clusters[1,i] ge sz then begin
				flag = 2
				; go back and do the same now for down row of test1
				goto, jump2
			endif else begin
				print, 'There is only first_test0 and first_test1 (no second_tests)'
			endelse
		endif
		if exist(flag) AND flag eq 2 then begin
			second_test0 = test0
			second_test1 = test1
		endif
	endelse
        if exist(first_test0) then begin
		print, 'Cluster0 ', clusters[0,i]
		print, 'first_test0 ', first_test0
	endif else begin
		first_test0 = clusters[0,i]
		print, 'Cluster0 ', clusters[0,i]
	endelse
        if exist(first_test1) then print, 'first_test1 ', first_test1
        if exist(second_test0) then begin
		print, 'Cluster1 ', clusters[1,i]
		print, 'second_test0 ', second_test0
	endif else begin
		second_test0 = clusters[1,i]
		print, 'Cluster1 ', clusters[1,i]
	endelse
        if exist(second_test1) then print, 'second_test1 ', second_test1

	print, 'Final:'
	print, first_test0
	if exist(first_test1) then print, first_test1
	print, second_test0
	if exist(second_test1) then print, second_test1
	
	
	if where(first_test0 lt sz) ne [-1] then begin
		collapse_first_test0 = first_test0[where(first_test0 lt sz)]
		collapse_first_test0 = collapse_first_test0[uniq(collapse_first_test0, sort(collapse_first_test0))]
		print, 'collapse_first_test0 ', collapse_first_test0
		plots, data[0,collapse_first_test0], data[1,collapse_first_test0], psym=1, color=(i mod 7)+2, thick=3, symsize=2
	endif
	if exist(first_test1) then begin
		if where(first_test1 lt sz) ne [-1] then begin
			collapse_first_test1 = first_test1[where(first_test1 lt sz)]
			collapse_first_test1 = collapse_first_test1[uniq(collapse_first_test1, sort(collapse_first_test1))]
			print, 'collapse_first_test1 ', collapse_first_test1
			plots, data[0,collapse_first_test1], data[1,collapse_first_test1], psym=1, color=(i mod 7)+2, thick=3, symsize=2
		endif
	endif
	if where(second_test0 lt sz) ne [-1] then begin
		collapse_second_test0 = second_test0[where(second_test0 lt sz)]
		collapse_second_test0 = collapse_second_test0[uniq(collapse_second_test0, sort(collapse_second_test0))]
		print, 'collapse_second_test0 ', collapse_second_test0
		plots, data[0,collapse_second_test0], data[1,collapse_second_test0], psym=1, color=(i mod 7)+2, thick=3, symsize=2
	endif
	if exist(second_test1) then begin
		if where(second_test1 lt sz) ne [-1] then begin
			collapse_second_test1 = second_test1[where(second_test1 lt sz)]
			collapse_second_test1 = collapse_second_test1[uniq(collapse_second_test1, sort(collapse_second_test1))]
			print, 'collapse_second_test1 ', collapse_second_test1
			plots, data[0,collapse_second_test1], data[1,collapse_second_test1], psym=1, color=(i mod 7)+2, thick=3, symsize=2
		endif
	endif

	pause


	delvarx, first_test0, first_test1, second_test0, second_test1

endfor

end
