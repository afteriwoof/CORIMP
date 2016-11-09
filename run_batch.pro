; Created:	2013-03-05	to tar up the fits files, copy them over to dublin, and delete after.

pro run_batch, alshamess=alshamess

;!path=!path+':'+expand_path('+'+'/volumes/data/solarsoft')
;!path=!path+':'+expand_path('+'+'/volumes/work/progs2009/')

years = file_search('/volumes/store/processed_data/soho/lasco/separated/fits/2013/')
;for i_years=0,0 do begin
i_years = 0
	months = file_search(years[i_years]+'/*')
	;for i_months=0,n_elements(months)-1 do begin
	for i_months=10,10 do begin
		days = file_search(months[i_months]+'/*')
		for i_days = 0,n_elements(days)-1 do begin
			dir = days[i_days]
			print, '*****'
			print, 'dir: ', dir
			current_year = strmid(dir,strlen(dir)-10,4)
                        current_month = strmid(dir,strlen(dir)-5,2)
                        current_day = strmid(dir,strlen(dir)-2,2)
			print, 'current: ', current_year, current_month, current_day	
			;if j lt 10 then j2 = '0'+int2str_huw(j) else j2=int2str_huw(j)
		
			;spawn, 'tar -zcvf '+current_year+current_month+current_day+$
			;'origfits.tar.gz '+days[i_days]+'/original/'
			spawn, 'tar -zcvf '+current_year+current_month+current_day+$
				'fits.tar.gz '+days[i_days]

			if keyword_set(alshamess) then $
			spawn, 'scp -i /home/gail/jbyrne/.ssh/id_dsa_alshamess '+current_year+current_month+current_day+$
			'fits.tar.gz jbyrne@alshamess.ifa.hawaii.edu:fits/' $
			else $
			spawn, 'scp -i /home/gail/jbyrne/.ssh/id_dsa_jpb '+current_year+current_month+current_day+$
                        'fits.tar.gz jbyrne@dublin.ifa.hawaii.edu:/Volumes/Bluedisk/fits/'
		
			spawn, 'rm '+current_year+current_month+current_day+'fits.tar.gz'
		endfor
	endfor
;endfor

end
