; Code to reflect the outer and inner occulter masks with data

; Created: 15-03-11	

function reflect, in, da

get_ht_pa_2d_corimp, in.naxis1, in.naxis2, in.xcen, in.ycen, x, y, ht, pa, pix_size=in.pix_size/in.rsun

para = [0,360]
if in.i3_instr eq 'C2' then begin
	npa = 900.
	nr = 300.
	htra = [2.25,6.]
endif

v = fltarr(2, n_elements(ht))
v[0,*] = pa
v[1,*] = ht

h = hist_nd(v, nbin=[npa,nr], min=[para[0],htra[0]], max=[para[1],htra[1]], rev=ri)
h = float(h)

imp = fltarr(npa,nr)

for i=0,npa-1 do begin
	for j=0,nr-1 do begin
		index = i + npa*j
		if h[i,j] ne 0 then imp[i,j] = total(da[ri[ri[index]:ri[index+1]-1]]) / h[i,j]
	endfor
endfor


newimp = fltarr(npa, nr+(nr/5.))
newimp[*, (nr/10.):(nr+nr/10.)-1] = imp

for i=0,(nr/10.)-1 do newimp[*,(nr/10.)-i] = imp[*,i+1]

for i=(nr+nr/10.),(nr+nr/5.)-1 do newimp[*,i] = imp[*,nr-(i-nr)]


return, newimp

end
