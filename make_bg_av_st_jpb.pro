; Created	2014-03-20	from Huw's make_bg_av_st.pro to call adjust_hdr_tcr_jpb.pro

pro make_bg_av_st_jpb,startdate,enddate,topdatadir,topsavedir, $
          instr0,spacecraft0,mission0,overwrite=overwrite,loglun=loglun,npa=npa,nht=nht, $
          lastimage=lastimage

if keyword_set(loglun) then begin
  get_date,datenow,/time
  if keyword_set(loglun) then printf,loglun,'Start make_bg_av_st '+anytim2cal(datenow,form=11)
endif

;next block sets calling parameters if testing code with no parameters
if n_params() eq 0 then begin;testing
  startdate='2011/01/01'
  enddate='2011/01/07'
  topdatadir=getenv('SECCHI_DATA')+'/a/cor2'
  topsavedir=getenv('PROCESSED_DATA')+'/stereo/secchi/bg_av_st'
  instr0='cor2'
  spacecraft0='a'
  mission0='stereo'
endif

instr=strlowcase(instr0)
spacecraft=strlowcase(spacecraft0)
mission=strlowcase(mission0)

if ~keyword_set(nht) then nht=320
if ~keyword_set(npa) then npa=360*3.

timewindow4bg=24.*3600; +/- days
maxgaps=keyword_set(lastimage)?timewindow4bg:timewindow4bg*0.5
existgaps=timewindow4bg
minimumobs=keyword_set(lastimage)?10:20

if keyword_set(loglun) then begin
  printf,loglun,'Time window +/-',timewindow4bg
  printf,loglun,'Maximum gaps between processing blocks ',maxgaps
endif

dates=anytim2cal(timegrid(startdate,enddate,/days,/str),form=11,/date)
ndates=n_elements(dates)


case 1 of
  instr eq 'cor1' and spacecraft eq 'a':begin
    minht=1.5
    maxht=3.5
    filter='orange'
    pntfiltwdth=5
    read_size=512
  end
  instr eq 'cor1' and spacecraft eq 'b':begin
    minht=1.5
    maxht=3.5
    filter='orange'
    pntfiltwdth=5
    read_size=512
  end
  instr eq 'cor2' and spacecraft eq 'a':begin
    minht=3.0
    maxht=14.0
    filter='orange'
    pntfiltwdth=5
    read_size=1024
  end
  instr eq 'cor2' and spacecraft eq 'b':begin
    minht=3.0
    maxht=14.0
    filter='orange'
    pntfiltwdth=5
    read_size=1024
  end
  instr eq 'c2' and spacecraft eq 'lasco':begin
    minht=2.2
    maxht=6.0
    filter='orange'
    pntfiltwdth=5
  end
  instr eq 'c3' and spacecraft eq 'lasco':begin
    minht=5.7
    maxht=25.
    filter='clear'
    pntfiltwdth=9
  end
endcase

print,'Searching for files...'

if mission eq 'soho' then begin
  dirs=file_search(topdatadir+'/*',/test_directory)
  datesdirreq=strmid(anytim2cal(dates,form=8,/date),2)
  datesdir=file_basename(dirs)
  for i=0,n_elements(datesdir)-1 do begin
    if total(strmatch(datesdirreq,datesdir[i])) eq 1 then begin
      filesnow=file_search(topdatadir+'/'+datesdir[i]+'/'+instr,'{*fts,*fts.gz,*fits,*fits.gz}',count=cnt)
      if cnt gt 0 then build_loop_array,filesnow,files,reset=i eq 0,/onedim
    endif
  endfor
endif

if mission eq 'stereo' then begin
  for i=0,n_elements(dates)-1 do begin
    dirsnow=topdatadir+'/'+dates[i]
    if dir_exist(dirsnow) then $
    build_loop_array,dirsnow,dirs,reset=i eq 0,/onedim 
  endfor
  if n_elements(dirs) gt 0 then begin
    srchstr=instr eq 'cor2'?'*_d4c2*.fts*':'*_s4c1*.fts*'
    files=file_search(dirs,srchstr)
  endif
endif

nfiles=n_elements(files)
if nfiles eq 0 then begin
  print,'No files found (make_bg_av_st)'
  if keyword_set(loglun) then printf,loglun,'No files found (make_bg_av_st)'
  print,'Dirs = ',topdatadir
  return
