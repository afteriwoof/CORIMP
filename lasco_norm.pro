
; Last edited: 30-06-08

PRO lasco_norm, in, da, dafn

; C2 data only
ssw_fill_cube2, da, da

; Convert int to float
dafn = da
sz = size(da, /dim)

; Remove inner disk and perform fmedian filter (slow!)
for i=0,sz[2]-1 do begin
	; background subtraction
	im = getbkgimg(in[i])
	da[*,*,i] = da[*,*,i] - im
	if in[i].detector eq 'C2' then da[*,*,i] = rm_inner(da[*,*,i], in[i], dr_px, thr=2.2)
	if in[i].detector eq 'C3' then da[*,*,i] = rm_inner(da[*,*,i], in[i], dr_px, thr=4.)
	dafn[*,*,i] = fmedian( (da[*,*,i]/in[i].exptime), 3, 3)
endfor

; Have to correct for warp using c2_warp.pro



END
