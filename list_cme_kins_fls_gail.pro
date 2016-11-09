; Created	2014-09-30	to list the cme_kins files on gail, split by CME strength (e.g., red, orange, ..., grey).

; INPUTS	startdate
;		enddate
;		fitting		the fitting method to be inspected (sav_gol, quadratic, linear, or all).
;		strength	the strength of the CME detection (red, orange, yellow, etc).


pro list_cme_kins_fls_gail, startdate=startdate, enddate=enddate, fitting=fitting, strength=strength

startdate = '2000/01/01'
enddate = '2000/01/07'

dates = anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11)
days = anytim2cal(timegrid(startdate+' 00:00',enddate+' 23:59',/days),form=11,/da)

filepath = '/volumes/store/processed_data/soho/lasco/detections'

case fitting of
        'sav_gol':      fl = 'savgol'
        'quadratic':    fl = 'quadratic'
        'linear':       fl = 'linear'
        'all':          fl = ''
endcase

textfls = file_search(filepath+'/'+days+'/cme_kins/*'+fl+'*txt')





end
