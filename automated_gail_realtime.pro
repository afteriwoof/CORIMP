; Created	2014-03-27	from automated_dublin.pro

; Last edited	2014-05-23	to include keyword 'test' for testing a subset
;				and keyword check for not running detections already run.
; 		2014-06-11	to include keyword 'latest' for running single detections, obtaining pa_slice (and send email alerts).

pro automated_gail_realtime, startdate, enddate, in_dir, out_dir, overwrite=overwrite, test=test, check=check, latest=latest

dates=anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11)
days=anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11,/da)

if ~exist(in_dir) then indir=getenv('PROCESSED_DATA')+'/soho/lasco/separated/fits/'+days $
	else indir=in_dir+'/'+days

if ~exist(out_dir) then outdir=getenv('PROCESSED_DATA')+'/soho/lasco/detections/'+days $
	else outdir=out_dir+'/'+days

index=where(dir_exist(indir),cntdir)
if cntdir eq 0 then begin
	print,'No directories (automated_gail)!!!'
	return
endif
index_many_arrays,index,dates,days,indir,outdir

for i_days=0,cntdir-1 do begin
	
	fls = file_search(indir[i_days]+'/c[23]_lasco_soho_dynamics_*.fits.gz',count=cntfls)
	if cntfls eq 0 then begin
		print,'No files ',indir[i_days]
		continue
	endif
	
	; Check for already performed detections
	if keyword_set(check) then begin
		print, 'CHECK'
		check_dir = '/home/gail/jbyrne/realtime/soho/lasco/detections/'+days[i_days]
		check_fls = strmid(file_basename(fls),strlen(file_basename(fls[0]))-23,15)
		check_dets = file_search(check_dir+'/cme_dets/*')
		check_dets = strmid(file_basename(check_dets),5,15)
		check_ind = where(check_fls ne check_dets)
		fls = fls[check_ind]
		print, 'Running for just the following files:', fls
	endif

  
	cme_alert_count = 0
	out_dir=outdir[i_days]
	make_directories,out_dir
	make_directories,out_dir+'/cme_dets'
	make_directories,out_dir+'/cme_masks'
	print, 'out_dir: ', out_dir
	if keyword_set(test) then fls=[fls[0:2],fls[n_elements(fls)-3:n_elements(fls)-1]]
	if keyword_set(latest) then begin
		for i_fls=0,n_elements(fls)-1 do begin
			print, 'i_fls '+int2str(i_fls)+' of '+int2str(n_elements(fls))
			run_automated_realtime_alert, fls[i_fls], out_dir, cme_alert, pa_slice, /gail
			if cme_alert eq 1 then cme_alert_count += cme_alert else cme_alert_count=0
			;if cme_alert_count ge 3 then spawn, 'echo "'+fls[i_fls-(cme_alert_count-1):i_fls]+'" | mail -s "CORIMP CME ALERT 3" jbyrne6+corimp@gmail.com'
		endfor
	endif else begin
  		run_automated_new_gail_realtime, fls, out_dir, /gail, overwrite=overwrite
	endelse
endfor

end
