; Code for radial filtering steps from Huw Morgan for SECCHI/LASCO

; Last Edited: 22-05-08

PRO nrgf_steps, in, da, filt

sz = size(da, /dim)

filt = fltarr(sz[0], sz[1], sz[2])


for i=0,sz[2]-1 do begin

	case in[i].detector of
	'C2':	begin
		thr1=2.2
		thr2=7
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
	
	pre_make_pos, in[i], da[*,*,i], x, y

	r = make_pos(x,y)

	index = where( r gt thr1 and r lt thr2, comp=nindex )

	im2 = nrgf(da[*,*,i], r, index)

	im2[nindex] = avg(im2[index])

	filt[*,*,i] = im2

endfor




END
