; Createed	2014-06-11	from lasco_realtime_jpb.pro to perform the latest detections and send an alert (via email).

; Last edited
;	


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



pro lasco_realtime_jpb_latest,test=test,startdate=startdate,nobackground=nobackground

; Email code start
;spawn, 'echo "lasco_realtime_jpb_latest START" | mail -s "lasco_realtime_jpb_latest" jbyrne6+corimp@gmail.com'

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

;STEP 0)
print, 'STEP 0)'
;enddate = strmid(anytim(timnow,/ccsds),0,10)
;startdate = strmid(anytim(anytim(timnow)-(60.*60.*24.),/ccsds),0,10)
enddate = tend
startdate = tstart
print, 'startdate: ', startdate
print, 'enddate: ', enddate
print, '***'

; STEP 1) Make folder 'latest/' or else empty current one.
print, 'STEP 1)'
if ~dir_exist('/home/gail/jbyrne/realtime/soho/lasco/detections/latest') then begin
	print, 'spawn, mkdir -p /home/gail/jbyrne/realtime/soho/lasco/detections/latest' 
	spawn, 'mkdir -p /home/gail/jbyrne/realtime/soho/lasco/detections/latest' 
endif else begin
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/latest/*/*/*/cme_ims*'
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/latest/*/*/*/cme_profs' 
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/latest/*/*/*/cme_kins' 
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/latest/*/*/*/rm_date*sav'
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/latest/*/*/*/pa_total*' 
	spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/latest/*/*/*/det_info*'
endelse
print, '***'

; STEP 2) Run the automated detections on the past day's separated fits files, saving the output to the 'detections/daily/' folder.
print, 'STEP 2)'
print, '*** Now run the past day`s detections but with a check in place so not to repeat any (so this code can be called multiple times a day):'
print, 'Running automated_gail_realtime:'
print, 'automated_gail_realtime, '+startdate+', '+enddate+', /home/gail/jbyrne/realtime/soho/lasco/separated/fits, /home/gail/jbyrne/realtime/soho/lasco/detections/latest'
automated_gail_realtime, startdate, enddate, '/home/gail/jbyrne/realtime/soho/lasco/separated/fits', '/home/gail/jbyrne/realtime/soho/lasco/detections/latest', test=test, /check, /latest
; where automated_gail_realtime calls run_automated_new.pro
print, '***'

; STEP 3) Join up the pa_slices from the individual detections in folder latest.
print, 'STEP 3)'
days=anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11,/da)
for i_days = 0,n_elements(days)-1 do begin
	gather_pa_slices_gail_realtime, '/home/gail/jbyrne/realtime/soho/lasco/detections/latest/'+days[i_days], det_stack
	save, det_stack, f='/home/gail/jbyrne/realtime/soho/lasco/detections/latest/'+days[i_days]+'/det_stack_'+strjoin(strsplit(days[i_days],'/',/extract))+'.sav'
endfor
print, '***'

; STEP 4) Call the automated_kins_gail_realtime to run kinematics on the latest detections.
print, 'STEP 4)'
automated_kins_gail_realtime, startdate, enddate, /originals, /latest
print, '***'

; STEP 5) Create the htmls of the latest detections.
print, 'STEP 5)'
print, 'create_html_gail_realtime, /home/gail/jbyrne/realtime/soho/lasco/detections/latest, /latest'
create_html_gail_realtime, '/home/gail/jbyrne/realtime/soho/lasco/detections/latest', /sav_gol, /latest
create_html_gail_realtime, '/home/gail/jbyrne/realtime/soho/lasco/detections/latest', /quadratic, /latest
create_html_gail_realtime, '/home/gail/jbyrne/realtime/soho/lasco/detections/latest', /linear, /latest, /mail_alert
print, '***'

; STEP 6) Sync the latest detections to alshamess for online catalog.
print, 'STEP 6)'
print, 'spawn, rsync -avuSH --delete-after -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/latest alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'
spawn, 'rsync -avuSH --delete-after -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/latest alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'
print, '***'


  ;delete original data which is older than 5 days
;  if size(dmm,/type) eq 8 then begin
;    inddelete=where(anytim2tai(dmm.date_obs) lt anytim2tai(anytim2cal(systim(),form=11))-3600.*24*5,cntdelete, $
;                    comp=ninddelete,ncomp=ncntdelete)
;    for idelete=0,cntdelete-1 do begin
;      print,'Deleting ',dmm[inddelete[idelete]].dir+'/'+dmm[inddelete[idelete]].filename
;      file_delete,dmm[inddelete].dir+'/'+dmm[inddelete].filename,/allow_nonexistent      
;    endfor
;    if ncntdelete gt 0 then dmm=dmm[ninddelete] else dmm=''
;  endif


;  i++
;print, '***' & print, 'i++ ', i & print, '***'
;endrep until i eq ifinish

jump_end:

;spawn, 'echo "lasco_realtime_jpb_latest END" | mail -s "lasco_realtime_jpb_latest" jbyrne6+corimp@gmail.com'

end
