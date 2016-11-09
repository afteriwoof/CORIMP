pro eight_fronts, all, first, second, third, fourth, fifth, sixth, seventh, eight
 
	temp = first
	sz1 = size(first, /dim)
	for i=0,sz1[0]-1 do temp[*,abs(sz1[0]-1-i)]=first[*,i]
	im1 = temp
	delvarx, temp

	temp = second
	sz2 = size(second, /dim)
	for i=0,sz2[0]-1 do temp[*,abs(sz2[0]-1-i)]=second[*,i]
	im2 = temp
	delvarx, temp

	temp = third
	sz3 = size(third, /dim)
	for i=0,sz3[0]-1 do temp[*,abs(sz3[0]-1-i)]=third[*,i]
	im3 = temp
	delvarx, temp

	temp = fourth
	sz4 = size(fourth, /dim)
	for i=0,sz4[0]-1 do temp[*,abs(sz4[0]-1-i)]=fourth[*,i]
	im4 = temp
	delvarx, temp

	temp = fifth
	sz5 = size(fifth, /dim)
	for i=0,sz5[0]-1 do temp[*,abs(sz5[0]-1-i)]=fifth[*,i]
	im5 = temp
	delvarx, temp

	temp = sixth
	sz6 = size(sixth, /dim)
	for i=0,sz6[0]-1 do temp[*,abs(sz6[0]-1-i)]=sixth[*,i]
	im6 = temp
	delvarx, temp

	temp = seventh
	sz7 = size(seventh, /dim)
	for i=0,sz7[0]-1 do temp[*,abs(sz7[0]-1-i)]=seventh[*,i]
	im7 = temp
	delvarx, temp
	
	temp = eight
	sz8 = size(eight, /dim)
	for i=0,sz8[0]-1 do temp[*,abs(sz8[0]-1-i)]=eight[*,i]
	im8 = temp
	delvarx, temp
	
	front1 = where(im1 ne 0)
	front2 = where(im2 ne 0)
	front3 = where(im3 ne 0)
	front4 = where(im4 ne 0)
	front5 = where(im5 ne 0)
	front6 = where(im6 ne 0)
	front7 = where(im7 ne 0)
	front8 = where(im8 ne 0)
	
	ind1 = array_indices(im1, front1)
	ind2 = array_indices(im2, front2)
	ind3 = array_indices(im3, front3)
	ind4 = array_indices(im4, front4)
	ind5 = array_indices(im5, front5)
	ind6 = array_indices(im6, front6)
	ind7 = array_indices(im7, front7)
	ind8 = array_indices(im8, front8)
	
	all = [[ind1],[ind2],[ind3],[ind4],[ind5],[ind6],[ind7],[ind8]]

end
