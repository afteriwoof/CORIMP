; code to running difference euvi data.

pro fdiff_euvi, fls, fdiffs

sz = size(fls,/dim)

da = sccreadfits(fls,in,/nodata)

fdiffs = dblarr(2048,2048,sz[0]-1)

map0 = mk_secchi_map(fls[0])
d0 = map0.data
sm0 = median(d0,3)
map0.data = sm0

for k=1,sz[0]-1 do begin

	map1 = mk_secchi_map(fls[k])
		
	;drot_map0 = drot_map(maps[0],time=maps[0].time,/nolimb,b0=maps[0].B0,l0=maps[0].L0,rsun=maps[0].rsun)
	
	d1 = map1.data
	sm1 = median(d1, 3)
	
	sm1 = rm_inner(sm1,in[k],dr_px,thr=1)
	
	map1.data = sm1
	;drot_map1 = drot_map(maps[1],time=maps[1].time,/nolimb,b0=maps[1].B0,l0=maps[1].L0,rsun=maps[1].rsun)
	
	diffmap = diff_map(map1,map0)
	
	;plot_map, diffmap, /log

	fdiffs[*,*,k-1] = diffmap.data

	;plot_image,sigrange(rdiffs[*,*,k-1])

endfor


end
