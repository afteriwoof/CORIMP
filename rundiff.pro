; Perform running difference on image array

; Last edited: 15-06-07

PRO rundiff, path, diffn, dafn, in

fls = file_search(path)
mreadfits, fls, in, da

; C2 data only
c2da = where(in.detector eq 'C2') ;and in.naxis1 eq 1024)
mreadfits, fls[c2da], in, c2da
ssw_fill_cube2, c2da, da

; Convert int to float
da = float(da)
dafn = da
sz = size(da, /dim)

; Remove inner disk and perform fmedian filter (slow!)
for i=0,sz[2]-1 do begin
	da[*,*,i] = rm_inner(da[*,*,i], in[i], dr_px, thr=2.2)
	dafn[*,*,i] = fmedian( (da[*,*,i]/in[i].exptime), 5, 3)
endfor

; Compute running difference
diffn = fltarr(sz[0], sz[1], sz[2]-1)
for i=0,sz[2]-2 do begin
	diffn[*,*,i] = dafn[*,*,i+1] - dafn[*,*,i]
endfor

END
