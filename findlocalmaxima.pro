; Written from Alex's code in Matlab.

; Last Edited: 23-09-07

function findlocalmaxima, direction, ix, iy, mag

; This function helps with the non-maxima suppression in the Canny edge detector.
; The input parameters are:

;	direction - the index of which direction the gradient is pointing,
;		    read from the diagram below. direction is 1, 2, 3 or 4.
;	ix	  - input image filtered by derivative of Gaussian along x.
;	iy	  - input image filtered by derivative of Gaussian along y.
;	mag	  - the gradient magnitude image.

; There are 4 cases:
;
;                       The X marks the pixel in question, and each
;       3     2         of the quadrants for the gradient vector
;     O----0----0       fall into two cases, divided by the 45 
;   4 |         | 1     degree line.  In one case the gradient
;     |         |       vector is more horizontal, and in the other
;     O    X    O       it is more vertical.  There are eight 
;     |         |       divisions, but for the non-maximum supression  
;  (1)|         |(4)    we are only worried about 4 of them since we 
;     O----O----O       use symmetric points about the center pixel.
;      (2)   (3)        
;		     

sz_mag = size(mag, /dim)
m = sz_mag[0]
n = sz_mag[1]

; Find the indices of all the points whose gradient (specified by the 
; vector (ix,iy)) is going in the direction we're looking at.

case direction of
	1: idx = where((iy le 0 AND ix gt -iy) OR (iy ge 0 AND ix lt -iy))
	2: idx = where((ix gt 0 AND -iy ge ix) OR (ix lt 0 AND -iy le ix))
	3: idx = where((ix le 0 AND ix gt iy) OR (ix ge 0 AND ix lt iy))
	4: idx = where((iy lt 0 AND ix le iy) OR (iy gt 0 AND ix ge iy))
endcase

; Exclude the exterior pixels
if idx ne [-1] then begin
	v = idx mod m
	extIdx = where((v eq 1) OR (v eq 0) OR (idx le m) OR (idx gt (n-1)*m))
	max_idx = max(idx)
	if extIdx ne [-1] then idx[extIdx] = max_idx+1
	idx = idx[where(idx ne (max_idx+1))]
endif

ixv = ix[idx]
iyv = iy[idx]
gradmag = mag[idx]

;ind = array_indices(ix,idx)
;ixv = ix[ind[0,*], ind[1,*]]
;iyv = iy[ind[0,*], ind[1,*]]
;gradmag = mag[ind[0,*], ind[1,*]]

; Do the linear interpolations for the interior pixels.
case direction of
	1: begin
		d = abs(iyv/ixv)
	   	gradmag1 = mag[idx+m] * (1-d) + mag[idx+m-1] * d
		gradmag2 = mag[idx-m] * (1-d) + mag[idx-m+1] * d
	end
	2: begin
		d = abs(ixv/iyv)
		gradmag1 = mag[idx-1] * (1-d) + mag[idx+m-1] * d
		gradmag2 = mag[idx+1] * (1-d) + mag[idx-m+1] * d
	end
	3: begin
		d = abs(ixv/iyv)
		gradmag1 = mag[idx-1] * (1-d) + mag[idx-m-1] * d
		gradmag2 = mag[idx+1] * (1-d) + mag[idx+m+1] * d
	end
	4: begin
		d = abs(iyv/ixv)
		gradmag1 = mag[idx-m] * (1-d) + mag[idx-m-1] * d
		gradmag2 = mag[idx+m] * (1-d) + mag[idx+m+1] * d
	end
endcase

idxLocalMax = idx[ where((gradmag ge gradmag1) AND (gradmag ge gradmag2)) ]

return, idxLocalMax

END
