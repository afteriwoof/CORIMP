; list = cor1_pbseries('date', 'A/B/C')

pro my_cor1_prep, list, in, da

secchi_prep, list.filename, in, da, /polariz_on, /calfac_off, /calimg_off, /rotate

sz = size(da,/dim)

for k=0,sz[2]-1 do begin
	da[*,*,k] = rm_inner_stereo(da[*,*,k],in[k],dr_px,thr=1.5)
	da[*,*,k] = fmedian(da[*,*,k], 3, 3)
endfor






end
