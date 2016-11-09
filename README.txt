Last edited: 01/2016

CORIMP GUIDE TO CODES (AND jbyrne@GAIL.ifa.hawaii.edu & jbyrne@ALSHAMESS.ifa.hawaii.edu SETUP)


################################

Cronjob on jbyrne@gail.ifa.hawaii.edu:

#——
SHELL=/bin/bash
PATH=:/bin:/usr/bin:/usr/local/bin/
HOME=/home/gail/jbyrne
MAILTO=""

00 06 * * * cd $HOME/work_on_gail && sh script.sh 2> $HOME/work_on_gail/error.out
30 */2 * * * cd $HOME/work_on_gail && sh script_latest.sh 2> $HOME/work_on_gail/error_latest.out
00 18 6 * * cd $HOME/work_on_gail && sh script_lastmonth.sh 2> $HOME/work_on_gail/error_lastmonth.out
00 12 * * 6 cd $HOME/work_on_gail && sh script_week.sh 2> $HOME/work_on_gail/error_week.out
59 23 31 1,3,5,7,8,10,12 * cd $HOME/work_on_gail && sh script_week.sh 2> $HOME/work_on_gail/error_month.out
59 23 30 4,6,9,11 * cd $HOME/work_on_gail && sh script_week.sh 2> $HOME/work_on_gail/error_month.out
59 23 28,29 2 * cd $HOME/work_on_gail && sh script_week.sh 2> $HOME/work_on_gail/error_month.out

#——

where script.sh contains:

#——
#!/bin/sh
touch temp_script_ran.txt
/usr/local/bin/idl < automated_cron.b
#——

and script_latest.sh contains:

#——
#!/bin/sh
touch temp_script_ran_latest.txt
/usr/local/bin/idl < automated_cron_latest.b
#——

and script_week.sh contains:

#——
#!/bin/sh
touch temp_script_ran_week.txt
/usr/local/bin/idl < automated_cron_week.b
#——

and script_lastmonth.sh contains:

#—— 
#!/bin/sh
touch temp_script_ran_lastmonth.txt
/usr/local/bin/idl < automated_cron_lastmonth.b
#——

########

automated_cron.b calls:

;;;
@idl_startup.b
lasco_realtime_jpb
;;;

and automated_cron_latest.b calls:
;;;
@idl_startup.b
lasco_realtime_jpb_latest
;;;

while automated_cron_week.b calls
;;;
@idl_startup.b
datetime = strsplit(systime(/utc),' ',/extract)
month = datetime[1]
year = datetime[4]
case month of & $
        'Jan':  mon='01' & $
        'Feb':  mon='02' & $
        'Mar':  mon='03' & $
        'Apr':  mon='04' & $
        'May':  mon='05' & $
        'Jun':  mon='06' & $
        'Jul':  mon='07' & $
        'Aug':  mon='08' & $
        'Sep':  mon='09' & $
        'Oct':  mon='10' & $
        'Nov':  mon='11' & $
        'Dec':  mon='12' & $
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

spawn, 'rsync -avuSH --delete-after -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/ alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'+year+'/'+mon+'/'
;;;


and automated_cron_lastmonth.b calls

;;;
@idl_startup.b
datetime = strsplit(systime(/utc),' ',/extract)
month = datetime[1]
year = datetime[4]
if month eq 'Jan' then year=int2str(year-1)
case month of & $
        'Jan':  mon='12' & $
        'Feb':  mon='01' & $
        'Mar':  mon='02' & $
        'Apr':  mon='03' & $
        'May':  mon='04' & $
        'Jun':  mon='05' & $
        'Jul':  mon='06' & $
        'Aug':  mon='07' & $
        'Sep':  mon='08' & $
        'Oct':  mon='09' & $
        'Nov':  mon='10' & $
        'Dec':  mon='11' & $
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

spawn, 'rsync -avuSH --delete-after -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/'+year+'/'+mon+'/ alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'+year+'/'+mon+'/'
;;;

################################



***************************************************************************************************************************************


*******

TO RUN THE PAST (as opposed to realtime): 


