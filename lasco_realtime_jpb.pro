; Createed	2014-03-19	from Huw's lasco_realtime.pro

; Last edited	2014-05-09	to include keyword daily
;		2014-05-23	to make daily the default


;Huw Morgan hmorgan@aber.ac.uk 2013/08

;top-level program for LASCO C2/C3 dynamic separation routines.
;This one is for realtime processing of latest data:
;checks for latest files and downloads/processes if available.
;
;Does not delete previously-processed data. Could be implemented but probably
;simpler just to do manually every few weeks.
;
;Only creates new backgrounds when sufficient number of new files are downloaded, OR
;sufficient time gap between background file and process file, OR
;large difference in roll angle between background and process file
; 
;Biggest flaw currently is dealing with times of spacecraft roll. For this case, 
;there will be a delay before new images are created as we wait for sufficient number of images
;after roll


; KEYWORDS	startdate	ideal format yyyy/mm/dd
;		enddate		yyyy/mm/dd


pro lasco_realtime_jpb,test=test,startdate=startdate,enddate=enddate,nobackground=nobackground

;spawn, 'echo "lasco_realtime_jpb START" | mail -s "lasco_realtime_jpb START" jbyrne6+corimp@gmail.com'

;topsave=getenv('PROCESSED_DATA')+'/realtime'
topsave = '/home/gail/jbyrne/realtime'
topbgdir=topsave+'/soho/lasco/bg_av_st'
fitsdir='/volumes/store/processed_data/soho/lasco/separated/fits'
detection_dir=topsave+'/soho/lasco/detections'

timnow=anytim2cal(systim(/utc),form=11)
tainow=anytim2tai(timnow)
tstart=anytim2cal(tainow-24.*3600.,form=11,/date)
tend=anytim2cal(tainow,form=11,/date)
if ~exist(startdate) then startdate=tstart
if exist(enddate) then tend=enddate
;i=0
;ifinish=keyword_set(test)?100:-1;endless loop - never done this deliberately before...
;repeat begin
;print, '***' & print, 'i ', i & print, '***'

;goto, jump_loop


