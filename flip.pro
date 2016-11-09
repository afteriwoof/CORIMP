; code to flip an image vertically (coz matlab outputs them upsidedown!!!)

function flip, im

sz = size(im,/dim)

temp = im

for i=0,sz[0]-1 do temp[*, abs(sz[0]-1-i)]=im[*,i]

return, temp



end