To process automated detections from Huw’s separated files:

1) Perform the CME detections:

automated_gail, ‘yyyy/mm/dd’, ’yyyy/mm/dd’, ’/volumes/store/processed_data/soho/lasco/separated/fits', '/volumes/store/processed_data/soho/lasco/detections'

2) Derive the CME kinematics:

automated_kins_gail, ‘yyyy/mm/dd’, ‘yyyy/mm/dd’, /originals

(^asks to delete previous kinematic runs before proceeding)

3) Generate the HTMLs:

Set the in_dir with manually set loops over the startdate and enddate in this code if they run for more than one month, otherwise start and end dates can be input as follows:

create_html_gail, '/volumes/store/processed_data/soho/lasco/detections', ‘yyyy/mm/dd’, ‘yyyy/mm/dd’, /sav_gol

4) Copy via rsync to alshamess:

rsync -avnuSH —delete-after /volumes/store/processed_data/soho/lasco/detections/yyyy/mm/ alshamess:/volumes/data/data1/www/CORIMP/yyyy/mm/


*******

TO RUN THE REALTIME:


cronjob of codes run:
 
1) lasco_realtime_jpb_latest   (every few hours <— including call /mail_alert in create_html_gail_realtime to send an email alert, and tweet @CMEcatalog)

2) lasco_realtime_jpb   (every midnight)

3) lasco_realtime_jpb_week	(every Sunday for the past week within the month)

4) lasco_realtime_jpb_lastmonth (every first Sunday of the month for the last month’s detections)


lasco_realtime_jpb_latest.pro

	Downloads the fits files to /home/gail/jbyrne/soho/lasco/lastimage & bg_av_st/ & separated/
	(currently skips run_automated_realtime_alert.pro that performs single image detection alert.)

	STEPS:

	1)	Make folder 'latest/' or else empty the current one.

	2)	Run the automated detections on the past day's separated fits files, saving the output to the 'detections/daily/' folder.
		Calls automated_gail_realtime, startdate, enddate, fits dir, latest dir, /check, /latest
			/check for already performed detections
			if keyword_set(latest) then call run_automated_realtime_alert.pro on each file
				or else call run_automated_new_gail_realtime.pro on all the files.

	3)	Join up the pa_slices from the individual detections in folder latest.

	4)	Call the automated_kins_gail_realtime.pro to run kinematics on the latest detections.
			automated_kins_gail_realtime, startdate, enddate, /originals, /latest
				saves out the kinematic info (cme_kins/ , cme_profs/ , cme_im*/ , etc) to /home/gail/jbyrne/reatlime/soho/lasco/detections/latest/
			Calls (among others) clean_heights.pro, plot_kins_quartiles_gail.pro, gather_gail_detections_inset_all_device.pro

	5)	Create the htmls of the latest detections
			Calls create_html_gail_realtime, ‘/home/gail/jbyrne/realtime/soho/lasco/detections/latest’, /type of fit, /latest (, /mail_alert)

	6)	Sync the latest detections to alshamess for online catalog:
			spawn, 'rsync -avuSH --delete-after -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/latest alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'	