for iinstr=0,1 do begin
	instr=iinstr eq 0?'c2':'c3'
	filter='orange'
    	f=get_latest_lasco_data_jpb(instr,startdate=startdate)
    	if f[0] ne '' then begin
      		print,'Downloaded new files '
      		print,f
    	endif
  
	print, '***' & print, 'startdate: ', startdate & print, 'tstart: ', tstart & print, 'tend: ', tend & print, '***'
    	days=anytim2cal(timegrid(tstart,tend,/days),form=11,/da)
    
    	;check for existing fits files
    	for idays=0,n_elements(days)-1 do begin & $
      		d=print_lasco_dates_jpb(days[idays],instr,/normal,count=cntfiles,/lastimage) & $
      		if cntfiles gt 0 then begin & $
        		indexist=where(file_exist(d.dir+'/'+d.filename),cntexist) & $
        		if cntexist gt 0 then build_loop_array,d[indexist],dm,reset=idays eq 0,/onedim & $
      		endif & $
    	endfor
    	cntdata=n_elements(dm)
    
    	;check for existing processed files
    	cntfilesmain=0
    	for idays=0,n_elements(days)-1 do begin & $
      		fl=file_search(fitsdir+'/'+days[idays],instr+'_lasco_soho_dynamics_*.fits.gz',count=cntfiles) & $
      		if cntfiles gt 0 then build_loop_array,fl,fm,reset=idays eq 0,/onedim & $
      		cntfilesmain=cntfilesmain+cntfiles & $
    	endfor
    	if cntfilesmain gt 0 then begin & $
      		ptai=anytim2tai(filename2date(fm)) & $
    	endif else begin & $
      		ptai=-1.e6 & $
    	endelse
    	dtai=anytim2tai(dm.date_obs)

    	processrequired=0
    	for idata=0,cntdata-1 do begin & $
      		dt=min(abs(ptai-dtai[idata])) & $
      		if dt gt 240 then begin & $;3 minutes difference
        		build_loop_array,idata,indexprocess,reset=idata eq 0,/onedim & $
        		processrequired=1 & $
      		endif & $
    	endfor
    
    	nfiles=n_elements(indexprocess)
    	if nfiles gt 0 and processrequired then begin
      
      		files=dm[indexprocess].dir+'/'+dm[indexprocess].filename
      		dates=dm[indexprocess].date_obs
      		datestart=anytim2cal(min(anytim2tai(dates)),form=11)
      		dateend=anytim2cal(max(anytim2tai(dates)),form=11)
      		daysnow=anytim2cal(timegrid(datestart,dateend,/days),form=11,/da)
      		fbg=file_search(topbgdir,instr+'lasco_bg_av_st_*.dat',count=cntbg)
      		bgrequired=0
      		if cntbg gt 0 then begin
        		taibg=yyyymmdd2cal(strmid(file_basename(fbg,'.dat'),17,14),/tai)
        		rollbg=long(strmid(file_basename(fbg,'.dat'),32,3))

        		for ifile=0,nfiles-1 do begin & $
          			void=lasco_readfits(files[ifile],hdrnow,/silent) & $
          			datenow=hdrnow.date_obs+' '+hdrnow.time_obs & $
          			dt=abs(anytim2tai(datenow)-taibg) & $
          			xbg=sin(rollbg*!dtor) & $
          			ybg=cos(rollbg*!dtor) & $
          			xdata=sin(hdrnow.crota1*!dtor) & $
          			ydata=cos(hdrnow.crota1*!dtor) & $
          			dist=sqrt((xbg-xdata)^2+(ybg-ydata)^2) & $
          			ind=where(dt/3600. le 12 and dist le 0.4,cntbgapprop) & $
          			if cntbgapprop eq 0 or nfiles gt 6 then begin & $;better make new background
            				bgrequired=1 & $
            				build_loop_array,datenow,datereqbg,reset=ifile eq 0,/onedim & $
          			endif & $
        		endfor
        		if bgrequired then begin
          			datestartbg=anytim2cal(min(anytim2tai(datereqbg)),form=11)
          			dateendbg=anytim2cal(max(anytim2tai(datereqbg)),form=11)
        		endif
      		endif else begin
        		bgrequired=1
        		datestartbg=datestart
        		dateendbg=dateend
      		endelse
      		if bgrequired and ~keyword_set(nobackground) $
      			then cme_main_process_jpb,datestartbg,dateendbg,instr,/over,/delete,/lastimage,/no_sep,/no_img
      
      		files_processed=''
      		cme_main_process_jpb,datestart,dateend,instr,/lastimage,/no_bg,nobackground=nobackground,files_processed=files_processed
      		ind_files_processed=where(~strmatch(files_processed,''),cnt_files_processed)
      		
		; skip single file detections for now (until it's working daily first)
		goto, jump1
      		cme_alert_count = 0
		for idetect=0,cnt_files_processed-1 do begin & $
        		print, 'files_processed[ind_files_processed[idetect]]) :  ', files_processed[ind_files_processed[idetect]] & $
			print, '^filename2date :  ', filename2date(file_basename(files_processed[ind_files_processed[idetect]])) & $
			print, '^strmid, 0, 10 :  ', strmid(filename2date(file_basename(files_processed[ind_files_processed[idetect]])),0,10) & $
			detection_dir_now=detection_dir+'/'+strmid(filename2date(file_basename(files_processed[ind_files_processed[idetect]])),0,10) & $
        		if ~dir_exist(detection_dir_now) then spawn, 'mkdir -p '+detection_dir_now & $
			run_automated_realtime_alert, files_processed[ind_files_processed[idetect]], detection_dir_now, cme_alert, /gail & $
			if cme_alert eq 1 then begin
				print, '*** CME ALERT ***'
				cme_alert_count += 1
				if cme_alert_count ge 3 then begin
					; edit the realtime html image
				endif
			endif else begin
				cme_alert_count = 0
			endelse
      		endfor
      		jump1:
		
		if n_elements(dm) gt 0 then dmm=size(dmm,/type) ne 8?dm:[dmm,dm]
      
    	endif;nfiles gt 0
 endfor;iinstr

 ; wait,120

jump_loop:

;***
; Now run the full past day's kinematics.
;timnow=anytim2cal(systim(/utc),form=11)
;tainow=anytim2tai(timnow)
;tstart=anytim2cal(tainow-2*24.*3600.,form=11,/date)
;tend=anytim2cal(tainow-24.*3600.,form=11,/date)

;STEP 0) Removing the previous detection folders. ; 20141002 Stop removing these (commented out)! - JPB
print, 'STEP 0)'
enddate = tend
startdate = tstart
print, 'startdate: ', startdate
print, 'enddate: ', enddate
;spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/*/*/*/cme_ims*'
;spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/*/*/*/cme_profs'
;spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/*/*/*/cme_kins'
;spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/*/*/*/rm_date*sav'
;spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/*/*/*/pa_total*'
;spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/*/*/*/det_info*'
print, '***'

