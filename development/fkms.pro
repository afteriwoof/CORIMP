; http://www.groupsrv.com/computers/about32281.html

pro FKMs, Xs, K, U, Ms, niter=niter, seed=seed 
; takes data Xs (array of column vectors) and number of clusters K as 
; input and returns fuzzy membership matrix U and the class centers Ms 
; Ref: J. C. Dunn, Journal of Cybernetics, PAM1:32-57, 1973 
; M. Canty 2004 

n = n_elements(Xs[*,0]) 
NN = n_elements(Xs[0,*]) 

if n_elements(niter) eq 0 then niter = 500 

; vector distances to cluster centers 
Ds = fltarr(n,NN) 
; work array 
W = fltarr(n,NN) 

; initialize normalized fuzzy membership matrix 
U = randomu(seed,n,K) 
for i=0L,n-1 do begin 
a = 1/total(U[i,*]) 
U[i,*] = U[i,*]*a 
endfor 

; iteration 
dU = 1.0 & iter=0L 
while ((dU gt 0.001) or (iter lt 20)) and (iter lt niter) do begin 
Uold = U 
UU = U*U 
; update means and distances 
Ms = Xs ## transpose(UU) 
for j=0,K-1 do begin 
Ms[j,*]=Ms[j,*]/total(UU[*,j]) 
for i=0,NN-1 do W[*,i]=replicate(Ms[j,i],n) 
Ds = Xs-W 
dd = 1/total(Ds*Ds,2) 
U[*,j] = dd 
endfor 
; normalize 
for j=0,K-1 do U[*,j]=U[*,j]/total(U,2) 
dU = max(abs(U-Uold)) 
iter=iter+1 
endwhile 

Ms = transpose(Ms) 

end 
