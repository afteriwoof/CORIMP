; Created	2014-02-12	to take out the CME mass info from Huw's files.

; INPUT		- path		the path to the directory containing the detections (cme_dets, cme_masks, cme_masses, etc).
;		- datetimes_in	the dates&times corresponding to the days covered by a CME detection.
;		- pos_angles_in	the position angles in the CME detection.
;		

pro cmemass, path, datetimes_in, pos_angles_in

goto, skip1

; initialise variables
datetimes = datetimes_in
pos_angles = pos_angles_in

; Determine the CME mass files that need to be restored.
dates = strmid(datetimes,0,10)
dates = dates[uniq(dates)]
mass_fls = strarr(n_elements(dates))
for i=0,n_elements(dates)-1 do mass_fls[i] = file_search(path+'/'+dates[i]+'/cme_masses/*'+strjoin(strsplit(dates[i],'/',/extract))+'*')

skip1:
mass_fls = file_search('~/Postdoc/Automation/Test/cmemasses/*dat')
restore, mass_fls[0]

loop_flag = 0
; Gather the datetimes from the relevant mass files
for i=0,n_elements(mass_fls)-1 do begin
	restore, mass_fls[i]
	datetimes_mass = strmid(mmain.date,0,10)+'T'+strmid(mmain.date,11,8)
	datetimes = datetimes_mass
	for j=0,n_elements(datetimes)-1 do begin
		ind = where(datetimes_mass eq datetimes[j])
		datetimes_now = datetimes_mass[ind]
		mass_now = mmain[ind].mass
		angs_now = (where(mass_now ne 0)) / 2.
		if where(mass_now ne 0) eq [-1] then goto, jump1
		mass_now = mass_now[where(mass_now ne 0)]
		if loop_flag eq 0 then begin
			angs_list = angs_now
			mass_list = mass_now
			datetimes_list = replicate(datetimes_now, n_elements(angs_now))
			loop_flag = 1
		endif else begin
			angs_list = [angs_list, angs_now]
			mass_list = [mass_list, mass_now]
			datetimes_list = [datetimes_list, replicate(datetimes_now, n_elements(angs_now))]
		endelse
		jump1:
	endfor
endfor
	
utbase = min(anytim(datetimes_list))

utplot, datetimes_list, mass_list, utbase, psym=1, ytit='Mass', /nodata

for i=min(angs_list),max(angs_list) do begin
	pos_ind = where(abs(angs_list-i) lt 0.5, cnt)
	if cnt gt 1 then begin
		outplot, datetimes_list[pos_ind], mass_list[pos_ind], color=(i-min(angs_list))*(255./(max(angs_list)-min(angs_list))), psym=1

	endif
endfor

ticknames = int2str(fix((((indgen(7))*((max(angs_list)-min(angs_list))/6)+min(angs_list))+180) mod 360))
colorbar, ncol=255,pos=[0.4,0.93,0.7,0.945], tickinterval=6, tickname=ticknames, $
	tit='Position Angle (deg.)', charsize=1, xtit=''


end
