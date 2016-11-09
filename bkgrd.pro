; Caculates the background image from the Lasco archives by the median pixels of the 'month'

; Last edited: 29-06-07

pro bkgrd, path, corrected;, sav=sav, xdisp=xdisp

fls = file_search(path)
mreadfits, fls, in, da

; background image
tempim = readfits(fls[0], hdr)
bkgrd = getbkgimg(hdr, bkgrd_hdr, /ffv)

;if keyword_set(sav) then begin
	save, bkgrd, f='bkgrd.sav'
	save, bkgrd_hdr, f='bkgrd_hdr.sav'
;endif
	
plot_image, bkgrd

sz = size(da, /dim)

corrected = fltarr(sz[0], sz[1], sz[2])

for i=0,sz[2]-1 do begin
	corrected[*,*,i] = da[*,*,i] - bkgrd
	;writefits, 'bkgrdsub'+i, corrected[*,*,i], in[i]
endfor

;if keyword_set(xdisp) then begin
;	xstepper, corrected, xs=500
;endif



end
