;Created	2013-03-28	to output a .html file for online catalogue realtime detections.

;Last edited	2014-03-31	to run on gail.
;		2014-05-23	to include keyword 'daily'
;		2014-06-05	to include keyword 'weekly'
;		2014-06-11	to include keyword 'latest'
;		2014-06-19	to include keyword 'mail_alert'

pro create_html_gail_realtime, in_dir, linear=linear, quadratic=quadratic, sav_gol=sav_gol, daily=daily, weekly=weekly, latest=latest, mail_alert=mail_alert

;years = file_search('~/Postdoc_largefiles/detections/2007')
main_path = 'http://alshamess.ifa.hawaii.edu/CORIMP'
realtime_path = main_path+'/realtime/soho/lasco/detections'
if keyword_set(daily) then realtime_path = main_path+'/realtime/soho/lasco/detections/daily'
if keyword_set(weekly) then realtime_path = main_path+'/realtime/soho/lasco/detections/weekly'
if keyword_set(latest) then realtime_path = main_path+'/realtime/soho/lasco/detections/latest'

if keyword_set(linear) then plot_name='linear'
if keyword_set(quadratic) then plot_name='quadratic'
if keyword_set(sav_gol) then plot_name='savgol'

test_html = 'realtime_'+plot_name+'.html'

test_html = 'realtime_'+plot_name+'.html'
print, 'test_html: ', test_html
print, 'file_exist(test_html): ', file_exist(test_html)
		
; put the main bit in to the html at the start if first time writing this file.
;if file_exist(test_html) eq 0 then begin
print, 'Initialising the html'
print, in_dir+'/'+test_html
openw, lun, in_dir+'/'+test_html, /get_lun
help, lun
print, 'lun: ', lun
printf, lun, '<html>'
printf, lun, '<br><title>CORIMP CME Catalog</title>'
printf, lun, '<head><style><!--A:link {text-decoration: none} A:visited {text-decoration: none} A:active {text-decoration: none} A:hover {text-decoration: underline}--></style></head>'
printf, lun, '<font size=+2 color=white><center>'
printf, lun, '<a href="'+main_path+'/index.html"><font color=white><u><< CORIMP</u></font></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' 
; Kinematic Treatment
if keyword_set(linear) then printf, lun, '<a href=realtime_savgol.html><font color=white><u>Savitsky-Golay filter</u></font></a> &nbsp;&nbsp; <a href=realtime_quadratic.html><font color=white><u>Quadratic fits</u></font></a> &nbsp;&nbsp; Linear fits </center> </font> <br>'
if keyword_set(quadratic) then printf, lun, '<a href=realtime_savgol.html><font color=white><u>Savitsky-Golay filter</u></font></a> &nbsp;&nbsp; Quadratic fits &nbsp;&nbsp; <a href=realtime_linear.html><font color=white><u>Linear fits</u></font></a> </center> </font> <br>'
if keyword_set(sav_gol) then printf, lun, ' Savitsky-Golay filter &nbsp;&nbsp; <a href=realtime_quadratic.html><font color=white><u>Quadratic fits</u></font></a> &nbsp;&nbsp; <a href=realtime_linear.html><font color=white><u>Linear fits</u></font></a> </center> </font> <br>'

;printf, lun, '<head>header text</head>'
printf, lun, '<body bgcolor=black text=black background=black>'
printf, lun, '<br><br><br><br>'
;printf, lun, '<b> <center> <font size=+3 color=white> CORIMP LASCO CME CATALOGUE </font> </center> </b> <br>'
printf, lun, '<script type="text/javascript" src="http://alshamess.ifa.hawaii.edu/CORIMP/floating-1.12.js"></script>' 
printf, lun, '<div id="floatdiv" style="position:absolute; width:95%; height:0px; top:10px; right:10px; left:10px; padding:16px; z-index:10">'

