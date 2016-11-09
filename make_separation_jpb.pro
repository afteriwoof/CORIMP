function quickcollate

startdate='2011/03/01 00:00'
enddate='2011/03/01 23:59'
;topdir=getenv('PROCESSED_DATA')+'/soho/lasco/separated'
topdir=getenv('PROCESSED_DATA')+'/stereo/secchi/separated/a/cor2'
instr='cor2a'

dates=anytim2cal(timegrid(startdate,enddate,/days,/str),form=11,/date)
dirs=topdir+'/'+dates
files=file_search(dirs,instr+'_seprtd_*.dat',count=cntfiles)


for i=0,cntfiles-1 do begin
  restore,files[i]
  if i eq 0 then begin
    im=fltarr(seprtd.npa,seprtd.nr,cntfiles)
  endif
  im[*,*,i]=seprtd.cme
endfor

return,im

end


pro make_separation_jpb,startdate,enddate,topdatadir,topsavedir,topbgavstdir,instr0,spacecraft0,mission0, $
                            overwrite=overwrite,loglun=loglun,npa=npa,nht=nht,delete_whole_day=delete_whole_day, $
                            nfitsout=nfitsout,nobackground=nobackground

if keyword_set(loglun) then begin
  get_date,datenow,/time
  if keyword_set(loglun) then printf,loglun,'Start make_separation '+anytim2cal(datenow,form=11)
endif

;next block sets calling 
if n_params() eq 0 then begin;testing
  startdate='2011/01/02 00:00'
  enddate='2011/01/02 14:00'
  ;topdatadir=getenv('SOHO_DATA')+'/lasco/lz/level_05'
  topdatadir='/home/gail/jbyrne/soho/lasco/lz/level_05'
  ;topsavedir=getenv('PROCESSED_DATA')+'/soho/lasco/separated_new'
  topsavedir='/home/gail/jbyrne/soho/lasco/separated_new'
  ;topbgavstdir=getenv('PROCESSED_DATA')+'/soho/lasco/bg_av_st'
  topbgavstdir='/home/gail/jbyrne/soho/lasco/bg_av_st'
  instr0='c2'
  spacecraft0='lasco'
endif

instr=strlowcase(instr0)
spacecraft=strlowcase(spacecraft0)
mission=strlowcase(mission0);this one not used so far

timewindow4bg=24.*3600
maxgaps=timewindow4bg*0.5

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

if ~keyword_set(nht) then nht=320
if ~keyword_set(npa) then npa=360*3.

startdatefull=strlen(startdate) lt 14?startdate+' 00:00':startdate
starttai=anytim2tai(startdatefull)
enddatefull=strlen(enddate) lt 14?enddate+' 00:00':enddate
endtai=anytim2tai(enddatefull)

dates=anytim2cal(timegrid(startdate,enddate,/days,/str),form=11,/date)
ndates=n_elements(dates)

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
  print,'No files found (make_separation)'
  if keyword_set(loglun) then printf,loglun,'No files found (make_separation)'
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
    sc=adjust_hdr_tcr(hdrnow,verb=0)
    if sc.date eq '' then begin
      print,'Just using header values - adjust_hdr_tcr did not work!!!'
      sc.date=hdrnow.date_obs
      sc.time=hdrnow.time_obs
      sc.roll=hdrnow.crota1
    endif 
    build_loop_arrays,sc.date+' '+sc.time,datemain,sc.roll,rollmain
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
   polmain=strlowcase(hdr.polar) eq 'clear'
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

topsavedirs=topsavedir+'/'+dates
make_directories,topsavedirs

if keyword_set(delete_whole_day) then begin
  files4delete=file_search(topsavedirs,strlowcase(instr)+'*_seprtd_*.dat',count=countdelete)
  if countdelete gt 0 then file_delete,files4delete,/allow_nonexistent
endif

index_many_arrays,index,files,hdr,datemain,polmain
taimain=anytim2tai(datemain)
print,nfiles,' appropriate files found'
if keyword_set(loglun) then printf,loglun,' appropriate files found'

index2=sort(taimain)
index_many_arrays,index2,files,hdr,datemain,taimain,polmain

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

nfiles=float(nfiles)/npolar

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
indblocks=index_ends(where(dt lt maxgaps and droll lt 30),cntblocks)
indblocks[2*indgen(cntblocks*0.5)+1]=(indblocks[2*indgen(cntblocks*0.5)+1]+1)<(n_elements(dt))
indblocks[2*indgen(cntblocks*0.5)]=(indblocks[2*indgen(cntblocks*0.5)]-1)>0

fbg=keyword_set(nobackground)?'':read_bg_dir(instr,spacecraft,bgtai,bgroll,dir=topbgavstdir)

