; Code which calls the front_ell_kinematics.pro and gathers the ellipse kinematics into a text file.

; fronts is the front edges which need to be restored.

; Last Edited: 10-12-08  to include save_ells keyword for saving the xe,ye coords of ellipse fit.
; Last Edited: 25-02-09 to include max_h_ell

pro ell_kinematics, in, da, fronts, errs, kins, mov, noplot=noplot, noflank=noflank, save_ells=save_ells

ang = 2

if keyword_set(noplot) then noplot=1 else noplot=0

sz = size(da,/dim)
if noplot eq 0 then begin
	window, 0, xs=800, ys=800
	mov = fltarr(800,800,sz[2])
endif

kins = fltarr(sz[2], 6)

if keyword_set(save_ells) then xy_ells = fltarr(101,sz[2],2)

openw, lun, /get_lun, 'write_kins.txt', error=err, width=500
free_lun, lun

openu, lun, 'write_kins.txt', /append
printf, lun, '# SEMIMAJOR, SEMIMINOR, TILT, ANGULAR_WIDTH, HEIGHT_CENTRE, HEIGHT_APEX, INSTR, DATE, TIME, HEIGHT_ERR, EXP_TIME, TILT_ERR, MAG_ERR, TILT_ERR*180/PI, MAX_H_FRONT, MAX_H_ELL, APEX_ANGLE'
free_lun, lun

for k=0,sz[2]-1 do begin
	
	if keyword_set(noflank) then begin
		front_ell_kinematics, fronts[*,*,k], errs[k], in[k], da[*,*,k], ang, ell_info, r_err, xe, ye, perror, max_h_front, max_h_ell, apex_a, noplot, /noflank
	endif else begin
		front_ell_kinematics, fronts[*,*,k], errs[k], in[k], da[*,*,k], ang, ell_info, r_err, xe, ye, perror, max_h_front, max_h_ell, apex_a, noplot
	endelse
		
	if noplot eq 0 then mov[*,*,k] = tvrd()

	if keyword_set(save_ells) then begin
		xy_ells[0:100,k,0] = xe[*]
		xy_ells[0:100,k,1] = ye[*]
	endif
	
	for i=0,5 do kins[k,i] = ell_info[i]
	
	openu, lun, 'write_kins.txt', /append

	if tag_exist(in, 'date_d$obs') eq 1 then begin
		if in[k].instrume eq 'LASCO' then printf, lun, ell_info[0], ell_info[1], ell_info[2], ell_info[3], ell_info[4], ell_info[5], in[k].detector, ' ', in[k].date_d$obs, in[k].time_d$obs, r_err, in[k].exptime, perror[4], errs[k]*in[k].platescl, perror[4]*(180/!pi), max_h_front, max_h_ell, apex_a
	endif else begin
		if in[k].instrume eq 'LASCO' then printf, lun, ell_info[0], ell_info[1], ell_info[2], ell_info[3], ell_info[4], ell_info[5], in[k].detector, ' ', in[k].date_obs, r_err, in[k].exptime, perror[4], errs[k]*in[k].platescl, perror[4]*(180/!pi), max_h_front, max_h_ell, apex_a
	endelse

	if in[k].instrume eq 'SECCHI' then begin
		
		if in[k].exptime ne -1 then printf, lun, ell_info[0], ell_info[1], ell_info[2], ell_info[3], ell_info[4], ell_info[5], in[k].detector, ' ', in[k].date_obs, r_err, in[k].exptime, perror[4], errs[k]*in[k].cdelt1, perror[4]*(180/!pi), max_h_front, max_h_ell, apex_a
		
		if in[k].exptime eq -1 then printf, lun, ell_info[0], ell_info[1], ell_info[2], ell_info[3], ell_info[4], ell_info[5], in[k].detector, ' ', in[k].date_obs, r_err, in[k].expcmd, perror[4], errs[k]*in[k].cdelt1, perror[4]*(180/!pi), max_h_front, max_h_ell, apex_a

	endif
		
	free_lun, lun

endfor

if keyword_set(save_ells) then save, xy_ells, f='xy_ells.sav'

end
