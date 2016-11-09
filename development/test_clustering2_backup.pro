; Test out the way cluster_tree works in a better coded way than test_clustering.pro

; Created:	20111129

pro test_clustering2

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
	if clusters[0,i] lt n_elements(data[0,*]) AND clusters[1,i] lt n_elements(data[1,*]) then begin
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
		test0 = clusters[0,i]
		test1 = clusters[1,i]
		count_test0 = 0
		; fist go down first column - test0
		while test0[count_test0] ge n_elements(data[0,*]) do begin
			; while the cluster number is larger than the number of single points
			;print, 'clusters[0,i] ', clusters[0,i]
			;print, 'clusters[0,test0 mod n_elements(data[0,*])] ', clusters[0,test0 mod n_elements(data[0,*])]
			count_test0 += 1
			;gather the tests according to the number indicated by the first column of clusters since loop is over test0
			test0 = [test0, clusters[0,test0[count_test0-1] mod n_elements(data[0,*])]]
			test1 = [test1, clusters[1,test0[count_test0-1] mod n_elements(data[1,*])]]
			print, 'test0 ', test0
			print, 'test1 ', test1
		;	pause
		endwhile
		; second go down second column - test1
		count_test1 = 0
		print, 'test1 init ', test1
		while test1[count_test1] ge n_elements(data[1,*]) do begin
			;while the cluster number is larger than the number of single points
			count_test1 += 1
			print, 'count_test1 ', count_test1
			print, 'test0 init ', test0
			print, 'test1 init ', test1
			test0 = [test0, clusters[0,test1[count_test1-1] mod n_elements(data[0,*])]]
			test1 = [test1, clusters[1,test1[count_test1-1] mod n_elements(data[1,*])]]
			print, 'test0 again ', test0
			print, 'test1 again ', test1
		endwhile
		;print, 'plots, data[0,test0[count_test0]], data[1,test0[count_test0]]'
		;plots, data[0,test0[count_test0]], data[1,test0[count_test0]], psym=1, color=(i mod 4)+4, thick=3, symsize=3
		;plots, data[0,test1[count_test0]], data[1,test1[count_test0]], psym=1, color=(i mod 4)+4, thick=3, symsize=3		
		;pause
		if exist(final_test0) then final_test0=[final_test0,test0] else final_test0=test0
		if exist(final_test1) then final_test1=[final_test1,test1] else final_test1=test1
	endelse
	print, 'final_test0 ', final_test0
	print, 'final_test1 ', final_test1

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
	pause
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
; end here (below is old - delete)

	;**************
	if final_test0[inc] ge n_elements(data[0,*]) OR final_test1[inc] ge n_elements(data[1,*]) then begin
		print, 'test=0'
		test = 0 
	endif else begin
		print,'plots, data[0,final_test0[inc]], data[1,final_test0[inc]], psym=1' 
		print,'plots, data[0,final_test1[inc]], data[1,final_test1[inc]], psym=1' 
		plots, data[0,final_test0[inc]], data[1,final_test0[inc]], psym=1, color=(inc mod 7)+2, thick=3, symsize=2
		plots, data[0,final_test1[inc]], data[1,final_test1[inc]], psym=1, color=(inc mod 7)+2, thick=3, symsize=2
	endelse
	while test ne 1 do begin
		jump1:
		print, 'final_test0[inc] ', final_test0[inc], ' n_elements(data[0,*]) ', n_elements(data[0,*])
	        print, 'final_test1[inc] ', final_test1[inc], ' n_elements(data[1,*]) ', n_elements(data[1,*])
		print, 'test ', test
		print, 'inc in while ', inc
		if final_test0[inc] lt n_elements(data[0,*]) then $
			plots, data[0,final_test0[inc]], data[1,final_test0[inc]], psym=4, color=(inc mod 7)+2, thick=3, symsize=inc+1
		if final_test1[inc] lt n_elements(data[1,*]) then $
			plots, data[0,final_test1[inc]], data[1,final_test1[inc]], psym=4, color=(inc mod 7)+2, thick=3, symsize=inc+1
		if final_test0[inc] lt n_elements(data[0,*]) AND final_test1[inc] lt n_elements(data[1,*]) then begin
			test=1
			print, 'test=1'
		endif else begin
			inc+=1
			print, 'inc+=1 & goto, jump1'
			goto, jump1
		endelse
	endwhile
	inc += 1
	pause
endwhile	


	

end
