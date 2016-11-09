; Created	2014-03-19	from Huw's get_latest_lasco_data.pro

; Last edited	2014-05-20	to include keyword 'test' for testing codes.


function get_latest_lasco_data_jpb,instmain,startdate=startdate, test=test

print, '***' & print, 'get_latest_lasco_data_jpb.pro' & print, ' '

if n_params() eq 0 then instmain=['c2','c3']

timnow=anytim2cal(systim(/utc),form=11)
print,'Current time is ',timnow
tainow=anytim2tai(timnow)

tstart=keyword_set(startdate)?anytim2cal(startdate,form=11,/date):anytim2cal(tainow-24.*3600.,form=11,/date)
print, 'tstart: ', tstart
; if testing, then add a day onto the tstart, otherwise run it to current real time.
tend=anytim2cal(tainow,form=11,/date)
print, 'tend: ', tend
dates=anytim2cal(timegrid(tstart,tend,/days,/str),form=8,/date)
dirs=strmid(dates,2,6)
ndates=n_elements(dates)

ninstr=n_elements(instmain)

print, 'dates: ', dates
print, 'dirs: ', dirs
print, 'ndates: ', ndates
print, 'ninstr: ', ninstr

;savedir=getenv('SOHO_DATA')+'/lasco/lastimage/level_05'
savedir = '/home/gail/jbyrne/soho/lasco/lastimage/level_05'
print, 'savedir: ', savedir
make_directories,savedir
toploc=savedir
local=savedir+'/'+dirs
remote='/pub/lasco/lastimage/level_05/'+dirs
site='lasco6.nascom.nasa.gov'
com=mirror_huw()

lists=[ $
'remote_user=anonymous', $
'remote_password=hmorgan@aber.ac.uk', $
'do_deletes=true', $
'max_delete_dirs=100%', $
'max_delete_files=100%', $
'passive_ftp=true' $
]

counter=0
for idate=0,ndates-1 do begin
  for iinst=0,ninstr-1 do begin
  
    inst=instmain[iinst]
    
    localnow=local[idate]+'/'+inst+'/'
    remotenow=remote[idate]+'/'+inst+'/'
    
    mirrorfilename=toploc+'/mirrorpackages_SSW'
    file_delete,mirrorfilename,/allow_nonexist
    openw,lun,mirrorfilename,/get_lun
    printf,lun,'package=SSW_'+int2str_huw(counter,3)
    for j=0,n_elements(lists)-1 do printf,lun,lists[j]
    printf,lun,'site='+site
    printf,lun,'remote_dir='+remotenow
    printf,lun,'local_dir='+localnow
    printf,lun,''

    close,lun
    free_lun,lun

    spawn,mirror_huw()+' '+mirrorfilename,a

    ind=where(strmid(a,0,3) eq 'Got' and strmatch(a,'*.fts*'),cnt)
    if cnt gt 0 then begin
      for i=0,cnt-1 do begin
        aa=strsplit(a[ind[i]],/ext)
        build_loop_array,localnow+aa[1],downloaded
      endfor
    endif

    counter++

  endfor;iinst
endfor;idate


if n_elements(downloaded) eq 0 then downloaded=''


return,downloaded

print, 'end get_latest_lasco_data_jpb.pro' & print, '***'
 

end

