; Created	20131004	from automated_dublin.pro

; Last edited:	20131021	to remove nested for-loops in place of Huw's loop over file dirs.


pro automated_jaydog, startdate, enddate, overwrite=overwrite

if n_params() eq 0 then print, 'Expected startdate and enddate'

dates=anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11)
days=anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11,/da)
;indir=getenv('PROCESSED_DATA')+'/soho/lasco/separated/fits/'+days
;outdir=getenv('PROCESSED_DATA')+'/soho/lasco/detections/'+days
indir = '/Volumes/Bluedisk/volumes/store/processed_data/soho/lasco/separated/fits/'+days
outdir = '/Volumes/Bluedisk/volumes/store/processed_data/soho/lasco/detections/'+days
index=where(dir_exist(indir),cntdir)
if cntdir eq 0 then begin
  print,'No directories (automated_jaydog)!!!'
  return
endif
index_many_arrays,index,dates,days,indir,outdir

for i_days=0,cntdir-1 do begin

	print, 'i_days: ', i_days

  fls = file_search(indir[i_days]+'/c[23]_lasco_soho_dynamics_*.fits.gz',count=cntfls)
  if cntfls eq 0 then begin
   print,'No files ',indir[i_days]
   continue
  endif
  
  out_dir=outdir[i_days]
  make_directories,out_dir
  make_directories,out_dir+'/cme_dets'
  make_directories,out_dir+'/cme_masks'
  print, 'out_dir: ', out_dir
  run_automated_new, fls, out_dir,/gail,overwrite=overwrite

endfor



;years = file_search('/Volumes/Bluedisk/processed_data/soho/lasco/separated/fits/2006')
;
;for i_years=0,0 do begin
;
;	months = file_search(years[i_years]+'/*')
;
;	for i_months = 9,n_elements(months)-1 do begin
;
;		days = file_search(months[i_months]+'/*')
;
;		for i_days=2,n_elements(days)-1 do begin
;		
;			fls = file_search(days[i_days]+'/*dynamics*')
;
;			out_dir = '/Volumes/Bluedisk/processed_data/soho/lasco/detections/'+$
;				strmid(days[i_days],strlen(days[i_days])-10,4)+'/'+$
;				strmid(days[i_days],strlen(days[i_days])-5,2)+'/'+$
;				strmid(days[i_days],strlen(days[i_days])-2,2)
;
;			if ~dir_exist(out_dir) then spawn, 'mkdir -p '+out_dir
;
;			print, 'out_dir: ', out_dir
;
;			run_automated_new, fls, out_dir, /gail
;
;		endfor
;
;	endfor
;
;endfor

end
