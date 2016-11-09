;
;+
; NAME:
;       mlasco_readfits
;
; Version: 
;		1.0
;
; PURPOSE:
; 		Readin multiple lasco fits files and return them as an image cube, optionally wiht the 
;		headers as well
;
; CATEGORY:
;       LASCO
;
; CALLING SEQUENCE:
;       imgs = mlaso_radfits(fls [, hdrs])
;
; INPUTS:
;       fls:      string array of file names
;
; OUTPUTS:
;       imgs: images contained in fits file
;		hdrs: hdr corresponding to images
;
;RESTRICTIONS:
;		Rebin all data to be 1024 by 1024 arbitratrly, but hdrs maintain size of true image
;
;-
;

function mlasco_readfits, fls, hdrs
	dimm = n_elements(fls)
	tmpimg = lasco_readfits(fls[0], tmphdr)
	imgs = dblarr(1024, 1024, dimm)
	hdrs = replicate(tmphdr, dimm)
	for i =0, dimm-1 do begin
		tmpimg = lasco_readfits(fls[i], tmphdr)
		imgs[*,*,i] = rebin(tmpimg, 1024, 1024)
		hdrs[i] = tmphdr
	endfor
	hdrs=hdrs
	return, imgs
end