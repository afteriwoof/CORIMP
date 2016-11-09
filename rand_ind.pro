;+
; NAME:
;       rand_ind
;
; PURPOSE:
;       Return random array of indices  
;
; EXPLANATION:
;		Generates nnums of random numbers between 0 and maxind
;
; CALLING SEQUENCE:
;       ran = rand_ind(maxind, [nnums])
;
;		ran = rand_ind(maxind) [then assumes nnums = maxind]
;		
; INPUTS:
;		maxind - highest number index to generate
;               
; OUTPUTS:
;		Array of length nnums, or random numbers between 0 and maxind
;
;		Will return -1 on error 
;
; EXAMPLE
;		data = dingen(20)
;		rand_data = data[rand_ind(n_elements(data))]
;
;		rand_nos = rand_ind(10, 100000)
;
; RESTRICTIONS
;		Will not work for numbers below one!
;
; AUTHOR:
;		Shane Maloney 18/07/2009
;-

function rand_ind, maxind, nnums
; Error trapping
  if (n_params() eq 0) then begin
     Print, 'Need to supply at least one argument: maxind'
     return, -1
  endif else if (n_params() ne 2 ) then nnums = maxind
  
  if (maxind lt 1.0) then begin
     print, 'maxind must be greater or equal to 1.0d'
     return, -1
  endif
  
; Generate 10 time to many data points
  rand = round( randomu(seed, nnums*10.0d, /double)*(maxind+2.0d) ) - 1.0d
  
; Find where le maxind to fix problem with floor
  gd = where(rand le double(maxind) and rand ge 0.0d )
  rand=rand[gd]
  
;Only return the correct number of data points
  if (n_elements(gd) lt nnums) then begin
     print, "Uh oh . . . . "
     return, -1
  endif
  rand=rand[0:nnums-1]
  return, rand
end
