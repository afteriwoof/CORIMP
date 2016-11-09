; Created	2014-09-30	to inspect the kinematics stats for the detections on gail.

; INPUTS	fitting		the fitting method to be inspected (sav_gol, quadratic, linear, or all).



pro inspect_kins_stats_gail, startdate, enddate, fitting=fitting, tog=tog

;startdate = '2001/01/01'
;enddate = '2001/12/31'
fitting = 'sav_gol'

filepath = '/volumes/store/processed_data/soho/lasco/detections'

dates = anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11)
days = anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11,/da)

; Count up the months
; structure:  month.yyyymm = x
yyyymm = strmid(days[uniq(strmid(days,0,7),sort(strmid(days,0,7)))],0,7)
for i=0,n_elements(yyyymm)-1 do yyyymm[i] = strjoin(strsplit(yyyymm[i],'/',/extract))
; intialise structure variables
velmeans = dblarr(n_elements(yyyymm))
velmedians = dblarr(n_elements(yyyymm))
kins_stats = {date:yyyymm, vel_mean:velmeans, vel_median:velmedians}

case fitting of 
	'sav_gol': 	fl = 'savgol'
	'quadratic':	fl = 'quadratic'
	'linear':	fl = 'linear'
	'all':		fl = ''
endcase

textfls = file_search(filepath+'/'+days+'/cme_kins/*'+fl+'*txt')

; Commenting out the possible use of fitting='all'
;if fitting eq 'all' then begin
;	ind=([where(strmatch(fls,'*linear*') eq 1),where(strmatch(fls,'*quadratic*') eq 1),where(strmatch(fls,'*savgol*') eq 1)])
;	ind = ind[sort(ind)]
;	fls = fls[ind]
;	textfls = textfls[ind]
;endif

; Find the sav files corresponding to the detections worthy of a text file.
fls = strarr(n_elements(textfls))
for i=0,n_elements(textfls)-1 do fls[i] = file_search(strmid(textfls[i],0,strlen(textfls[i])-4)+'*sav')

keep_fls = -1
for i=0,n_elements(fls)-1 do begin & $
	; Check the 'strength' of the CME. & $
	readcol, textfls[i], date_tmp, h_tmp, ang_tmp, nlines=nlines, f='(A,D,I)',/silent & $
	if nlines ge 100 then keep_fls=[keep_fls,i] & $
endfor
fls = fls[keep_fls[1:*]]

; Loop over the months
for i=0,n_elements(yyyymm)-1 do begin & $
	tmp = where(strmatch(fls,'*'+yyyymm[i]+'*') eq 1,cnt)
	if cnt eq 0 then goto, skip1
	fls_now = fls[where(strmatch(fls,'*'+yyyymm[i]+'*') eq 1)] & $
	velsmax = dblarr(n_elements(fls_now)) & $
	for j=0,n_elements(fls_now)-1 do begin & $
		restore, fls_now[j] & $
		velsmax[j] = cme_kins.CME_RADIALLINVELMAX & $
	endfor & $
	kins_stats.vel_mean[i] = mean(velsmax) & $
	kins_stats.vel_median[i] = median(velsmax) & $
	skip1:
endfor

save, kins_stats, f='kins_stats_'+yyyymm[0]+'-'+yyyymm[n_elements(yyyymm)-1]+'.sav'

if keyword_set(tog) then begin
	set_plot, 'ps'
	device, /encapsul, bits=8, lang=2, /color, filename='inspect_kins_stats_gail.eps', xs=15, ys=12
	!p.charsize=2	
	!p.charthick=5
	!p.thick=3
	v = kins_stats.vel_mean
	v[where(v eq 0)] /= 0
	plot, v, psym=-1, xtit='Year', xtickname=['00','01','02','03','04','05','06','07','08','09','10'], ytit='Mean speed (km s!U-1!X)'
	device, /close
endif


end
