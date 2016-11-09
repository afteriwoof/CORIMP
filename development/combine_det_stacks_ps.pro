; Created	20120418	to save ps file of the combined detection stack.


pro combine_det_stacks_ps, fls, mask=mask

set_plot, 'ps'

device, /encapsul, xs=30, ys=100, bits=8, language=2, /portrait, /color, filename='combine_det_stacks.eps'

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

if keyword_set(mask) then begin
	clean_pa_total, stack, mask
	stack *= mask
endif

loadct, 39

plot_image, stack

device, /close_file


end
