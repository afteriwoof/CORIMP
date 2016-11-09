; Code to take the canny_atrous modgrads and alpgrads at a particular scale for spatiotemp.pro

; Last Edited: 03-10-07

PRO pre_spatiotemp, da, s, modgrads, alpgrads, rows, columns

sz = size(da, /dim)

modgrads = fltarr(sz[0],sz[1],sz[2])
alpgrads = modgrads
rows = modgrads
columns = modgrads

for k=0,sz[2]-1 do begin
	canny_atrous2d, da[*,*,k], modgrad, alpgrad, rows=row, columns=col
	modgrads[*,*,k] = modgrad[*,*,s]
	alpgrads[*,*,k] = alpgrad[*,*,s]
	rows[*,*,k] = row[*,*,5]
	columns[*,*,k] = col[*,*,5]
endfor

END

	