; STEP 1) Empty folders 'daily/' and weekly/ for the new day's files
print, 'STEP 1)'
; If running this code more than once a day, I only want to delete the 'daily' folder contents if it's not the same day.
;test_daily = file_search(outdir+'/*/*/*')
;test_daily = test_daily[n_elements(test_daily)-1]
;test_daily = strmid(test_daily,strlen(test_daily)-10,10)
;if anytim(test_daily) gt anytim(enddate) then begin
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/daily/*' ;cleaning the daily folder of previous day's entries
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/weekly/*/*/*/cme_ims*' ;cleaning the daily folder of previous day's entries
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/weekly/*/*/*/cme_profs' ;cleaning the daily folder of previous day's entries
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/weekly/*/*/*/cme_kins' ;cleaning the daily folder of previous day's entries
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/weekly/*/*/*/rm_date*sav' ;cleaning the daily folder of previous day's entries
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/weekly/*/*/*/pa_total*' ;cleaning the daily folder of previous day's entries
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/weekly/*/*/*/det_info*' ;cleaning the daily folder of previous day's entries
;endif else begin
;	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/daily/cme_ims*'
;	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/daily/cme_profs'
;	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/daily/cme_kins'
;endelse
print, '***'

; STEP 2) Run the automated detections on the past day's separated fits files, saving the output to the 'detections/daily/' folder.
print, 'STEP 2)'
print, '*** Now run the full past day`s detections:'
print, 'Running automated_gail_realtime:'
print, 'automated_gail_realtime, '+startdate+', '+enddate+', /home/gail/jbyrne/realtime/soho/lasco/separated/fits, /home/gail/jbyrne/realtime/soho/lasco/detections/daily'
automated_gail_realtime, startdate, enddate, '/home/gail/jbyrne/realtime/soho/lasco/separated/fits', '/home/gail/jbyrne/realtime/soho/lasco/detections/daily', test=test;, /check
; where automated_gail_realtime calls run_automated_new.pro

; STEP 3) Sync those detections to the weekly folder and main realtime detections folder.
print, 'STEP 3)'
spawn, 'rsync -avuSH /home/gail/jbyrne/realtime/soho/lasco/detections/daily/ /home/gail/jbyrne/realtime/soho/lasco/detections/weekly/'
spawn, 'rsync -avuSH /home/gail/jbyrne/realtime/soho/lasco/detections/daily/ /home/gail/jbyrne/realtime/soho/lasco/detections/'
print, '***'

; STEP 4) Run the kinematic outputs of the realtime 'detections/daily/' folder.
;print, 'STEP 4)'
;print, 'automated_kins_gail_realtime, '+startdate+', '+enddate+', /originals, /daily' 
;automated_kins_gail_realtime, startdate, enddate, /originals, /daily
;print, '***'

; STEP 5) Create the htmls of the daily detections.
;print, 'STEP 5)'
;print, 'create_html_gail_realtime, /home/gail/jbyrne/realtime/soho/lasco/detections/daily, /daily'
;create_html_gail_realtime, '/home/gail/jbyrne/realtime/soho/lasco/detections/daily', /sav_gol, /daily
;create_html_gail_realtime, '/home/gail/jbyrne/realtime/soho/lasco/detections/daily', /quadratic, /daily
;create_html_gail_realtime, '/home/gail/jbyrne/realtime/soho/lasco/detections/daily', /linear, /daily
;print, '***'

; STEP 6) Sync the daily detections to alshamess for online catalog.
;print, 'STEP 6)'
;print, 'spawn, rsync -avuSH -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/ alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'
;spawn, 'rsync -avuSH -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/daily alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'
;print, '***'

; Next steps concerned with weekly
 
; STEP 7) Run the kinematics for the past week (the weekly detections were sync from the daily detections above already).
print, 'STEP 7)'
; This needs to start from a week ago.
kins_startdate = anytim2cal(tainow-24.*3600.*7.,form=11,/date)
automated_kins_gail_realtime, kins_startdate, enddate, /originals, /weekly
print, '***'

; STEP 8) Create the htmls of the weekly detections folder.
print, 'STEP 8)'
print, 'create_html_gail_realtime, /home/gail/jbyrne/realtime/soho/lasco/detections/weekly, /weekly'
spawn, 'rm -f /home/gail/jbyrne/realtime/soho/lasco/detections/weekly/*html' ;remove htmls currently in the folder.
create_html_gail_realtime, '/home/gail/jbyrne/realtime/soho/lasco/detections/weekly', /sav_gol, /weekly
create_html_gail_realtime, '/home/gail/jbyrne/realtime/soho/lasco/detections/weekly', /quadratic, /weekly
create_html_gail_realtime, '/home/gail/jbyrne/realtime/soho/lasco/detections/weekly', /linear, /weekly
print, '***'

; STEP 9) Sync the weekly detections to alshamess for online catalog.
print, 'STEP 9)'
print, 'spawn, rsync -avuSH --delete-after -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/weekly alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'
spawn, 'rsync -avuSH --delete-after -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/weekly alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'
print, '***'


; STEP 10) Sync TODAY'S latest detections and fits with the regular folder
print, 'STEP 10)'
print, 'spawn, rsync -avuSH /home/gail/jbyrne/realtime/soho/lasco/separated/fits/ /volumes/store/processed_data/realtime/soho/lasco/separated/fits/'
spawn, 'rsync -avuSH /home/gail/jbyrne/realtime/soho/lasco/separated/fits/ /volumes/store/processed_data/realtime/soho/lasco/separated/fits/'
;print, 'spawn, rsync -avuSH /home/gail/jbyrne/realtime/soho/lasco/detections/ /volumes/store/processed_data/realtime/soho/lasco/detections/'
;spawn, 'rsync -avuSH /home/gail/jbyrne/realtime/soho/lasco/detections/ /volumes/store/processed_data/realtime/soho/lasco/detections/'
print, '***'
; redundant to keep dets_dirs, so instead just delete them (in the code 7 lines down)
weekly_dets = file_search('/home/gail/jbyrne/realtime/soho/lasco/detections/weekly/*/*/*')
if n_elements(weekly_dets) gt 7 then begin
	for i=0,n_elements(weekly_dets)-8 do spawn, 'rm -rf ' + weekly_dets[i]
endif
;^if n_elements(fits_dirs) gt 30 then spawn, 'rm -r ' + fits_dirs[0:(n_elements(fits_dirs)-31)]
print, '***'

  ;delete original data which is older than 5 days
  if size(dmm,/type) eq 8 then begin
    inddelete=where(anytim2tai(dmm.date_obs) lt anytim2tai(anytim2cal(systim(),form=11))-3600.*24*5,cntdelete, $
                    comp=ninddelete,ncomp=ncntdelete)
    for idelete=0,cntdelete-1 do begin
      print,'Deleting ',dmm[inddelete[idelete]].dir+'/'+dmm[inddelete[idelete]].filename
      file_delete,dmm[inddelete].dir+'/'+dmm[inddelete].filename,/allow_nonexistent      
    endfor
    if ncntdelete gt 0 then dmm=dmm[ninddelete] else dmm=''
  endif


;  i++
;print, '***' & print, 'i++ ', i & print, '***'
;endrep until i eq ifinish

jump_end:

;spawn, 'echo "lasco_realtime_jpb END" | mail -s "lasco_realtime_jpb END" jbyrne6+corimp@gmail.com'

end
