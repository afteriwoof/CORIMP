; Code for radial filtereing steps from Huw Morgan for Lasco

; Created: 05-09-08

PRO nrgf_steps_one_image, in, da, filt

sz = size(da, /dim)

filt = fltarr(sz[0], sz[1])

pre_make_pos, in, da, x, y

r = make_pos(x,y)

case in.detector of
	'C2':	begin
		thr1=2.2
		thr2=8.0
		end
	'C3':	begin
		thr1=4.5
		thr2=29
		end
	'COR1':	begin
		thr1=1.5
		thr2=4.35
		end
	'COR2':	begin
		thr1=3.2
		thr2=15.
		end
	endcase

index = where( r gt thr1 and r lt thr2, comp=nindex )

im2 = nrgf(da, r, index)

im2[nindex] = avg(im2[index])

filt[*,*] = im2

END
