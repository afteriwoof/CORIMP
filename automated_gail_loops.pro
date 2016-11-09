; Created	11-04-11	

; Last edited	20120227
;		20120322	to use run_automated_new.pro

pro automated_gail

!path=!path+':'+expand_path('+'+'/volumes/data/solarsoft')
!path=!path+':'+expand_path('+'+'/volumes/work/progs2009/')

years = file_search('/volumes/store/processed_data/soho/lasco/separated/fits/*')
;years = file_search('/volumes/store/processed_data/soho/lasco/separated_old/fits/*')
;years = file_search('/volumes/store/processed_data/stereo/secchi/separated/b/cor2/fits/2010')

;for i_years=0,n_elements(years)-1 do begin
for i_years=0,0 do begin

	months = file_search(years[i_years]+'/*')
	
	for i_months=1,n_elements(months)-1 do begin
	;for i_months=0,0 do begin
	
		days = file_search(months[i_months]+'/*')

		for i_days=0,n_elements(days)-1 do begin
		;for i_days=12,12 do begin

			fls = file_search(days[i_days]+'/*dynamics*')

		;	out_dir='/volumes/store/processed_data/soho/lasco/detections/'$
			out_dir='../detections/'$
				+strmid(days[i_days],strpos(days[i_days],'fits/')+5,4)+'/'+strmid(days[i_days],$
				strpos(days[i_days],'fits/')+10,2)+'/'+strmid(days[i_days],strpos(days[i_days],'fits/')+13,2)
		
			;out_dir='/volumes/store/processed_data/stereo/secchi/detections/b/cor2/'$
			;	+strmid(days[i_days],strpos(days[i_days],'fits/')+5,4)+'/'+strmid(days[i_days],$
			;	strpos(days[i_days],'fits/')+10,2)+'/'+strmid(days[i_days],strpos(days[i_days],'fits/')+13,2)
			
			if ~dir_exist(out_dir) then spawn, 'mkdir -p '+out_dir
	
			print, 'out_dir: ', out_dir

			run_automated_new, fls, out_dir, /gail;, /old_data
			;run_automated_new, fls, out_dir, /gail, /stereo, /behind

		endfor

	endfor

endfor


end
