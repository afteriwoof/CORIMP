; My recipe for all the steps which must be employed in obtaining CME model.

; Inputs:
;	in - index/header file
;	da - data array/image
;	front1 - the front or first part of front from Matlab .png
;	front2 - the second part of front if it exists

; Last Edited: 13-07-07

pro my_recipe, in, da, front1, front2, front3, splitfront=splitfront

;********
	; Background subtraction must be performed on Lasco
	; Saves the bkgrd.sav and the bkgrd_hdr.sav into the current directory.

;********
	; pb/totb files must be made from Stereo data: stereo_prep.pro
	; The data must be normalised with fmedian noise filter, and rm_inner, rm_outer: stereo_norm.pro

;********
	; Matlab is used to perform Alex's recipe for front detection in WTMM.
	; read_da.m and CMEfront.m perform the wavelet and WTMM edge detections.
	; Must take out the front by eye (eg: fronts_18apr00.m) and save as .png
	
;********
	; Front is then read into IDL as follows
	; split front must call either full_fronts for two parts, or lots_fronts for more.
	; Then with the complete front must call front_ell to fit ellipse.

	
	if keyword_set(splitfront) then begin	
		;lots_fronts, all, front1, front2, front3
		full_fronts, front1, front2, all
		front = all
		front_full_ell, front, in, da
	endif else begin
		front_ell_info, front1, in, da
	endelse


end