endif
print,nfiles,' files found within date range'
if keyword_set(loglun) then printf,loglun,nfiles,' files found within date range'

print,'Reading headers...'
if mission eq 'soho' then begin
  for ifile=0.,nfiles-1. do begin
    if ifile mod 100 eq 0 then begin
      print,ifile,' out of ',nfiles
      if keyword_set(loglun) then printf,loglun,ifile,' out of ',nfiles
    endif
  
    void=lasco_readfits(files[ifile],hdrnow,/no_img,/silent)
    sc=adjust_hdr_tcr_jpb(hdrnow,verb=0) ;JPB
    if sc.date eq '' then begin
      print,'Just using header values - adjust_hdr_tcr did not work!!!'
      sc.date=hdrnow.date_obs
      sc.time=hdrnow.time_obs
      sc.roll=hdrnow.crota1
    endif 
    build_loop_arrays,sc.date+' '+sc.time,datemain,sc.roll,rollmain,0,polmain
    
    hdrnow={naxis1:hdrnow.naxis1,naxis2:hdrnow.naxis2, $
            filter:hdrnow.filter,detector:hdrnow.detector, $
            polar:hdrnow.polar,lp_num:hdrnow.lp_num}
    build_loop_array,hdrnow,hdr,/onedim,reset=ifile eq 0
  endfor
  index=where(strlowcase(hdr.filter) eq filter and $
        strlowcase(hdr.detector) eq instr and $
        strlowcase(hdr.polar) eq 'clear' and $
        (strcompress(strlowcase(hdr.lp_num),/remove_all) eq 'normal' or $
         strcompress(strlowcase(hdr.lp_num),/remove_all) eq 'seqpw') and $
        hdr.naxis1 eq 1024 and $
        hdr.naxis2 eq 1024,nfiles)
endif 
if mission eq 'stereo' then begin
  mreadfits,files,hdr,/nodata
  datemain=hdr.date_d$obs
  rollmain=hdr.crota
  polmain=hdr.polar
  index=instr eq 'cor2'? $
  where(hdr.naxis1 eq 2048 and hdr.naxis2 eq 2048 and abs(hdr.exptime-6) lt 1.e5 and hdr.ledpulse eq 0,nfiles): $
  where(hdr.naxis1 gt 512 and hdr.naxis2 gt 512 and hdr.ledpulse eq 0,nfiles)
endif

if nfiles eq 0 then begin
  print,'No appropriate files found (make_bg_av_st)'
  if keyword_set(loglun) then printf,loglun,'No appropriate files found (make_bg_av_st)'
  return
endif
make_directories,topsavedir

index_many_arrays,index,files,hdr,datemain,rollmain,polmain
taimain=anytim2tai(datemain)
index2=sort(taimain)

index_many_arrays,index2,files,hdr,datemain,rollmain,taimain,polmain
print,nfiles,' appropriate files found'
if keyword_set(loglun) then printf,loglun,nfiles,' appropriate files found'

uniqpolar=polmain[uniq(polmain,sort(polmain))]
npolar=n_elements(uniqpolar)
if npolar gt 1 then begin
  indtot=where(polmain eq 1001,cnttot,ncomp=nind)
  nout=cnttot+nind/3.
  fout=strarr(nout,3)
  taiout=dblarr(nout)
  dateout=strarr(nout)
  rollout=fltarr(nout)
  hdrout=replicate(hdr[0],nout)
  istore=0
  for i=0,nfiles-1 do begin
    if polmain[i] eq 1001 then begin
      fout[istore,0]=files[i]
      taiout[istore]=taimain[i]
      dateout[istore]=datemain[i]
      rollout[istore]=rollmain[i]
      hdrout[istore]=hdr[i] 
      istore++
    endif else begin
      if polmain[i] eq 0 then begin
        ind=where(abs(taimain-taimain[i]) lt 240 and $
                  polmain ne 0 and polmain ne 1001,cnt)
        if cnt eq 2 then begin
          fout[istore,*]=[files[i],files[ind]]
          taiout[istore]=taimain[i]
          dateout[istore]=datemain[i]
          rollout[istore]=rollmain[i]
          hdrout[istore]=hdr[i] 
          istore++
        endif
      endif
    endelse
  endfor
  files=fout
  taimain=taiout
  datemain=dateout
  rollmain=rollout
  hdr=hdrout
