; code to click around the general area of the front

; Created: 27-01-09

pro pick_out_front, im, area

sz = size(im, /dim)
plot_image, im

read, 'How many points to click? ', c

xf = dblarr(c)
yf = dblarr(c)
for k=0,c[0]-1 do begin
	print, k
	cursor, x, y, /data, /down
	xf[k] = x
	yf[k] = y
endfor

area = dblarr(sz[0],sz[1])
ind = polyfillv(xf,yf,sz[0],sz[1])
area[ind] = 1




end
