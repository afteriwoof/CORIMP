; Created	2014-06-18	Jason P. Byrne	to perform the monthly realtime output for online catalog (built from the daily realtime detections).

; INPUTS	startdate = '2014/05/01'
;		enddate = '2014/05/31'

pro realtime_monthly, startdate, enddate


days=anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11,/da)
path = '/home/gail/jbyrne/realtime/soho/lasco/detections'
outdir = path+'/'+days

ans = ' '
read, 'Delete previous kinematic runs before proceeding? (y/n)', ans
if ans eq 'y' then begin
        print, 'Deleting any previous automated_kins.pro outputs in the file structure under ', outdir
        pause
        for ii=0,n_elements(outdir)-1 do begin
                spawn, 'rm -f '+outdir[ii]+'/det_info_str*sav'
                spawn, 'rm -f '+outdir[ii]+'/pa_total*.eps'
                spawn, 'rm -f '+outdir[ii]+'/rm_date*sav'
                spawn, 'rm -f '+outdir[ii]+'/*html'
                spawn, 'rm -rf '+outdir[ii]+'/cme_kins*'
                spawn, 'rm -rf '+outdir[ii]+'/cme_ims*'
                spawn, 'rm -rf '+outdir[ii]+'/cme_profs'
                spawn, 'rm -rf '+outdir[ii]+'/cme_masses'
        endfor
endif


automated_kins_gail_realtime, startdate, enddate, /originals

create_html_gail, '/home/gail/jbyrne/realtime/soho/lasco/detections', startdate, /sav_gol, /from_realtime
create_html_gail, '/home/gail/jbyrne/realtime/soho/lasco/detections', startdate, /quadratic, /from_realtime
create_html_gail, '/home/gail/jbyrne/realtime/soho/lasco/detections', startdate, /linear, /from_realtime

spawn, 'rsync -avuSH --delete-after -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/'+strmid(startdate,0,4)+' alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'




end
