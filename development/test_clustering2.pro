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
		step_again = 0
		test0 = clusters[0,i]
		test1 = clusters[1,i]
		count_test0 = 0
		count_test1 = 0
		step_again0_entry = 0
		step_again1_entry = 0
		; this jump is for looping down the columns more than once
		jump1:
		flag_step_again = 0
		; first go down first column - test0
		print, 'Before going down the first column the entries are test0: ', test0
		print, 'test0 ', test0
		print, 'test0[count_test0] ', test0[count_test0]
		while test0[count_test0] ge n_elements(data[0,*]) do begin
			; while the cluster number is larger than the number of single points
			print, 'First Column: test0[count_test0] ge n_elements(data[0,*])'
			;print, 'clusters[0,i] ', clusters[0,i]
			;print, 'clusters[0,test0 mod n_elements(data[0,*])] ', clusters[0,test0 mod n_elements(data[0,*])]
			count_test0 += 1
			;gather the tests according to the number indicated by the first column of clusters since loop is over test0
			test0 = [test0, clusters[0,test0[count_test0-1] mod n_elements(data[0,*])]]
			test1 = [test1, clusters[1,test0[count_test0-1] mod n_elements(data[1,*])]]
			;if clusters[0,test0[count_test0-1] mod n_elements(data[0,*])] ge n_elements(data[0,*]) then print, 'ANOTHER1'
			;if clusters[1,test0[count_test0-1] mod n_elements(data[1,*])] ge n_elements(data[1,*]) then print, 'ANOTHER1'
			print, 'test0 ', test0
			print, 'test1 ', test1
			pause
		endwhile
		; second go down second column - test1
		print, 'Before going down the second column the entries are test1: ', test1
		print, 'test1 ', test1
		print, 'test1[count_test1] ', test1[count_test1]
		while test1[count_test1] ge n_elements(data[1,*]) do begin
			;while the cluster number is larger than the number of single points
			print, 'Second Column: test1[count_test1] ge n_elements(data[1,*])'
			count_test1 += 1
			print, 'count_test1 ', count_test1
			print, 'test0 init ', test0
			print, 'test1 init ', test1
			; now add in the next cluster numbers
			test0 = [test0, clusters[0,test1[count_test1-1] mod n_elements(data[0,*])]]
			test1 = [test1, clusters[1,test1[count_test1-1] mod n_elements(data[1,*])]]
			print, 'test0 again ', test0
			print, 'test1 again ', test1
			; check does it need to loop down the second column of the new ones now.
			if clusters[0,test1[count_test1-1] mod n_elements(data[0,*])] ge n_elements(data[0,*]) then begin
				print, 'So will need to go down the first column again'
				print, 'To consider column entry ', clusters[0,test1[count_test1-1] mod n_elements(data[0,*])]
				if exist(step_again0_entry) AND step_again0_entry ne 0 then step_again0_entry = [step_again0_entry,test1[count_test1-1] mod n_elements(data[0,*])] $
					else step_again0_entry = test1[count_test1-1] mod n_elements(data[0,*])
				print, 'step_again0_entry ', step_again0_entry
				if exist(step_again0) then step_again0 += 1 else step_again0 = 1
				print, 'step_again0 ', step_again0
				flag_step_again = 1
				print, 'flag_step_again ', flag_step_again
			endif
			if clusters[1,test1[count_test1-1] mod n_elements(data[1,*])] ge n_elements(data[1,*]) then begin
				print, 'So will need to go down the second column again'
				print, 'To consider column entry ', clusters[1,test1[count_test1-1] mod n_elements(data[1,*])]
				if exist(step_again1_entry) AND step_again1_entry ne 0 then step_again1_entry = [step_again1_entry,test1[count_test1-1] mod n_elements(data[1,*])] $
					else step_again1_entry = test1[count_test1-1] mod n_elements(data[1,*])
				print, 'step_again1_entry ', step_again1_entry
				if exist(step_again1) then step_again1 += 1 else step_again1 = 1
				print, 'step_again1 ', step_again1
				flag_step_again = 1
				print, 'flag_step_again ', flag_step_again
			endif
			pause
		endwhile
		if flag_step_again eq 1 then begin
			help, step_again0_entry, step_again1_entry
			if step_again0_entry eq 0 and step_again1_entry ne 0 then step_again0_entry=step_again1_entry else step_again1_entry=step_again0_entry
			;go through it again
			print, 'whats the count_test0 now ', count_test0
			print, 'whats the count_test1 now ', count_test1
			;print, 'goto jump1'
			;goto, jump1
			; Don't jump back but write a loop here to account for needing to redo from this point down the columns
			print, 'Now test0 ', test0
			print, 'Now test1 ', test1
			print, 'step_again0_entry ', step_again0_entry
			print, 'step_again1_entry ', step_again1_entry
			print, 'clusters[0,clusters[0,step_again0_entry] mod n_elements(data[0,*])] ', clusters[0,clusters[0,step_again0_entry] mod n_elements(data[0,*])]
			print, 'clusters[1,clusters[0,step_again1_entry] mod n_elements(data[0,*])] ', clusters[1,clusters[0,step_again1_entry] mod n_elements(data[0,*])]
			test0 = [test0, clusters[0,clusters[0,step_again0_entry] mod n_elements(data[0,*])]]
			test1 = [test1, clusters[1,clusters[0,step_again1_entry] mod n_elements(data[0,*])]]
			print, 'Then test0 ', test0
			print, 'Then test1 ', test1
			pause
		endif
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
