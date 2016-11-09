; Use Gaussian elimination to solve simultaneous equations

; Created: 11-09-08 Jason.

; Last edited: 11-09-08 Jason

; input m x n matrix in 'augmented matrix' form (m-n=1)


function gaussian_elimination, input

matrix = input

matrix=float(matrix)

sz = size(matrix, /dim)
m = sz[0] ; columns
n = sz[1] ; rows
; matrix[column, row]
i=0 ; columns
j=0 ; rows
;maxi = max(matrix[*,*]) ; biggest number in matrix
;maxi_row = where(matrix[*,*] eq maxi)/m ; row containing biggest number in matrix
;print,maxi,maxi_row
;switch this row with the bottom row
;temp = matrix[*,n-1] ; bottom row
;matrix[*,n-1] = matrix[*,maxi_row]
;matrix[*,maxi_row] = temp
while(i lt m and j lt n) do begin
	for u=j+1,n-1 do begin
		matrix[*,u] -= (matrix[i,u]/matrix[i,j])*matrix[*,j]
	endfor
	i+=1
	j+=1
endwhile
 
; Once in upper triangular form can solve backwards for each variable
evals = fltarr(n) ; not necessarily eigenvalues!
; last eval easily done:
evals[n-1] = matrix[m-1,n-1] / matrix[m-2,n-1]
count = n-2
while(count gt -1) do begin
	add_on = 0
	for k=(count+1),n-1 do begin
		add_on += (matrix[k,count]*evals[k])/matrix[count,count]
	endfor
	evals[count] = matrix[m-1,count]/matrix[count,count] - add_on
	count -= 1
endwhile

return, evals



end
