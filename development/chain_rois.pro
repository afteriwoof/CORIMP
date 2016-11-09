;Created:	20111005	to chain ROIs as they add to each other in the height dimension.

pro chain_rois

restore, 'cube.sav', /ver

se = intarr(1,6)
se[*,*] = 1

flag = 0

for k=23,27 do begin

	slice = cube[*,*,k]
	slice[where(slice gt 1)] = 1
	slice_dil = dilate(slice,se)
	label = label_region(slice_dil)

	if flag ne 0 then begin
		add = prev_slice_dil + slice_dil
		inds = where(add eq 2)
		init = morph_cc(add, inds[0])
		for j=1,n_elements(inds)-1 do init+=morph_cc(add,inds[j])
		init[where(init gt 0)] = 1
		init += slice_dil
		plot_image, init
		pause
	endif

	prev_slice_dil = slice_dil		

	flag = 1
endfor	

stop

slice1 = cube[*,*,23]
slice1[where(slice1 gt 1)] = 1
se = intarr(1,6)
se[*,*] = 1
slice1_dil = dilate(slice1,se)
label1 = label_region(slice1_dil)

contour, slice1_dil, lev=1, path_xy=xy,path_info=info,/path_data_coords


slice2 = cube[*,*,24]
slice2[where(slice2 gt 1)] = 1
slice2_dil = dilate(slice2,se)
label2 = label_region(slice2_dil)

add = slice1_dil + slice2_dil

sz = size(slice1,/dim)
inds = where(slice2_dil+slice1_dil eq 2)

init = morph_cc(add,inds[0])
for k=1,n_elements(inds)-1 do init += morph_cc(add,inds[k])
init[where(init gt 0)] = 1
init += slice1_dil



end