endif

;identifying gaps in observation or large rolls
dt=taimain-shift(taimain,1)
dt[0]=median(dt)
hroll=histogram(rollmain,binsize=5,rev=ri,min=0,max=360,loc=rollh)
n=n_elements(hroll)
shifth=min(where(hroll eq 0))
hroll=shift(hroll,-shifth)
hroll=[0,hroll,0]
l=label_region_huw(hroll,nreg=nreg)
l=shift(l[1:n],shifth)
rollmain2=rollmain*0
for i=1,nreg-1 do begin
  ind=get_rev_ind(ri,where(l eq i))
  rollmain2[ind]=median(rollmain[ind])
endfor
droll=rollmain2-shift(rollmain2,1)
droll[0]=0

indblocks=index_ends(where(dt lt maxgaps and abs(droll) lt 30),cntblocks)
indblocks[2*lindgen(cntblocks*0.5)+1]=(indblocks[2*lindgen(cntblocks*0.5)+1]+1)<(n_elements(dt))
indblocks[2*lindgen(cntblocks*0.5)]=(indblocks[2*lindgen(cntblocks*0.5)]-1)>0


;check which files exist
srchstr=instr+spacecraft+'_bg_av_st_*.dat'
f=file_search(topsavedir,srchstr,count=cntexist)
if cntexist gt 0 then begin
  fb=file_basename(f,'.dat')
  for i=0.,cntexist-1. do begin
    fnow=strsplit(fb[i],'_',/extract)
    tainow=anytim2tai(anytim2cal(yyyymmdd2cal(fnow[4]),form=11))
    rollnow=long(fnow[5])
    build_loop_arrays,tainow,taiexist,rollnow,rollexist,f[i],fileexist,reset=i eq 0
  endfor
endif
if cntexist eq 0 then begin
  taiexist=!values.f_nan
  rollexist=!values.f_nan
  fileexist='???'
endif

for iblocks=0.,cntblocks-1.,2. do begin
  print,'Testing block ',(iblocks/2.)+1,' out of ',cntblocks/2.
  if keyword_set(loglun) then printf,loglun,'Testing block ',(iblocks/2.)+1,' out of ',cntblocks/2.
  nnow=indblocks[iblocks+1]-indblocks[iblocks]
  index=lindgen(nnow)+indblocks[iblocks]
  tainow=taimain[index]
  filesnow=npolar gt 1?files[index,*]:files[index]
  datenow=datemain[index]
  rollnow=rollmain[index]
  
  taimid=median(tainow)
  y=(tainow-taimid)/timewindow4bg
  x=findgen(n_elements(y))
  miny=ceil(min(y)) & maxy=floor(max(y))
  nprocess=maxy-miny+1
  it=interpol(x,y,indgen(nprocess)+miny)
  itai=interpol(tainow,x,it)
  it=round(it)
  
  filesprocessnow=ptrarr(nprocess)
  keepprevprocessnow=ptrarr(nprocess)
  savefilenamenow=strarr(nprocess)
  for i=0,nprocess-1 do begin
    minind=i eq 0?0:it[i-1]
    midind=it[i]
    maxind=i eq nprocess-1?nnow:it[i+1]
    
    if maxind-minind gt minimumobs then begin
      indexist=where(abs(taiexist-itai[i]) le existgaps,cntexistnow)
      if cntexistnow eq 0 or keyword_set(overwrite) then begin
        if keyword_set(overwrite) and cntexistnow gt 0 then begin
          print,'Deleting existing file ',fileexist[indexist],', will reprocess'
          if keyword_set(loglun) then printf,loglun,'Deleting existing file ',fileexist[indexist],', will reprocess'
          file_delete,fileexist[indexist],/allow_nonexistent
        endif
        indexallnownow=indgen(maxind-minind)+minind
        case i of
          0:begin
            indexfornextprocess=indgen(maxind-midind-1)
            indexfilesnownow=indexallnownow
          end
          nprocess-1:begin
            indexfornextprocess=-1
            indexfilesnownow=indgen(maxind-midind)+midind
          end
          else:begin
            indexfornextprocess=indgen(maxind-midind-1)
            indexfilesnownow=indgen(maxind-midind)+midind
          end
        endcase
        
        avdatefilename=anytim2cal(itai[i],form=8)
        avroll=round(wrap_n(median(rollnow[indexallnownow]),360))
        avrollfilename=int2str_huw(avroll,3)
        savefilenamenow[i]=topsavedir+'/'+instr+spacecraft+'_bg_av_st_'+avdatefilename+'_'+ $
                              avrollfilename+'.dat'
        filesprocessnow[i]=npolar eq 1?ptr_new(filesnow[indexfilesnownow]):ptr_new(filesnow[indexfilesnownow,*])
        keepprevprocessnow[i]=ptr_new(indexfornextprocess)
      endif else begin
        print,'File exists ',fileexist[indexist],', not processing'
        if keyword_set(loglun) then printf,loglun,'File exists ',fileexist[indexist],', not processing'
      endelse
    endif else begin
      print,'Found one with too few observations (make_bg_av_st)...'
      if keyword_set(loglun) then printf,loglun,'Found one with too few observations (make_bg_av_st)...'
    endelse
  endfor
  
  build_loop_arrays,filesprocessnow,filesprocess,keepprevprocessnow,keepprevindex, $
                    savefilenamenow,savefilenames,reset=iblocks eq 0

