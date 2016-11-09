; Code to reflect the outer and inner occulter masks with data

; Created: 28-06-11	from reflect_inner_outer.pro
; Last edited:	May the 4th be with you (2011) to include steps for blending data over the C3 occulter arm. 
;		27-05-11	Changed the in.xcen and in.ycen to in.crpix1/2 everywhere.

function reflect_inner_outer_cme_model, in, da

C2_thr_inner = 2.3
C2_thr_outer = 5.7
C3_thr_inner = 5.95
C3_thr_outer = 16
print,'Currently have C2_thr_outer set to 5.7 rather than 5.95 because of the cme model'
print,'Currently have C3_thr_outer set to 16 rather than 19.5 because of the cme model'
da_in = da

; Masking off the occulter arm of C3.

if in.i4_instr eq 'C3' then begin
        da2_r = reverse(da_in, 1) ;flip horizontally
        da2_r = rot(da2_r, 99, 1, in.crpix1, in.crpix2, /interp)
        inds = where(da_in eq 0)
        da_in[inds] = da2_r[inds]
        delvarx, da2_r, inds
endif

count = 0 ;count 0 inner count 1 outer

while count lt 2 do begin
	
	;output array
	if count eq 1 then begin
		im = fltarr(1216,1216)
		im[96:1119,96:1119] = da2
		da_in = im
	endif

	da2=da_in
	
	;cartesian pixel size
	pix_size=in.pix_size/in.rsun
	
	case count of
	0:	get_ht_pa_2d_corimp, in.naxis1, in.naxis2, in.crpix1, in.crpix2, x, y, ht, pa, pix_size=pix_size
	1:	get_ht_pa_2d_corimp, in.naxis1+192, in.naxis2+192, in.crpix1+96, in.crpix2+96, x, y, ht, pa, pix_size=pix_size
	endcase
	
	para = [0,360]
	
	;DO FIRST INNER FOV AND OCCULTER REFLECTION
	if in.i3_instr eq 'C2' then begin
		npa = 900.
		case count of
		0:	htra = [C2_thr_inner,C2_thr_inner*2];range of reflection in Rs. I go right into center just for fun.
		1:	htra = [C2_thr_outer-(96*pix_size),C2_thr_outer]
		endcase
	endif
	if in.i4_instr eq 'C3' then begin
		npa = 360.
		case count of
		0:	htra = [C3_thr_inner, C3_thr_inner*2]
		1:	htra = [C3_thr_outer-(96*pix_size),C3_thr_outer]
		endcase
	endif

	dht=htra[1]-htra[0]
	nref=(htra[1]-htra[0])/pix_size;approximate number of cartesian pixels within reflection depth 

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
			if h[i,j] ne 0 then imp[i,j] = total(da_in[ri[ri[index]:ri[index+1]-1]]) / h[i,j]
		endfor
	endfor
	
	;interpolate polar array back into appropriate region inside occulter
	case count of
	0:	begin
		index=where_limits(ht,htra[0]-dht,htra[0]);identify appropriate pixels inside cartesian occulter
		htnow=ht[index] & panow=pa[index];extract spatial information
		htnow = 2*htra[0]-htnow
		end
	1:	begin
		index=where_limits(ht,htra[1],htra[1]+dht);identify appropriate pixels inside cartesian occulter
		htnow=ht[index] & panow=pa[index];extract spatial information
		htnow=2*htra[1]-htnow;modify htnow so reflection works
		end
	endcase
	;calculate position of each appropariate cartesian pixel within polar array
	ipa=interpol(indgen(npa),pa_polar,panow)
	iht=interpol(indgen(nref),ht_polar,htnow)
	
	;interpolate
	da2[index]=interpolate(imp,ipa,iht,cubic=-0.5)
	
	;similar approach for outer edges
	;also need to expand data array to make room for outer reflection, probably right at start of this program?	
	
	count += 1

endwhile	

; Masking off the occulter arm of C3.

if in.i4_instr eq 'C3' then begin
	da2_r = reverse(da2, 1) ;flip horizontally
	da2_r = rot(da2_r, 99, 1, in.crpix1+96, in.crpix2+96, /interp)
	inds = where(da2 eq 0)
	da2[inds] = da2_r[inds]
	delvarx, da2_r, inds
endif


return, da2

end
