pro open_lasco_file_jpb,filename_or_date,instr,im,sc,rollnow,pix_size,date=date, $
      subtract_bg=subtract_bg,nrgf=nrgf,correct_roll=correct_roll,dbg=dbg,center=center,hdr=hdr, $
      nofreelun=nofreelun,htrange=htrange,point=point,calibrate=calibrate,huw_calibrate=huw_calibrate,help=help

if keyword_set(help) then begin
  print,'open_lasco_file,filename_or_date,instr,im,sc,rollnow,pix_size,date=date, $'
      print,'subtract_bg=subtract_bg,nrgf=nrgf,correct_roll=correct_roll,dbg=dbg,center=center,hdr=hdr, $'
      print,'nofreelun=nofreelun,htrange=htrange,point=point,calibrate=calibrate,huw_calibrate=huw_calibrate,help=help'
endif

;if filename_or_date contains only numbers and '/' and ':' then assume it's a date
;so must supply date in 2011/01/25 12:00 format, not 21 Jul...etc
ford=filename_or_date
swap_str,ford,['/',':'],['','']
ford=strcompress(ford,/remove_all)
isdate=1b
for i=0,strlen(ford)-1 do if ~is_number(strmid(ford,i,1)) then isdate=0b
if ~isdate then filename=filename_or_date else begin
  filename=print_lasco_dates(filename_or_date,instr,/normal)
  filename=filename.dir+'/'+filename.filename
  if ~file_exist(filename) then filename=filename+'.gz'
endelse


if ~keyword_set(nofreelun) then free_all_lun
im=lasco_readfits(filename,hdr,/silent)
instr=strlowcase(hdr.detector)
s=size(im)
if s[1] eq 1024 then full=1 else full=0
if s[1] eq 0 then stop
im=reduce_std_size_huw(im,hdr,/bias,full=full,/silent)
good=where(im gt 0,comp=bad,ncomp=nbad)
sc=adjust_hdr_tcr(hdr)
if sc.date eq '' then begin
  print,'Just using header values - adjust_hdr_tcr did not work!!!'
  sc.date=hdr.date_obs
  sc.time=hdr.time_obs
  sc.roll=hdr.crota1
  sc.xpos=hdr.crpix1
  sc.ypos=hdr.crpix2
endif 
date=sc.date+' '+sc.time

im=hdr.detector eq 'C2'?c2_warp_jpb(im,hdr):c3_warp_jpb(im,hdr)
if ~keyword_set(calibrate) then begin
  im=float(im)/hdr.exptime
  hdr.exptime=1.0
endif else begin
  im=c2_calibrate(im,hdr)
endelse


if nbad gt 0 then begin
  imbad=fltarr(s[1],s[2])
  imbad[bad]=1
  imbad=hdr.detector eq 'C2'?c2_warp_jpb(imbad,hdr):c3_warp_jpb(imbad,hdr)
  indbad=where(imbad gt 0.9)
  im[bad]=!values.f_nan
endif

rsun=(pb0r(date,/arcsec,/soho))(2)
pix_size=get_sec_pixel(hdr)/rsun
rollnow=sc.roll

if keyword_set(subtract_bg) or keyword_set(nrgf) or keyword_set(dbg) then $
dbg=read_bg_dir('c2','lasco',req_time=date,roll=rollnow,timewindow=24.*3600)

if keyword_set(correct_roll) or keyword_set(center) then begin
  if keyword_set(correct_roll) then begin
    rollcorrect=-rollnow
    rollnow=0. 
    hdr.crota=0
    hdr.crota1=0
    hdr.crota2=0
  endif else rollcorrect=0
    
  im=rot(im,rollcorrect,1,sc.xpos,sc.ypos,pivot=~keyword_set(center),missing=!values.f_nan,/interp)
  if keyword_set(center) then begin
    sc.xpos=(s[1]-1)*0.5
    sc.ypos=(s[2]-1)*0.5 
  endif
  
endif

