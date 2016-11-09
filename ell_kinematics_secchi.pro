; Code which calls the front_ell_kinematics_secchi.pro and gathers the ellipse kinematics into a text file.

; fronts is the front edges which need to be restored.

; Last Edited: 16-04-08

pro ell_kinematics_secchi, in, da, fronts, errs, ang, kins, mov

sz = size(da,/dim)
window, 0, xs=800, ys=800
mov = fltarr(800,800,sz[2])

kins = fltarr(sz[2], 6)

;my_fronts=fltarr(sz[0],sz[1],sz[2])

openw, lun, /get_lun, 'write_kins.txt', error=err
free_lun, lun

for k=0,sz[2]-1 do begin
	
	front_ell_kinematics_secchi, fronts[*,*,k], errs[k], in[k], da[*,*,k], ang, ell_info, r_err, xe, ye, perror, max_h_front
	;front_ell_kinematics_nonflip, fronts[*,*,k], errs[k], in[k], da[*,*,k], ang, ell_info, r_err, no1,no2,no3,x_front, y_front, perror
	mov[*,*,k] = tvrd()
	
	;front_ell_kinematics2, fronts[*,*,k], in[k], da[*,*,k], ang, ell_info
	
	for i=0,5 do kins[k,i] = ell_info[i]
	
	openu, lun, 'write_kins.txt', /append
	;printf, lun, ell_info[0], ell_info[1], ell_info[2], ell_info[3], ell_info[4], $
		;ell_info[5], in[k].detector, in[k].date_d$obs, in[k].time_d$obs, r_err, in[k].exptime, perror[4]
	if in[0].exptime ne -1 then printf, lun, ell_info[0], ell_info[1], ell_info[2], ell_info[3], ell_info[4], $
		ell_info[5], in[k].detector, in[k].date_obs, r_err, in[k].exptime, perror[4], errs[k]*in[k].cdelt1, $
		perror[4]*(180/!pi), max_h_front

	if in[0].exptime eq -1 then printf, lun, ell_info[0], ell_info[1], ell_info[2], ell_info[3], ell_info[4], $
		ell_info[5], in[k].detector, in[k].date_obs, r_err, in[k].expcmd, perror[4], errs[k]*in[k].cdelt1, $
		perror[4]*(180/!pi), max_h_front
	
	free_lun, lun

	;temp=fltarr(sz[0],sz[1])
	;temp[x_front,y_front]=1
	;plot_image, temp
	;pause
	;my_fronts[*,*,k] = temp
endfor

;save, my_fronts, f='my_fronts2.sav'

end
