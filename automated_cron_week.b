@idl_startup.b
datetime = strsplit(systime(/utc),' ',/extract)
month = datetime[1]
year = datetime[4]
case month of & $
	'Jan':	mon='01' & $
	'Feb':	mon='02' & $
	'Mar':	mon='03' & $
	'Apr':	mon='04' & $
	'May':	mon='05' & $
	'Jun':	mon='06' & $
	'Jul':	mon='07' & $
	'Aug':	mon='08' & $
	'Sep':	mon='09' & $
	'Oct':	mon='10' & $
	'Nov':	mon='11' & $
	'Dec':	mon='12' & $
endcase
; Before I can run this within the month, the previous runs need to be deleted (kins/profs/ims etc) or it'll add to them:
spawn, 'rm -f /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/*/det_info_str*sav'
spawn, 'rm -f /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/*/pa_total*eps'
spawn, 'rm -f /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/*/rm_date*sav'
spawn, 'rm -f /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/*/*html'
spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/*/cme_kins*'
spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/*/cme_ims*'
spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/*/cme_profs'
spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/*/cme_masses'

automated_kins_gail_realtime,year+'/'+mon+'/01',year+'/'+mon+'/31',/originals
create_html_gail,'/home/gail/jbyrne/realtime/soho/lasco/detections',year+'/'+mon+'/01',year+'/'+mon+'/31',/sav_gol,/from_realtime
create_html_gail,'/home/gail/jbyrne/realtime/soho/lasco/detections',year+'/'+mon+'/01',year+'/'+mon+'/31',/quadratic,/from_realtime
create_html_gail,'/home/gail/jbyrne/realtime/soho/lasco/detections',year+'/'+mon+'/01',year+'/'+mon+'/31',/linear,/from_realtime

;;;spawn, 'rsync -avuSH --delete-after -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/ alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'+year+'/'+mon+'/'

