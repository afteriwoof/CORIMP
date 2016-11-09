; Test out the way cluster_tree works in a better coded way than test_clustering.pro

; Created:	20111201

pro test_clustering3

; Given a set of points in two-dimensional space.  
DATA = [ $  
[1, 1], $  
[1, 3], $  
[2, 2.2], $  
[4, 1.75], $  
[4, 4], $  
[5, 1], $  
[5.5, 3]]  

sz = n_elements(data[0,*]) ; same as n_elements(data[1,*])

; Compute the Euclidean distance between each point.  
DISTANCE = DISTANCE_MEASURE(data)  
  
; Now compute the cluster analysis.  
CLUSTERS = CLUSTER_TREE(distance, linkdistance)  
 
help, data, distance, clusters
 
PRINT, 'Item#  Item#  Distance'  
PRINT, [clusters, TRANSPOSE(linkdistance)], $  
   FORMAT='(I3, I7, F10.2)'  

plot, data[0,*], data[1,*], psym=1, xr=[0,6], yr=[0,5]

; make new clusters for testing code
temp0 = transpose([transpose(clusters[0,*]),9,13,14])
temp1 = transpose([transpose(clusters[1,*]),12,9,10])
clusters=[temp0,temp1]
temp = transpose(indgen(9)+7)
PRINT, 'No. Item#  Item#'
PRINT, [temp,clusters], $
   FORMAT='(I3, I7, I7)'
pause

for i=0,n_elements(clusters[0,*])-1 do begin
	PRINT, 'No. Item#  Item#'
	PRINT, [temp,clusters], $
	   FORMAT='(I3, I7, I7)'
	
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
		test0 = clusters[0,i]
		test1 = clusters[1,i]
		count_test0 = 0
		count_test1 = 0
		; first column first, then second.
		while test0[count_test0] ge sz do begin
			; while the cluster number is larger than the number of single points
			count_test0 += 1
			test0 = [test0, clusters[0,test0[count_test0-1] mod sz]]
			test1 = [test1, clusters[1,test0[count_test0-1] mod sz]]
			print, '1: test0 ', test0
			print, '1: test1 ', test1
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
			add_on = 0
			print, 'check ', test0[pen_test0:n_elements(test0)-1]
			print, 'check ', test1[pen_test0:n_elements(test1)-1]
			;****
			; this is where to now write loop over the columns to test and add to.
			; first test and add down test0
			if pen_test0 gt 0 then add_on_more=pen_test0-count_test0-1
			print, 'add_on_more restart', add_on_more
			print, '*** along test0 direction'
			print, 'for test_no = ', count_test0+1+add_on_more, ', ', n_elements(test0)-1
			for test_no = (count_test0+1+add_on_more),n_elements(test0)-1 do begin
				test0_before = n_elements(test0)
				print, 'test_no ', test_no
				print, 'test0[test_no] ', test0[test_no]
				if test0[test_no] ge sz then begin
					test0 = [test0, clusters[0,test0[test_no] mod sz]]
					test1 = [test1, clusters[1,test0[test_no] mod sz]]
					print, '2: test0 ', test0
					print, '2: test1 ', test1
				endif
				print, 'Will I need to loop test0 again?'
				if test0[n_elements(test0)-1] ge sz then begin
					current_test0 = test0[n_elements(test0)-1]
					print, 'Yes, from ', current_test0
					test0 = [test0, clusters[0,current_test0 mod sz]]
					test1 = [test1, clusters[1,current_test0 mod sz]]
					print, '3: test0 ', test0
                                        print, '3: test1 ', test1
					add_on += 1
					print, 'add_on ', add_on
				endif else begin
					print, 'No.'
				endelse
			endfor
			pen_test0 = n_elements(test0) ;penultimate test0 size
			print, 'Penultimate n_elements(test0) ', pen_test0
			; now test down the second column
			print, '*** along test1 direction'
			print, 'for test_no = ', count_test0+1+add_on_more, ', ', n_elements(test0)-1
			for test_no = (count_test0+1+add_on_more),n_elements(test0)-1 do begin
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
						print, 'YES down test1 at ', test1[test_no+1]
						test0 = [test0, clusters[0,test1[test_no+1] mod sz]]
						test1 = [test1, clusters[1,test1[test_no+1] mod sz]]
						print, '5: test0 ', test0
						print, '5: test1 ', test1
						add_on += 1
						print, 'add_on ', add_on
					endif else begin
						print, 'No.'
					endelse
				endif
			endfor
	
			print, 'Final add_on ', add_on

			if add_on gt 0 then begin
				print, 'loop again now inspecting '
				print, test0[pen_test0:n_elements(test0)-1]
				print, test1[pen_test0:n_elements(test1)-1]
				goto, jump1
			
			endif
		endif




	endelse

	pause


endfor

;temp
final_test0 = [final_test0, 2]
final_test1 = [final_test1, 1]

inc = 0
test = 1
steps = 0
print, '******************'
print, 'final_test0 ', final_test0
print, 'final_test1 ', final_test1
print, '******************'

while inc lt n_elements(final_test0) do begin
	print, 'inc ', inc
	print, 'n_elements(final_test0)',  n_elements(final_test0)
	print, 'final_test0[inc] ', final_test0[inc], ' n_elements(data[0,*]) ', n_elements(data[0,*])
	print, 'final_test1[inc] ', final_test1[inc], ' n_elements(data[1,*]) ', n_elements(data[1,*])
	case 1 of
	(final_test0[inc] ge n_elements(data[0,*])) AND (final_test1[inc] ge n_elements(data[1,*])):	steps = 2
	(final_test0[inc] ge n_elements(data[0,*])) XOR (final_test1[inc] ge n_elements(data[1,*])):	steps = 1
	else:	steps = 0
	endcase
	print, 'steps ', steps
	if steps gt 0 then begin
		inc_add = 1
		while inc_add lt steps do begin
			print, 'inc_add is ', inc_add
			case 1 of
			(final_test0[inc+inc_add] ge n_elements(data[0,*])) AND (final_test1[inc+inc_add] ge n_elements(data[1,*])):	steps += 2
			(final_test0[inc+inc_add] ge n_elements(data[0,*])) XOR (final_test1[inc+inc_add] ge n_elements(data[1,*])):	steps += 1
			else:	inc_add_now = 0
			endcase
			inc_add += 1
		endwhile
		print, 'steps is ', steps
		print, final_test0[inc:inc+steps]
		print, final_test1[inc:inc+steps]
	endif
	pause
	inc += steps+1
endwhile	


	

end
