; Created:	2013-02-26	to edit the plots that are produced by plot_kins_quartiles.pro

pro change_plot_kins_quartiles

years = file_search('~/Postdoc_largefiles/detections_dublin/2011')

for i_years=0,0 do begin
        months = file_search(years[i_years]+'/*')
        for i_months = 0,n_elements(months)-1 do begin
                days = file_search(months[i_months]+'/*')
                for i_days = 0,n_elements(days)-1 do begin
                        dir = days[i_days]
			print, 'dir: ', dir
			if dir_exist(dir+'/cme_profs') then begin
				kin_fls = file_search(dir+'/cme_profs/*txt')
				if n_elements(kin_fls) ne 0 then begin
					for i = 0,n_elements(kin_fls)-1 do begin
						readcol, kin_fls[i], datetimes, heights, angs, f='A, D, F'
						if n_elements(datetimes) eq 0 then goto, jump2
						if n_elements(datetimes[uniq(datetimes,sort(datetimes))]) ge 3 then begin
							angs_init = angs
							clean_heights, datetimes, heights, angs
							test = n_elements(datetimes[uniq(datetimes,sort(datetimes))])
							if test lt 4 then goto, jump2
							plot_kins_quartiles, datetimes, heights, angs, dir+'/cme_kins_plots', /sav_gol, /plot_quartiles, /tog
						endif
						jump2:
					endfor
				endif
			endif
		endfor
	endfor
endfor


end