printf, lun, '<table width="100%" border=2 bgcolor=white cellpadding=3> <tr>'
printf, lun, '<th width="10%" id="hd_date">Date<br>yy/mm/dd</th>'
printf, lun, '<th width="10%" id="hd_time">Time<br>[UT]</th>'
printf, lun, '<th width="8%" id="hd_cpa">Central<br>PA<br>[deg]</th>'
printf, lun, '<th width="8%" id="hd_wd">Angular<br>Width<br>[deg]</th>'
printf, lun, '<th width="8%" id="hd_v">Median<br>Speed<br>[km/s]</th>'
printf, lun, '<th width="8%" id="hd_v_max">Max Speed<br>[km/s]</th>'
printf, lun, '<th width="8%" id="hd_acc">Median Accel.<br>[m/s<sup>2</sup>]</th>'
printf, lun, '<th width="8%" id="hd_acc_max">Max Accel.<br>[m/s<sup>2</sup>]</th>'
printf, lun, '<th width="8%" id="hd_acc_min">Min Accel.<br>[m/s<sup>2</sup>]</th>'
printf, lun, '<th width="8%" id="hd_mass">Mass<br>[g]</th>'
printf, lun, '<th width="16%" id="hd_links">Movie &<br>Image Links</th>'
printf, lun, '</tr> </table> </div>'
      
printf, lun, '<script type="text/javascript"> ' 
printf, lun, 'floatingMenu.add("floatdiv",  '
printf, lun, '{  '
printf, lun, '    // Represents distance from left or right browser window border depending upon property used. Only one should be specified. ' 
printf, lun, '    // targetLeft: 10,  '
printf, lun, '    //targetRight: 10,  '
	
printf, lun, '  // Represents distance from top or bottom browser window border depending upon property used. Only one should be specified. ' 
printf, lun, ' targetTop: 75,  '
printf, lun, ' // targetBottom: 0,  '

printf, lun, '// Uncomment one of those if you need centering on X- or Y- axis. ' 
printf, lun, '//  centerX: true, '
printf, lun, ' // centerY: true,  '

printf, lun, '   // Remove this one if you do not want snap effect ' 
printf, lun, '  //  snap: true  '
printf, lun, '});  '
printf, lun, '</script>'


;printf, lun, '<div style="height:600px;overflow:auto;">'
printf, lun, '<table width="100%" border=22 bgcolor=white cellpadding=3> <tr>'
printf, lun, '<th width="10%" id="hd_date"></th>'
printf, lun, '<th width="10%" id="hd_time"></th>'
printf, lun, '<th width="8%" id="hd_cpa"></th>'
printf, lun, '<th width="8%" id="hd_wd"></th>'
printf, lun, '<th width="8%" id="hd_v"></th>'
printf, lun, '<th width="8%" id="hd_v_max"></th>'
printf, lun, '<th width="8%" id="hd_acc"></th>'
printf, lun, '<th width="8%" id="hd_acc_max"></th>'
printf, lun, '<th width="8%" id="hd_acc_min"></th>'
printf, lun, '<th width="8%" id="hd_mass"></th>'
printf, lun, '<th width="16%" id="hd_links"></th>'
printf, lun, '</tr>'

free_lun, lun


years = file_search(in_dir+'/20*')

