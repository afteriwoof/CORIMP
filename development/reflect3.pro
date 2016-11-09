; Code to reflect the outer and inner occulter masks with data

; Created: 15-03-11	
; Last edited: 16-03-11

function reflect3, in, da

;output array
im = fltarr(1216,1216)
im[96:1119,96:1119] = da
da = im
da2=da

;cartesian pixel size
pix_size=in.pix_size/in.rsun

get_ht_pa_2d_corimp, in.naxis1+192, in.naxis2+192, in.xcen+96, in.ycen+96, x, y, ht, pa, pix_size=pix_size

para = [0,360]

;DO FIRST INNER FOV AND OCCULTER REFLECTION
if in.i3_instr eq 'C2' then begin
	npa = 900.
	htra = [6.-(96*pix_size),6.];range of reflection in Rs. I go right into center just for fun.
	dht=htra[1]-htra[0]
	nref=(htra[1]-htra[0])/pix_size;approximate number of cartesian pixels within reflection depth 
	nref = float(nref)
endif

ht_polar=make_coordinates(nref,htra,/reverse);height vector for polar array
pa_polar=make_coordinates(npa,para); position angle vector for polar array

v = fltarr(2, n_elements(ht))
v[0,*] = pa
v[1,*] = ht

;do inner reflection within occulter first
h = hist_nd(v, nbin=[npa,nref], min=[para[0],htra[0]], max=[para[1],htra[1]], rev=ri)
h = float(h)

imp = fltarr(npa,nref)

for i=0,npa-1 do begin
	for j=0,nref-1 do begin
		index = i + npa*j
		if h[i,j] ne 0 then imp[i,j] = total(da[ri[ri[index]:ri[index+1]-1]]) / h[i,j]
	endfor
endfor

;interpolate polar array back into appropriate region inside occulter
index=where_limits(ht,htra[1],htra[1]+dht);identify appropriate pixels inside cartesian occulter
htnow=ht[index] & panow=pa[index];extract spatial information
htnow=2*htra[1]-htnow;modify htnow so reflection works

;calculate position of each appropariate cartesian pixel within polar array
ipa=interpol(indgen(npa),pa_polar,panow)
iht=interpol(indgen(nref),ht_polar,htnow)

;interpolate
da2[index]=interpolate(imp,ipa,iht,cubic=-0.5)

;similar approach for outer edges
;also need to expand data array to make room for outer reflection, probably right at start of this program?


return, da2

end
