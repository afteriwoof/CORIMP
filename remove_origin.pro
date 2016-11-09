; Code to remove the (0,0) origin point from the 3D reconstructions

pro remove_origin, files

print, 'Have to know what the restored variables are?'

sz = size(files,/dim)

for k=0,sz[0]-1 do begin
	restore,files[k]
	sz_xcs = size(xcs,/dim)
	for j=0,sz_xcs[1]-1 do begin
		ind = where((xcs ne 0) or (zcs ne 0))
		nxcs = xcs[ind,j]
	


end