for i_years=0,n_elements(years)-1 do begin

        months = file_search(years[i_years]+'/*')
        for i_months = 0,n_elements(months)-1 do begin
        ;for i_months = 0,0 do begin

		month_dir = months[i_months]
                current_year = strmid(month_dir,strlen(month_dir)-7,4)
                current_month = strmid(month_dir,strlen(month_dir)-2,2)

                days = file_search(months[i_months]+'/*')
                ; be sure it's only the directories and not the html
                test = strpos(days, 'html')
                test = where(test eq -1)
                days = days[test]
                print, days
		for i_days=0,n_elements(days)-1 do begin
                ;for i_days=21,21 do begin
                        dir = days[i_days]
			print, 'dir: ', dir
			;current_year = strmid(dir,strlen(dir)-10,4)
			;current_month = strmid(dir,strlen(dir)-5,2)
			current_day = strmid(dir,strlen(dir)-2,2)

			fls = file_search(dir+'/cme_kins/cme_kins_'+plot_name+'*sav')
			print, 'fls'
			print, fls
			if size(fls,/dim) eq 0 then goto, jump1

			for i=0,n_elements(fls)-1 do begin

				print, 'restore ', fls[i]
				restore, fls[i] ; restores cme_kins structure.
			
				; Skip erroneous results
				;if abs(cme_kins.cme_accelmax) gt 10000 OR abs(cme_kins.cme_accelmin) gt 10000 OR cme_kins.cme_radiallinvel eq 0 then goto, jump2
	
				fl = file_basename(fls[i])
				print, 'fl: ', fl
				openu, lun, in_dir+'/'+test_html, /get_lun, /append

				; check if there are two CMEs with the same start time
				cnt = strsplit(fl,'_')
				print, 'cnt: ', cnt
				if n_elements(cnt) eq 6 then extn=strmid(fl,cnt[5]-1,2) else extn=''
				print, 'extn: ', extn
			
				datetime = strmid(fl, cnt[3],15)
                                dateonly = strmid(fl, cnt[3],8)
                                timeonly = strmid(fl, cnt[4],6)
				print, 'datetime: ', datetime
				print, 'dateonly: ', dateonly
				print, 'timeonly: ', timeonly

				read_txt = dir+'/cme_profs/'+dateonly+'_'+timeonly+extn+'.txt'
				help, read_txt
				print, 'read_txt: ', read_txt
				print, 'file_exist(read_txt): ', file_exist(read_txt)	
				if ~file_exist(read_txt) then goto, jump2
				readcol, read_txt, date_tmp,h_tmp,ang_tmp,nlines=nlines,f='(A,D,I)'
				; Add a check on the textfile to see if it's a relatively weak detection, and if so shade it grey.
				; First get the wide angular width (before cleaning the datapoints)
				span_wide_init = max(ang_tmp)-min(ang_tmp)
				ang_tmp_shift = (ang_tmp+180) mod 360; test if it crosses 0/360
				span_wide_shift = max(ang_tmp_shift)-min(ang_tmp_shift)
				span_wide = span_wide_shift < span_wide_init	
				; then get the constrained angular width (that corresponds to the kinematics)
				span = round(cme_kins.cme_angularwidth)
				;if nlines lt 100 then goto, jump2
				flag_nokins = 0
				if (abs(cme_kins.cme_accelmax) gt 10000) OR (abs(cme_kins.cme_accelmin) gt 10000) OR (cme_kins.cme_radiallinvel eq 0) then goto, jump2
				email_alert = 0
				if (nlines lt 100) then begin
					flag_nokins = 1
					printf, lun, '<tr bgcolor=dimgray>'
					alert = 'dark grey'
				endif
				case 1 of
                               	        (span ge 90) AND (nlines gt 800) AND (max(h_tmp) gt 6000): begin
						printf, lun, '<tr bgcolor=red>'
                               	        	email_alert = 4
						alert = 'red'
						end
					(span ge 60) AND (span lt 90) AND (nlines gt 800) AND (max(h_tmp) gt 6000): begin
						printf, lun, '<tr bgcolor=orange>'
                               	        	email_alert = 3
						alert = 'orange'
						end
					(span ge 30) AND (span lt 60) AND (nlines gt 800) AND (max(h_tmp) gt 6000): begin
						printf, lun, '<tr bgcolor=yellow>'
                               	        	email_alert = 2
						alert = 'yellow'
						end
					(span le 30) AND (nlines le 800): begin
						printf, lun, '<tr bgcolor=lightgray>'
                               	        	alert = 'light grey'
						end
					else: begin
						printf, lun, '<tr>'
						email_alert = 1
                               			alert = 'white'
						end
				endcase
				; Email CME alert
				if keyword_set(mail_alert) then begin
					; Create a save of the alert datetime to check before a re-issued alert occurs
					if email_alert gt 0 then begin
						if file_exist('alert_datetimes.sav') then restore, 'alert_datetimes.sav' else alert_datetimes=' '
						temp = where(alert_datetimes eq datetime, cnt)
						if cnt eq 0 then begin
							; Twitter Alert
							tweet_date = strmid(datetime,0,4)+'/'+strmid(datetime,4,2)+'/'+strmid(datetime,6,2)+' '+strmid(datetime,9,2)+':'+strmid(datetime,11,2);+':'+strmid(datetime,13,2)
							spawn, '/home/gail/jbyrne/tweepy/commandlinetweet "Automated CME Alert (level: '+alert+') '+tweet_date+' http://alshamess.ifa.hawaii.edu/CORIMP/realtime/soho/lasco/detections/latest/realtime_savgol.html #CoronalMassEjection #SolarPhysics #Heliophysics #SpaceWeather"'
							;spawn, 'echo "'+tweet_date+'   Alert level: '+alert+'  http://alshamess.ifa.hawaii.edu/CORIMP/realtime/soho/lasco/detections/latest/realtime_savgol.html" | mail -s "CORIMP CME ALERT" jbyrne6+corimp@gmail.com' 
							;if email_alert gt 1 then spawn, 'echo "'+tweet_date+'   Alert level: '+alert+'  http://alshamess.ifa.hawaii.edu/CORIMP/realtime/soho/lasco/detections/latest/realtime_savgol.html" | mail -s "CORIMP CME ALERT" hum2@aber.ac.uk'
							if email_alert gt 1 then spawn, 'echo "'+tweet_date+'   Alert level: '+alert+'  http://alshamess.ifa.hawaii.edu/CORIMP/realtime/soho/lasco/detections/latest/realtime_savgol.html" | mail -s "CORIMP CME ALERT" jbyrne6+corimp@gmail.com -b long.daithi+corimp@gmail.com -b eoincarley+corimp@gmail.com -b hum2@aber.ac.uk'
							alert_datetimes = [alert_datetimes, datetime]
							save, alert_datetimes, f='alert_datetimes.sav'
						endif
					endif
				endif
				

				ymd_dir = current_year+'/'+current_month+'/'+file_basename(dir)
				printf, lun, '<td headers="hd_date">'
				if file_exist(dir+'/cme_ims_orig_'+dateonly+'_'+timeonly+extn+'/movie_C3.html') then $
				printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_ims_orig_'+dateonly+'_'+timeonly+extn+'/movie_C3.html" title="view LASCO event movie">' $
				else printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_ims_orig_'+dateonly+'_'+timeonly+extn+'/movie_C2.html" title="view LASCO event movie">'
				printf, lun, strmid(dateonly,0,4)+'/'+strmid(dateonly,4,2)+'/'+strmid(dateonly,6,2)				
				printf, lun, '</a> </td>'

				; Create new text file from kinematic file with added info at the top of it
				;readcol, dir+'/cme_profs/'+dateonly+'_'+timeonly+'.txt', datetimes_tmp, heights_tmp, angs_tmp, f='(A,F,I)'
				readcol, read_txt, datetimes_tmp, heights_tmp, angs_tmp, f='(A,F,I)'
				; Get out the time label
				t_label = (datetimes_tmp[where(anytim(datetimes_tmp) eq min(anytim(datetimes_tmp)))])[0]
                                t_label = strmid(t_label,0,4)+strmid(t_label,5,2)+strmid(t_label,8,2)+'_'+strmid(t_label,11,2)+strmid(t_label,14,2)+strmid(t_label,17,2)
				print, 't_label: ', t_label
				
				openw, lun2, dir+'/cme_kins/cme_kins_'+dateonly+'_'+timeonly+extn+'.txt', /get_lun
				printf, lun2, '######################'
				printf, lun2, '# CORIMP CME CATALOG #'
				printf, lun2, '######################'
				printf, lun2, '# SPACECRAFT: SOHO'
				printf, lun2, '# INSTRUMENT: LASCO'
				printf, lun2, '# DETECTOR: C2 & C3'
				printf, lun2, '# CPA: '+int2str(round(cme_kins.cme_posang1 + (cme_kins.cme_angularwidth/2)))+' [deg]'
				printf, lun2, '# AW: '+int2str(round(cme_kins.cme_angularwidth))+' ('+int2str(span_wide)+') [deg]'
				printf, lun2, '# SPEED: '+int2str(round(cme_kins.cme_radiallinvel))+' [km/s]'
				if ~keyword_set(linear) then printf, lun2, '# ACCEL: '+int2str(round(cme_kins.cme_accel))+' [m/s^2]' $
					else printf, lun2, '# ACCEL: n/a'
				if tag_exist(cme_kins,'cme_mass') then printf, lun2, '# MASS: '+int2str(round(cme_kins.cme_mass))+' [g]'
				printf, lun2, '# KINEMATIC FIT: '+plot_name
				printf, lun2, '# DATE & TIME [UT],  HEIGHT [arcsec], ANGLE [deg]' 
				; reorder by ascending timestamp
				;goto, skip_sort
				tmp = anytim(datetimes_tmp)
				ind = sort(tmp)
				datetimes_tmp = datetimes_tmp[ind]
				heights_tmp = heights_tmp[ind]
				angs_tmp = angs_tmp[ind]
				;skip_sort:
				for i_tmp=0,n_elements(datetimes_tmp)-1 do printf, lun2, strmid(datetimes_tmp[i_tmp],0,10), ' '+strmid(datetimes_tmp[i_tmp],11,8), heights_tmp[i_tmp], angs_tmp[i_tmp], f='(A,A,F,I)'
				free_lun, lun2

				printf, lun, '<td headers="hd_time">'
				;printf, lun, '<a href="'+file_basename(dir)+'/cme_profs/'+dateonly+'_'+timeonly+'.txt" title="see height-time digital file">'
				printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_kins/cme_kins_'+dateonly+'_'+timeonly+extn+'.txt" title="see height-time digital file">'
				printf, lun, strmid(timeonly,0,2)+':'+strmid(timeonly,2,2)+':'+strmid(timeonly,4,2)
				printf, lun, '</a> </td>'

				test_plot = dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.eps'
				print, 'test_plot: ', test_plot
				if file_exist(test_plot) eq 1 then spawn, 'convert -density 150x150 '+dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.eps '+dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.jpg'
				printf, lun, '<td headers="hd_cpa" align=right>'
				printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.jpg" title="view kinematic plots">'
				printf, lun, round(cme_kins.cme_posang1 + (cme_kins.cme_angularwidth/2))
				printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_wd" align=right>'
			        printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.jpg" title="view kinematic plots">'
			        printf, lun, round(cme_kins.cme_angularwidth)
				printf, lun, ' <font size="1">('+int2str(span_wide)+')</font>'
			        printf, lun, '</a> </td>'
			
				printf, lun, '<td headers="hd_v" align=right>'
			        printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.jpg" title="view kinematic plots">'
			        printf, lun, round(cme_kins.cme_radiallinvel)
			        printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_v_max" align=right>'
			        printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.jpg" title="view kinematic plots">'
			        case flag_nokins of
					0:	printf, lun, round(cme_kins.cme_radiallinvelmax)
					1:	printf, lun, '-'
				endcase
			        printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_acc" align=right>'
			        printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.jpg" title="view kinematic plots">'
			        case flag_nokins of
                                        0:      if ~keyword_set(linear) then printf, lun, round(cme_kins.cme_accel) else printf, lun, '-'
					1:	printf, lun, '-'
				endcase
			        printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_acc_max" align=right>'
			        printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.jpg" title="view kinematic plots">'
			        case flag_nokins of
                                        0:      if ~keyword_set(linear) then printf, lun, round(cme_kins.cme_accelmax) else printf, lun, '-'
					1:	printf, lun, '-'
				endcase
			        printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_acc_min" align=right>'
                                printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.jpg" title="view kinematic plots">'
                                case flag_nokins of
                                        0:      if ~keyword_set(linear) then printf, lun, round(cme_kins.cme_accelmin) else printf, lun, '-'
                                	1:	printf, lun, '-'
				endcase
				printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_mass" align=right>'
                                printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_kins/plot_kins_quartiles_'+plot_name+'_'+datetime+extn+'.jpg" title="view kinematic plots">'
                                if tag_exist(cme_kins,'cme_mass') then printf, lun, round(cme_kins.cme_mass)
                                printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_links" align=center>'	
				;printf, lun, '<a href="'+file_basename(dir)+'/pa_total_'+dateonly+'.jpg" title="view detection stack">Detection stack</a><br>'
				;printf, lun, '<a href="'+file_basename(dir)+'/cme_pngs_'+dateonly+'_'+timeonly+'/" title="view PNGs">PNG images</a><br>'
				;spawn, 'convert -density 150x150 '+dir+'/pa_total_'+dateonly+'.eps '+dir+'/pa_total_'+dateonly+'.jpg'
				;printf, lun, '<a href="'+file_basename(dir)+'/cme_masks/" title="view CME mask files">CME masks</a><br>'
				;printf, lun, '<a href="'+file_basename(dir)+'/cme_dets/" title="view CME detection files">CME detections</a>'
				;spawn, 'convert '+dir+'/cme_pngs_'+dateonly+'_'+timeonly+'/c3/*png '+dir+'/cme_pngs_'+dateonly+'_'+timeonly+'/c3/c3.gif'
				;spawn, 'convert '+dir+'/cme_pngs_'+dateonly+'_'+timeonly+'/c2/*png '+dir+'/cme_pngs_'+dateonly+'_'+timeonly+'/c2/c2.gif'
				printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_ims_orig_'+dateonly+'_'+timeonly+extn+'/movie_C3.html" title="view C3 movie">C3</a>'
				printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_ims_'+dateonly+'_'+timeonly+extn+'/movie_C3.html" title="view C3 movie (dynamic images)"><font size="1">(dyn)</font></a>'
				printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_ims_orig_'+dateonly+'_'+timeonly+extn+'/c3/" title="view C3 images"><font size="1">(ims)</font></a>'
				printf, lun, '<br>'
				printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_ims_orig_'+dateonly+'_'+timeonly+extn+'/movie_C2.html" title="view C2 movie">C2</a>'
				printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_ims_'+dateonly+'_'+timeonly+extn+'/movie_C2.html" title="view C2 movie (dynamic images)"><font size="1">(dyn)</font></a>'
				printf, lun, '<a href="'+realtime_path+'/'+ymd_dir+'/cme_ims_orig_'+dateonly+'_'+timeonly+extn+'/c2/" title="view C2 images"><font size="1">(ims)</font></a>'
				printf, lun, '<br>'
				printf, lun, '</td>'
		
				delvarx, date_tmp,h_tmp,ang_tmp
				
				jump2:

				free_lun, lun

			endfor ; end of cme_kin files
			
			jump1:

		endfor	; end of days

	endfor ; end of months
	
