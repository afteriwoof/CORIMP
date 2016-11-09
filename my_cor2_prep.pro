; list = cor1_pbseries(['date'], 'A/B/C', /cor2)

; Last Edited: 08-07-08

pro my_cor2_prep, list, in, da

secchi_prep, list.filename, in, da, /polariz_on, /calfac_off, /calimg_off

sz = size(da,/dim)

for k=0,sz[2]-1 do begin
	bkg = scc_getbkgimg(in[k], outhdr=hdr) 
	da[*,*,k] = rot(da[*,*,k], -in[k].crota) - rot(bkg, -hdr.crota)
	da[*,*,k] = fmedian(da[*,*,k], 5, 3 ) ; 5,3 to remove vertical ccd lines, has to be done before rotating!!!
;	da[*,*,k] = rm_inner_stereo(da[*,*,k],in[k],dr_px,thr=2.75)
	da[*,*,k] *= mask ;restore, '~/idl_codes/cor2mask.sav'	
endfor

;filenames = strarr(sz[2])
;for k=0,sz[2]-1 do filenames[k] = in[k].date_obs




end
