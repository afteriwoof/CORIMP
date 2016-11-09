pro non_zero_front, xf, yf, xnf, ynf

xnf = xf
ynf = yf
sz = size(xf, /dim)
i=0
j=0

while ( i lt sz[0] ) do begin
	
	if ((xf[i] ne 0) OR (yf[i] ne 0)) then begin
		xnf[j] = xf[i]
		ynf[j] = yf[i]
		j += 1
	endif 
		i+=1
endwhile

xnf = xnf[0:j-1]
ynf = ynf[0:j-1]
end
