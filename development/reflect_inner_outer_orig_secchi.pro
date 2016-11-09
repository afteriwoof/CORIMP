; Code to reflect the outer and inner occulter masks with data

; Created: 23-06-11	from reflect_inner_outer.pro	
; Last edited:	May the 4th be with you (2011) to include steps for blending data over the C3 occulter arm. 
;		27-05-11	Changed the in.xcen and in.ycen to in.crpix1/2 everywhere.

function reflect_inner_outer_orig_secchi, in, da

COR1_thr_inner = 1.5
COR1_thr_outer = 4.25
COR2_thr_inner = 4
COR2_thr_outer = 20
;print,'Currently have C2_thr_outer set to 5.7 rather than 5.95 because of the cme model'
;print,'Currently have C3_thr_outer set to 16 rather than 19.5 because of the cme model'
da_in = da

count = 0 ;count 0 inner count 1 outer

while count lt 2 do begin
	
	;output array
	if count eq 1 then begin
		im = fltarr(600,600)
		im[44:555,44:555] = da2
		for i=44,555 do begin
			for j=0,43 do im[i,j] = da[i-44,44-j]
			for j=556,599 do im[i,j] = da[i-44,511+(556-j)]
		endfor
		for j=44,555 do begin
			for i=0,43 do im[i,j] = da[43-i,j-44]
			for i=556,599 do im[i,j] = da[511+(556-i),j-44]
		endfor
		da_in = im
	endif

	da2=da_in

	
	
	;cartesian pixel size
	pix_size=in.cdelt1/in.rsun
	
	case count of
	0:	get_ht_pa_2d_corimp, in.naxis1, in.naxis2, in.crpix1, in.crpix2, x, y, ht, pa, pix_size=pix_size
	1:	get_ht_pa_2d_corimp, in.naxis1+88, in.naxis2+88, in.crpix1+44, in.crpix2+44, x, y, ht, pa, pix_size=pix_size
	endcase
	
	para = [0,360]
	
	;DO FIRST INNER FOV AND OCCULTER REFLECTION
	case in.detector of
	'COR1':	begin
		npa = 900.
		case count of
		0:	htra = [COR1_thr_inner,COR1_thr_inner*2.];range of reflection in Rs. I go right into center just for fun.
		1:	htra = [COR1_thr_outer-(44*pix_size),COR1_thr_outer]
		endcase
		end
	'COR2':	begin
		npa = 360.
		case count of
		0:	htra = [COR2_thr_inner, COR2_thr_inner*2.]
		1:	htra = [COR2_thr_outer-(44*pix_size),COR2_thr_outer]
		endcase
		end
	endcase

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




return, da2

end
