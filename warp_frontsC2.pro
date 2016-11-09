; warping the fronts as if they were taken from distortion corrected C3 images level 1.

; Created: 27-08-08

pro warp_frontsC2, fronts, hdr, warped

sz = size(fronts, /dim)

warped = fltarr(sz[0], sz[1], sz[2])

; Which header should I read in for the warp? Is it just the level_05 or do I need to read in the calibrated level_1 ?
; seems that when i use c3_calibrate on a level_05 file it doesn't change the header anyway!

for k=0,sz[2]-1 do warped[*,*,k] = c2_warp(fronts[*,*,k], hdr[k])

end