endfor

if n_elements(savefilenames) eq 0 then begin
  print,'No processing to do, returning...(1)'
  if keyword_set(loglun) then printf,loglun,'No processing to do, returning...(1)'
  return
endif

index=where(ptr_valid(filesprocess),cntprocess)
if cntprocess eq 0 then begin
  print,'No processing to do, returning...(2)'
  if keyword_set(loglun) then printf,loglun,'No processing to do, returning...(2)'
  return
endif
index_many_arrays,index,filesprocess,keepprevindex,savefilenames

for i=0.,cntprocess-1. do begin
  
  files=*filesprocess[i]
  indexkeep=*keepprevindex[i]
  nfiles=float(n_elements(files))/npolar
  print,i+1,' chunks out of ',cntprocess,'. Reading ',nfiles,'files'
  if keyword_set(loglun) then printf,loglun,i+1,' chunks out of ',cntprocess,'. Reading ',nfiles,'files'
  
  imp=fltarr(npa,nht,nfiles)
  filedates=strarr(nfiles)
  for ifile=0.,nfiles-1. do begin
    if ifile mod 100 eq 0 then $
    print,ifile,' out of ',nfiles-1
    if keyword_set(loglun) then printf,loglun,files[ifile]
    if mission eq 'soho' then $
    open_lasco_file_jpb,files[ifile],void,im,sc,rollnow,pix_size,date=date
    if mission eq 'stereo' then begin
      if npolar eq 1 then $
      secchi_prep_call_huw,files[ifile],hdrvoid,im,read_size else $
      secchi_prep_call_huw,files[ifile,*],hdrvoid,im,read_size,/polar
      pix_size=hdrvoid.cdelt1/((pb0r(datemain[ifile],stereo=strupcase(spacecraft),/arcsec))(2))
      sc={xpos:hdrvoid.crpix1,ypos:hdrvoid.crpix2}
      rollnow=0
      date=anytim2cal(hdrvoid.date_obs,form=11)
    endif
    
    imp[*,*,ifile]=cartesian2polar_corimp(im,[0,360],[minht,maxht],npa,nht,sc.xpos,sc.ypos,pix_size,rollnow,/sample)
    filedates[ifile]=date
  endfor
  
  if indexkeep[0] ne -1 then impprevtemp=imp[*,*,indexkeep] else delvarx,impprevtemp
  if n_elements(impprev) ne 0 then imp=[[[impprev]],[[imp]]]
  if n_elements(impprevtemp) ne 0 then impprev=impprevtemp
  
  s=size(imp)
  bg=get_bg_lasco(imp,nan_tolerance=0.5)
  im=imp-rebin(bg,s[1],s[2],s[3])
  im=nrgf_polar(im,/smo,av=av,st=st)          
  d={nr:nht,rra:[minht,maxht],npa:npa,av:av,st:st,bg:bg,dates:date,files:files}

  
  save,d,filename=savefilenames[i]
  print,'Saving',savefilenames[i]
  if keyword_set(loglun) then printf,loglun,'Saving',savefilenames[i]

endfor;i



end