lasco_realtime_jpb.pro

	Downloads the fits files to /home/gail/jbyrne/soho/lasco/lastimage & bg_av_st/ & separated/

	STEPS:

	1)	Since this code is running only once a day, delete the daily/ folder of all detection info and weekly/ folder of just the kinematics info to redo for the week’s new kinematics with the new day’s detections added on.
			e.g. spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/daily/*' 
        			spawn, 'rm -rf /home/gail/jbyrne/realtime/soho/lasco/detections/weekly/*/*/*/cme_ims*'

	2)	Run the automated detections on the past day's separated fits files, saving the detection output to the 'detections/daily/' folder.
			automated_gail_realtime, startdate, enddate, fits dir, daily outdir

	3)	Sync those detections to the weekly folder and main realtime detections folder.
			spawn, 'rsync -avuSH /home/gail/jbyrne/realtime/soho/lasco/detections/daily/ /home/gail/jbyrne/realtime/soho/lasco/detections/weekly/'
			spawn, 'rsync -avuSH /home/gail/jbyrne/realtime/soho/lasco/detections/daily/ /home/gail/jbyrne/realtime/soho/lasco/detections/'

	skip to 7)	Run the kinematics for the past week: automated_kins_gail_realtime, kins_startdate, enddate, /originals, /weekly  from a week ago.

	8)	Create the htmls of the weekly detections folder.
			create_html_gail_realtime, ‘home/gail/jbyrne/realtime/soho/lasco/detections/weekly’, /type of fit, /weekly	

	9)	Sync the weekly detections to alshamess for online catalog.
			spawn, 'rsync -avuSH --delete-after -e "ssh -i /home/gail/jbyrne/.ssh/id_dsa_alshamess" /home/gail/jbyrne/realtime/soho/lasco/detections/weekly alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/'



*****

To add the monthly detections to the online catalog, after they have been populated with the weekly realtime detections:

(Open IDL in work_on_gail/ folder on jbyrne@gail.ifa.hawaii.edu and run @idl_startup.b to run ssw)

On gail run (from start date to end date): (NB I think there might be an error with this if it’s run for more than a single month)

automated_kins_gail_realtime, ‘yyyy/mm/dd’,/yyyy/mm/dd’, /originals

Then on gail run:

create_html_gail,'/home/gail/jbyrne/realtime/soho/lasco/detections’,’yyyy/mm/dd’,’yyyy/mm/‘dd, /sav_gol, /from_realtime
create_html_gail,'/home/gail/jbyrne/realtime/soho/lasco/detections','yyyy/mm/dd','yyyy/mm/dd', /quadratic, /from_realtime
create_html_gail,'/home/gail/jbyrne/realtime/soho/lasco/detections’,’yyyy/mm/dd’,’yyyy/mm/‘dd, /linear, /from_realtime

Then on gail rsync the output to alshamess:

rsync -avnuSH —delete-after /home/gail/jbyrne/realtime/soho/lasco/detections/yyyy/mm/ alshamess:/volumes/data/data1/www/CORIMP/realtime/soho/lasco/detections/yyyy/mm/

Move the relevant parts of the realtime data on gail to the folders where it’s to be stored, e.g.:

mv realtime/soho/lasco/detections/yyyy/mm /volumes/store/processed_data/realtime/soho/lasco/detections/yyyy/


Then on alshamess edit the html file to link the new month: /volumes/data/data1/www/CORIMP/index.html

***************************************************************************************************************************************

CODE DEPENDENCIES:

Last edited: 2013-07-15

**********************
run_automated_new.pro
	sort_fls.pro
		filename2date.pro
	rm_inner_corimp.pro
	rm_outer_corimp.pro
	reflect_inner_outer.pro
	canny_atrous2d.pro
		canny_atrous.pro
	wtmm.pro
		find_local_maxima.pro
	cme_detection_mask_corimp_dynamic_thr.pro
		test_contour_thresholds.pro
	cme_mask_inds.pro
run_automated2_new.pro
	medabsdev.pro
	polar.pro
	find_outer_peak_edges_new.pro
**********************	

automated_kins ;(needs to be setup for secchi data)
	read_daily_stacks.pro
	clean_pa_total.pro
	separate_pa_total.pro
	make_pa_total_plot.pro
	find_pa_heights_all_redo.pro
	find_pa_heights_masked.pro
	clean_heights.pro
	plot_kins_quartiles.pro
	gather_gail_detections_inset_all.pro
		get_ht_pa_2d_corimp.pro


;OR

automated_kins_stereo.pro
	read_daily_stacks.pro
	clean_pa_total.pro
	separate_pa_total.pro
	make_pa_total_plot.pro
	find_pa_heights_all_redo.pro
	find_pa_heights_masked.pro
	clean_heights.pro
	plot_kins_quartiles.pro
	gather_detections_cor2.pro
		get_ht_pa_2d_corimp.pro




NOTES to be done:

Need to set pa_total to save out after every N images. Right now it just saves out one for the input dataset (which is broken right now into every day on gail codes).


