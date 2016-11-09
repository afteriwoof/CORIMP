;Created	2013-03-21	to output a .html file for online catalogue.

;Last edited	


pro create_htmls, in_dir, linear=linear, quadratic=quadratic, sav_gol=sav_gol

;years = file_search('~/Postdoc_largefiles/detections_dublin/2011')
years = file_search(in_dir)

if keyword_set(linear) then plot_name='linear'
if keyword_set(quadratic) then plot_name='quadratic'
if keyword_set(sav_gol) then plot_name='savgol'

for i_years=0,0 do begin
	
	months = file_search(years[i_years]+'/*')
        ;for i_months = 0,n_elements(months)-1 do begin
        for i_months = 0,0 do begin

		month_dir = months[i_months]
		current_year = strmid(month_dir,strlen(month_dir)-7,4)
		current_month = strmid(month_dir,strlen(month_dir)-2,2)

		test_html = current_year+current_month+'_'+plot_name+'.html'
		print, 'test_html: ', test_html
		print, 'file_exist(test_html): ', file_exist(test_html)
		
		; put the main bit in to the html at the start if first time writing this file.
		;if file_exist(test_html) eq 0 then begin
	        print, 'Initialising the html'
	        openw, lun, month_dir+'/'+test_html, /get_lun
	        help, lun
		print, 'lun: ', lun
		printf, lun, '<html>'
	        printf, lun, '<br><title>CORIMP CME Catalog</title>'
        	;printf, lun, '<head>header text</head>'
        	printf, lun, '<body bgcolor=black text=black>'
        	printf, lun, '<b> <center> <font size=+3 color=white> CORIMP LASCO CME Catalog </font> </center> </b>'
		printf, lun, '<br> Kinematic treatment:'
		if keyword_set(linear) then printf, lun, '<br> <font size=+2 color=white> <center> <a href='+current_year+current_month+'_'+'savgol.html> Savitsky-Golay filter </a> &nbsp;&nbsp; <a href='+current_year+current_month+'_'+'quadratic.html>Quadratic fits</a> &nbsp;&nbsp; Linear fits </center> </font>'
		if keyword_set(quadratic) then printf, lun, '<br> <font size=+2 color=white> <center> <a href='+current_year+current_month+'_'+'savgol.html> Savitsky-Golay filter </a> &nbsp;&nbsp; Quadratic fits &nbsp;&nbsp; <a href='+current_year+current_month+'_'+'linear.html>Linear fits </a> </center> </font>'
		if keyword_set(sav_gol) then printf, lun, '<br> <font size=+2 color=white> <center> Savitsky-Golay filter &nbsp;&nbsp; <a href='+current_year+current_month+'_'+'quadratic.html>Quadratic fits</a> &nbsp;&nbsp; <a href='+current_year+current_month+'_'+'linear.html>Linear fits </a> </center> </font>'
		printf, lun, '<center> <br> <table border=1 bgcolor=white cellpadding=3> <tr>'
        	printf, lun, '<th width="120" colspan=2 id="hd_date_time">First Appearance<br>Date Time [UT]</th>'
        	printf, lun, '<th width="80" id="hd_cpa">Central<br>PA<br>[deg]</th>'
        	printf, lun, '<th width="80" id="hd_wd">Angular<br>Width [deg]</th>'
        	printf, lun, '<th width="80" id="hd_v">Speed [km/s]</th>'
        	printf, lun, '<th width="80" id="hd_v_max">Max Speed [km/s]</th>'
        	printf, lun, '<th width="80" id="hd_v_min">Min Speed [km/s]</th>'
        	printf, lun, '<th width="80" id="hd_acc">Accel. [m/s<sup>2</sup>]</th>'
        	printf, lun, '<th width="80" id="hd_acc_max">Max Accel. [m/s<sup>2</sup>]</th>'
        	printf, lun, '<th width="80" id="hd_acc_min">Min Accel. [m/s<sup>2</sup>]</th>'
        	;printf, lun, '<th width="80" id="hd_mass">Mass<br>[gram]</th>'
        	;printf, lun, '<th width="80" id="hd_ke">Kinetic<br>Energy [erg]</th>'
		printf, lun, '<th width="120" id="hd_links">Image & Detection Links</th>'
        	printf, lun, '</tr>'
        	free_lun, lun

                days = file_search(months[i_months]+'/*')
                for i_days=0,n_elements(days)-1 do begin
                ;for i_days=0,8 do begin
                        dir = days[i_days]
			;current_year = strmid(dir,strlen(dir)-10,4)
			;current_month = strmid(dir,strlen(dir)-5,2)
			current_day = strmid(dir,strlen(dir)-2,2)

			fls = file_search(dir+'/cme_kins_plots/cme_kins_'+plot_name+'*sav')
			if size(fls,/dim) eq 0 then goto, jump1

			for i=0,n_elements(fls)-1 do begin

				restore, fls[i] ; restores cme_kins structure.
				fl = file_basename(fls[i])
				openu, lun, month_dir+'/'+test_html, /get_lun, /append

				printf, lun, '<tr>'
				
				datetime = strmid(fl, strlen(fl)-19,15)
				dateonly = strmid(fl, strlen(fl)-19,8)
				timeonly = strmid(fl, strlen(fl)-10,6)

				printf, lun, '<td headers="hd_date_time">'
				printf, lun, '<a href="'+file_basename(dir)+'/cme_pngs_'+dateonly+'_'+timeonly+'/movie.html" title="view movie">'
				printf, lun, strmid(dateonly,0,4)+'/'+strmid(dateonly,4,2)+'/'+strmid(dateonly,6,2)
				printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_date_time">'
				if i lt 10 then time_end='0'+int2str(i) else time_end=int2str(i)
				printf, lun, '<a href="'+file_basename(dir)+'/cme_profs/'+strmid(dateonly,0,4)+'-'+strmid(dateonly,4,2)+'-'+strmid(dateonly,6,2)+'_'+time_end+'.txt" title="see height-time digital file">'
				printf, lun, strmid(timeonly,0,2)+':'+strmid(timeonly,2,2)+':'+strmid(timeonly,4,2)
				printf, lun, '</a> </td>'

				test_plot = dir+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.eps'
				print, 'test_plot: ', test_plot
				if file_exist(test_plot) eq 1 then spawn, 'convert -density 150x150 '+dir+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.eps '+dir+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.jpg'
				printf, lun, '<td headers="hd_cpa" align=right>'
				printf, lun, '<a href="'+file_basename(dir)+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.jpg" title="view kinematic plots">'
				printf, lun, round(cme_kins.cme_posang1 + (cme_kins.cme_angularwidth/2))
				printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_wd" align=right>'
			        printf, lun, '<a href="'+file_basename(dir)+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.jpg" title="view kinematic plots">'
			        printf, lun, round(cme_kins.cme_angularwidth)
			        printf, lun, '</a> </td>'
			
				printf, lun, '<td headers="hd_v" align=right>'
			        printf, lun, '<a href="'+file_basename(dir)+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.jpg" title="view kinematic plots">'
			        printf, lun, round(cme_kins.cme_radiallinvel)
			        printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_v_max" align=right>'
			        printf, lun, '<a href="'+file_basename(dir)+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.jpg" title="view kinematic plots">'
			        printf, lun, round(cme_kins.cme_radiallinvelmax)
			        printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_v_min" align=right>'
                                printf, lun, '<a href="'+file_basename(dir)+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.jpg" title="view kinematic plots">'
                                printf, lun, round(cme_kins.cme_radiallinvelmin)
                                printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_acc" align=right>'
			        printf, lun, '<a href="'+file_basename(dir)+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.jpg" title="view kinematic plots">'
			        printf, lun, round(cme_kins.cme_accel)
			        printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_acc_max" align=right>'
			        printf, lun, '<a href="'+file_basename(dir)+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.jpg" title="view kinematic plots">'
			        printf, lun, round(cme_kins.cme_accelmax)
			        printf, lun, '</a> </td>'

				printf, lun, '<td headers="hd_acc_min" align=right>'
                                printf, lun, '<a href="'+file_basename(dir)+'/cme_kins_plots/plot_kins_quartiles_'+plot_name+'_'+datetime+'.jpg" title="view kinematic plots">'
                                printf, lun, round(cme_kins.cme_accelmin)
                                printf, lun, '</a> </td>'

				;printf, lun, '<td headers="hd_mass" align=right>'
				;printf, lun, '</td>'

				;printf, lun, '<td headers="hd_ke" align=right>'
				;printf, lun, '</td>'
	
				printf, lun, '<td headers="hd_links" align=center>'
				printf, lun, '<a href="'+file_basename(dir)+'/pa_total.jpg" title="view detection stack">Detection stack</a><br>'
				printf, lun, '<a href="'+file_basename(dir)+'/cme_pngs_'+dateonly+'_'+timeonly+'/" title="view PNGs">PNG images</a>'
				spawn, 'convert -density 150x150 '+dir+'/pa_total.eps '+dir+'/pa_total.jpg'
				;printf, lun, '<a href="'+file_basename(dir)+'/cme_masks/" title="view CME mask files">CME masks</a>'
				;printf, lun, '<a href="'+file_basename(dir)+'/cme_dets/" title="view CME detection files">CME detections</a>'
				printf, lun, '</td>'
	
				free_lun, lun
			endfor ; end of cme_kin files
			
			jump1:

		endfor	; end of days

		openu, lun, test_html, /append, /get_lun
		printf, lun, '</tr> </table> </center> </body> </html>'	
		free_lun, lun

	endfor ; end of months
	
endfor	; end of years


end
