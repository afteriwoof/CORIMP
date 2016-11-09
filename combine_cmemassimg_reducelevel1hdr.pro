; Code to take the steps from REDUCE_LEVEL_!.pro and perform them individually myself.

; Created: 27-08-08

; Last Edited: 27-08-08

pro combine_cmemassimg_reducelevel1hdr, fls, in, calibda, unwarpda

szfls = size(fls, /dim)
for k=0,szfls[0]-1 do reduce_level_1, fls[k]

init = lasco_readfits(fls[0], in_init)

sz = size(init, /dim)

da = fltarr(sz[0], sz[1], szfls[0])
sz = size(da, /dim)
delvarx, szfls

in = replicate(in_init, sz[2])

calibda = fltarr(sz[0], sz[1], sz[2])
unwarpda = calibda

; read in the data
for k=0,sz[2]-1 do begin
	tempim = lasco_readfits(fls[k], tempin)
	da[*,*,k] = tempim
	in[k] = tempin
endfor

; calibrate the data
;for k=0,sz[2]-1 do begin
;	calibda[*,*,k] = c3_calibrate(da[*,*,k], in[k])
;endfor

; get the background for the data and calibrate it
;bkg = getbkgimg(in[0], bkgin)
;bkg = c3_calibrate(bkg, bkgin)

for k=0,sz[2]-1 do calibda[*,*,k] = c3_massimg('bkgrd.fts', fls[k])

; correction for the distortion
for k=0,sz[2]-1 do begin
	unwarpda[*,*,k] = c3_warp(calibda[*,*,k], in[k])
endfor



	
end
