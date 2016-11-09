; Created	2014-03-27	from automated_dublin.pro


pro automated_gail, startdate, enddate, in_dir, out_dir, overwrite=overwrite 
;
;!path=!path+':'+expand_path('+'+'/volumes/data/solarsoft')
;!path=!path+':'+expand_path('+'+'/volumes/work/progs2009/')

;years = file_search('/volumes/store/processed_data/final/lasco_coro/separated/fits/*')
if n_params() eq 0 then begin
  startdate='2011/03/07'
  enddate='2011/03/09'
endif

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
  
  out_dir=outdir[i_days]
  make_directories,out_dir
  make_directories,out_dir+'/cme_dets'
  make_directories,out_dir+'/cme_masks'
  print, 'out_dir: ', out_dir
  run_automated_new, fls, out_dir, /gail, overwrite=overwrite

endfor


end
;
;pro automated_dublin
;
;years = file_search('~/Postdoc_largefiles/2010')
;
;for i_years=0,0 do begin
;
;	months = file_search(years[i_years]+'/*')
;
;	for i_months = 0,n_elements(months)-1 do begin
;
;		days = file_search(months[i_months]+'/*')
;
;		for i_days=0,n_elements(days)-1 do begin
;		
;			fls = file_search(days[i_days]+'/*dynamics*')
;
;			out_dir = '~/Postdoc_largefiles/detections_dublin/'$
;				+strmid(days[i_days],strpos(days[i_days],'largefiles/')+11,4)+'/'+strmid(days[i_days],$
;				strpos(days[i_days],'largefiles/')+16,2)+'/'+strmid(days[i_days],strpos(days[i_days],'largefiles/')+19,2)
;
;			if ~dir_exist(out_dir) then spawn, 'mkdir -p '+out_dir
;
;			print, 'out_dir: ', out_dir
;
;			run_automated_new, fls, out_dir;, /gail
;
;		endfor
;
;	endfor
;
;endfor
;
;end
