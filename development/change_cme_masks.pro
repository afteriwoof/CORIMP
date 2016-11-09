; Created	2013-02-21	to go through the folders and save out the cme_mask_str saving space over the cme_masks.

pro change_cme_masks

years = file_search('~/Postdoc_largefiles/detections_dublin/2011')

for i_years=0,0 do begin
	months = file_search(years[i_years]+'/*')
	for i_months = 1,n_elements(months)-1 do begin
		days = file_search(months[i_months]+'/*')
		;for i_days = 0,n_elements(days)-1 do begin
		for i_days = 0,1 do begin
			dir = days[i_days]
			current_year = strmid(dir,strlen(dir)-10,4)
			current_month = strmid(dir,strlen(dir)-5,2)
			current_day = strmid(dir,strlen(dir)-2,2)
			mask_fls = file_search('~/Postdoc_largefiles/detections_dublin/'+current_year+'/'+current_month+'/'+current_day+'/cme_masks/CME_mask*sav')
			for i_masks = 0,n_elements(mask_fls)-1 do begin
				restore, mask_fls[i_masks]
				cme_mask_str = cme_mask_inds(cme_mask)
				save, cme_mask_str, f=dir+'/cme_masks/cme_mask_str_'+strmid(file_basename(mask_fls[i_masks]),9,18)+'.sav'
				print, 'Saving cme_mask_str: ', dir+'/cme_masks/cme_mask_str_'+strmid(file_basename(mask_fls[i_masks]),9,18)+'.sav'
				spawn, 'rm -f '+dir+'/cme_masks/CME_mask_'+strmid(file_basename(mask_fls[i_masks]),9,18)+'.sav'
				print, 'rm '+dir+'/cme_masks/CME_mask_'+strmid(file_basename(mask_fls[i_masks]),9,18)+'.sav'
			endfor ; end i_masks
		endfor ; end i_days
	endfor ; end i_months
endfor ; end i_years



end
