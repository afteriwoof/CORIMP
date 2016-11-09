;Created	20120409	to combine the detection stacks.


function combine_det_stacks, fls

for k=0,n_elements(fls)-1 do begin

	restore, fls[k]
	if k eq 0 then begin
		stack=det_stack.stack
		sz = size(stack, /dim)
	endif else begin
		sz_add = size(det_stack.stack, /dim)
		temp = fltarr(sz[0],sz[1]+sz_add[1])
		temp[*,0:(sz[1]-1)] = stack
		temp[*,sz[1]:(sz[1]+sz_add[1]-1)] = det_stack.stack
		stack = temp
		sz = size(stack, /dim)
	endelse

endfor

return, stack

end