endfor	; end of years

openu, lun, in_dir+'/'+test_html, /append, /get_lun

printf, lun, '</tr> </table> </div>'

printf, lun, '<font size=+2 color=white><center>'
printf, lun, '<a href="'+main_path+'/index.html"><font color=white><u><< CORIMP</u></font></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
; Kinematic Treatment
if keyword_set(linear) then printf, lun, '<a href=realtime_savgol.html><font color=white><u>Savitsky-Golay filter</u></font></a> &nbsp;&nbsp; <a href=realtime_quadratic.html><font color=white><u>Quadratic fits</u></font></a> &nbsp;&nbsp; Linear fits </center> </font> <br>'
if keyword_set(quadratic) then printf, lun, '<a href=realtime_savgol.html><font color=white><u>Savitsky-Golay filter</u></font></a> &nbsp;&nbsp; Quadratic fits &nbsp;&nbsp; <a href=realtime_linear.html><font color=white><u>Linear fits</u></font></a> </center> </font> <br>'
if keyword_set(sav_gol) then printf, lun, ' Savitsky-Golay filter &nbsp;&nbsp; <a href=realtime_quadratic.html><font color=white><u>Quadratic fits</u></font></a> &nbsp;&nbsp; <a href=realtime_linear.html><font color=white><u>Linear fits</u></font></a> </center> </font> <br>'

printf, lun, ' </body> </html>'	

free_lun, lun
close, /all

end