if keyword_set(subtract_bg) and size(dbg,/type) eq 8 then begin
  bg=polar2cartesian_corimp(dbg.bg,[0,360],dbg.rra,dbg.npa,dbg.nr,s[1],s[2], $
                            sc.xpos,sc.ypos,pix_size,rollnow,/sample)
  im=im-bg
endif else print,'No bg subtracted'

if (keyword_set(nrgf) and size(dbg,/type) eq 8) or keyword_set(htrange) then $
get_ht_pa_2d_corimp,s[1],s[2],sc.xpos,sc.ypos,x,y,ht,pa,roll=rollnow,pix_size=pix_size

if keyword_set(nrgf) and size(dbg,/type) eq 8 then begin
  av=interpol(dbg.av,make_coordinates(dbg.nr,dbg.rra),ht)
  st=interpol(dbg.st,make_coordinates(dbg.nr,dbg.rra),ht)
  im=(im-av)/st
endif else print,'No NRGF applied'



if keyword_set(huw_calibrate) then begin

  im=point_filter_corimp(im,/sil)

  ;bgdir=getenv('PROCESSED_DATA')+'/soho/lasco/bg_av_st_longterm'
  bgdir='/volumes/store/processed_data/soho/lasco/bg_av_st_longterm'
  bgfiles=file_search(bgdir,instr+'lasco_bg_av_st_*.dat')
  bgstartdates=yyyymmdd2cal(strmid(file_basename(bgfiles),17,14))
  bgstarttai=anytim2tai(bgstartdates)
  bgenddates=yyyymmdd2cal(strmid(file_basename(bgfiles),32,14))
  bgendtai=anytim2tai(bgenddates)
  
  calfiles=file_search(bgdir,instr+'lasco_cal_*.dat')
  calstartdates=yyyymmdd2cal(strmid(file_basename(calfiles),12,14))
  calstarttai=anytim2tai(calstartdates)
  calenddates=yyyymmdd2cal(strmid(file_basename(calfiles),27,14))
  calendtai=anytim2tai(calenddates)
  
  tainow=anytim2tai(date)
  ;find long-term background and subtract
  ind=where(bgstarttai le tainow and bgendtai ge tainow,cnt)
  if cnt ne 0 then begin
    print,'Long-term background: ',bgfiles[ind]
    restore,bgfiles[ind]
    bg=polar2cartesian_corimp(d.bg,[0,360],d.rra,d.npa,d.nr,s[1],s[2], $
                            sc.xpos,sc.ypos,pix_size,rollnow,/sample)
    im=im-bg
  endif else begin
    print,'No Long-term background found (open_lasco_file)',date
    im=-1
    return
  endelse
  ;find long-term calibration file and calibrate
  ind=where(calstarttai le tainow and calendtai ge tainow,cnt)

  if cnt ne 0 then begin
    print,'Long-term calibration: ',calfiles[ind]
    restore,calfiles[ind]
    calmult=polar2cartesian_corimp(d.calmult,[0,360],d.rra,d.npa,d.nht,s[1],s[2], $
                              sc.xpos,sc.ypos,pix_size,rollnow,/sample)
    caldiv=polar2cartesian_corimp(d.mcal,[0,360],d.rra,d.npa,d.nht,s[1],s[2], $
                              sc.xpos,sc.ypos,pix_size,rollnow,/sample)
    caladd=polar2cartesian_corimp(d.caladd,[0,360],d.rra,d.npa,d.nht,s[1],s[2], $
                              sc.xpos,sc.ypos,pix_size,rollnow,/sample)
    im=((im*calmult/caldiv)+caladd)*caldiv
  endif else begin
    print,'No Long-term calibration file found (open_lasco_file)',date
    im=-1
    return
  endelse
  
endif

if keyword_set(point) then im=point_filter_corimp(im,/sil)

if keyword_set(htrange) then begin
  ind=where(ht lt htrange[0] or ht gt htrange[1])
  im[ind]=!values.f_nan
endif

end