bgfile0='' & bgfile1=''
for ifile=0.,nfiles-1. do begin
  if ifile mod 100 eq 0 then begin
    print,ifile,' out of ',nfiles-1
  endif
  
  if keyword_set(loglun) then printf,loglun,'Reading ',files[ifile]

  if mission eq 'soho' then $
  open_lasco_file_jpb,files[ifile],void,im,sc,rollnow,pix_size,date=date
  if mission eq 'stereo' then begin
   if npolar eq 1 then $
    secchi_prep_call_huw,files[ifile],hdrvoid,im,read_size else $
    secchi_prep_call_huw,files[ifile,*],hdrvoid,im,read_size,/polar
    sz=size(im)
    pix_size=hdrvoid.cdelt1/((pb0r(datemain[ifile],stereo=strupcase(spacecraft),/arcsec))(2))
    rollnow=0
    sc={xpos:hdrvoid.crpix1,ypos:hdrvoid.crpix2,roll:0}
    date=anytim2cal(hdrvoid.date_obs,form=11)
  endif

  topsavedirnow=topsavedir+'/'+strmid(date,0,10)
  make_directories,topsavedirnow
  srchdirnow=topsavedir+'/'+[anytim2cal(anytim2tai(date)-3600*24.,/date,form=11), $
                strmid(date,0,10),anytim2cal(anytim2tai(date)+3600*24.,/date,form=11)]
  exist_files=file_search(srchdirnow,instr+spacecraft+'_seprtd_*.dat',count=exist_count)
  if exist_count gt 0 then begin
    exist_dates=strarr(exist_count)
    for i=0,exist_count-1 do $
      exist_dates[i]=(strsplit(file_basename(exist_files[i],'.dat'),'_',/ext))(2)
    exist_tai=yyyymmdd2cal(exist_dates,/tai)
    inddelete=where(abs(exist_tai-anytim2tai(date)) lt 3*60.,cntexist);3 minutes grace?
    thisoneexists=cntexist gt 0
    if keyword_set(overwrite) and thisoneexists then file_delete,exist_files[inddelete],/allow_nonexistent
  endif else thisoneexists=0b
  
  
  filenamenow=instr+spacecraft+'_seprtd_'+anytim2cal(date,form=8)+'.dat'
  filenamenow=topsavedirnow+'/'+filenamenow
  filenameorignow=instr+spacecraft+'_origin_'+anytim2cal(date,form=8)+'.dat'
  filenameorignow=topsavedirnow+'/'+filenameorignow
  
  indgood=where(finite(im),cntgood)
  imageok=float(cntgood)/n_elements(im) gt 0.5
  
  if ~thisoneexists or keyword_set(overwrite) and $
      imageok then begin
    
    imp=cartesian2polar_corimp(im,[0,360],[minht,maxht],npa,nht,sc.xpos,sc.ypos,pix_size,rollnow,/sample)
    
    if fbg[0] eq '' then begin
      print,'No background is being used (make_separation)'
    endif else begin
      ;find background file/files
      tai=anytim2tai(date)
      indbg0=max(where(abs(bgtai-tai) le timewindow4bg and bgtai le tai and $
                      abs(cyclic(bgroll-rollnow,/deg)) lt 30,cntbg0))
      if cntbg0 ne 0 then begin
        if bgfile0 ne fbg[indbg0] then begin
          restore,fbg[indbg0]
          dbg0=d
          if instr eq 'ccor2' then begin
            bg=[d.bg,d.bg,d.bg]
            indnanbg=where(~finite(bg),cntnanbg)
            bg=smooth(bg,5,/edge_trunc,/nan)
            if cntnanbg gt 0 then bg[indnanbg]=!values.f_nan
            dbg0.bg=bg[dbg0.npa:dbg0.npa*2-1,*]
          endif
          bgfile0=fbg[indbg0]
          bgtai0=bgtai[indbg0]
        endif
        bg0true=1b
      endif else bg0true=0b
      
      indbg1=min(where(abs(bgtai-tai) le timewindow4bg and bgtai gt tai and $
                      abs(cyclic(bgroll-rollnow,/deg)) lt 30,cntbg1))
      if cntbg1 ne 0 then begin
        if bgfile1 ne fbg[indbg1] then begin
          restore,fbg[indbg1]
          dbg1=d
          if instr eq 'ccor2' then begin
            bg=[d.bg,d.bg,d.bg]
            indnanbg=where(~finite(bg),cntnanbg)
            bg=smooth(bg,5,/edge_trunc,/nan)
            if cntnanbg gt 0 then bg[indnanbg]=!values.f_nan
            dbg1.bg=bg[dbg1.npa:dbg1.npa*2-1,*]
          endif
          bgfile1=fbg[indbg1]
          bgtai1=bgtai[indbg1]
        endif
        bg1true=1b
      endif else bg1true=0b
    
      ;skip this file if no bg exists
      if ~bg0true and ~bg1true then begin
        print,'No background found for this file: ',files[ifile]
        print,'Skipping...'
        if keyword_set(loglun) then printf,loglun,'No background found for this file: ',files[ifile]
        if keyword_set(loglun) then printf,loglun,'Skipping...'
        continue
      endif
    
      ;interpolate background in time?
      if bg0true ne bg1true then d=bg0true?dbg0:dbg1 else begin
        weight=(tai-bgtai0)/(bgtai1-bgtai0)
        d=dbg0
        d.bg=((1-weight)*dbg0.bg)+(weight*dbg1.bg)
        d.av=((1-weight)*dbg0.av)+(weight*dbg1.av)
        d.st=((1-weight)*dbg0.st)+(weight*dbg1.st)
      endelse
    
      ;interpolate background in space?
      if d.rra[0] ne minht or d.rra[1] ne maxht or d.npa ne npa or d.nr ne nht then begin
        ipa=interpol([0.,d.npa-1],[0,360.],make_coordinates(npa,[0,360]))
        iht=interpol([0.,d.nr-1],d.rra,make_coordinates(nht,[minht,maxht]))
        bg=interpolate(d.bg,ipa,iht,/grid)
        av=interpolate(d.av,iht)
        st=interpolate(d.st,iht)
      endif else begin
        bg=d.bg
        av=d.av
        st=d.st
      endelse
    
      aav=rebin(reform(av,1,nht),npa,nht)
      sst=rebin(reform(st,1,nht),npa,nht)
      ;if abs(anytim2tai('2011/01/02 00:22')-anytim2tai(date)) lt 60 then stop
      
      indnan=where(~finite(imp) or ~finite(bg),cntnan)
      imp=((imp-bg)-aav)/sst
      if cntnan gt 0 then imp[indnan]=!values.f_nan
    endelse;fbg[0] eq ''
      
    
    med=median(cumulative_clip(imp),dim=2)
    mmed=rebin(med,npa,nht)
    ;if cntnan gt 0 then imp[indnan]=mmed[indnan];gall hwn achosi problemau? Wedi ei ddileu oherwydd cor 2B 2011/03/23
    imp=point_filter_corimp(imp,pntfiltwdth,7,3,/silent)
    
    wd=15.*nht/320
    ker=fltarr(1,wd)+(1/wd);gaussian_function(wd/6.,/norm)
    ;ker=reform(ker,1,n_elements(ker))
    cme=deconvolve(imp-mmed,ker)
    
    
    sz=size(im)
    if sz[1] lt nfitsout or sz[2] lt nfitsout then begin
      im2=fltarr(nfitsout,nfitsout)
      im2[0:sz[1]-1,0:sz[2]-1]=im
      im=im2
      sz[1]=nfitsout & sz[2]=nfitsout
    endif
    get_ht_pa_2d_corimp,sz[1],sz[2],sc.xpos,sc.ypos,pix_size=pix_size,xorig,yorig,htorig
    if ~keyword_set(nobackground) then begin
      hts=make_coordinates(d.nr,d.rra)
      aav=interpol(av,hts,htorig)
      sst=interpol(st,hts,htorig)
      bgorig=polar2cartesian_corimp(bg,[0,360],[minht,maxht],npa,nht, $
                    sz[1],sz[2],sc.xpos,sc.ypos,pix_size,sc.roll,/sample)
                    imorig=point_filter_corimp((im-bgorig-aav)/sst,/sil)
      magnify=pix_size/(maxht*2/nfitsout)
      imorig=rot(imorig,-sc.roll,magnify,sc.xpos,sc.ypos,missing=!values.f_nan,/interp)
      sc.xpos=(nfitsout-1)*0.5
      sc.ypos=(nfitsout-1)*0.5
      pix_size=pix_size/magnify
      get_ht_pa_2d_corimp,sz[1],sz[2],sc.xpos,sc.ypos,pix_size=pix_size,xorig,yorig
      origin={im:imorig,xcen:sc.xpos,ycen:sc.ypos,pix_size:pix_size,date:date,file:files[ifile],rra:[minht,maxht]}
      save,origin,filename=filenameorignow
    endif
    seprtd={cme:cme,npa:npa,para:[0,360],nr:nht,rra:[minht,maxht],date:date,file:files[ifile]}
    

    if keyword_set(loglun) then printf,loglun,'Saving ',filenamenow
    save,seprtd,filename=filenamenow
    
  endif else begin
    print,'File exists (make_separation):',filenamenow
    if keyword_set(loglun) then printf,loglun,'File exists (make_separation):',filenamenow
  endelse
endfor


end
