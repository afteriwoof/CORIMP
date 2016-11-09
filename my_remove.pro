function remove, im, in, inner, outer, edge

im = rm_inner(im, in, dr_px, thr=inner)
im = rm_outer(im, in, dr_px, thr=outer)
im = rm_edges(im, in, dr_px, edge=edge)

return, im

end

