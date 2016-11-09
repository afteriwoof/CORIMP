pro printsep,lunlog
printf,lunlog,'*************************************************************'
printf,lunlog,''
printf,lunlog,''
end


pro wrap
s=['2010/04/01', $
'2010/07/09', $
'2011/06/18', $
'2012/11/06']

e=['2010/04/05', $
'2010/07/13', $
'2011/06/22', $
'2012/11/10']

instr=['cor2a','cor2b']

for i=0,n_elements(s)-1 do begin
  cme_main_process,s[i],e[i],instr
endfor

end

pro joe

cme_main_process,'2013/04/08','2013/04/12',['cor2a','cor2b'];
cme_main_process,'2013/05/28','2013/06/02',['cor2a','cor2b'];
cme_main_process,'2013/07/16','2013/07/21',['cor2a','cor2b'];
cme_main_process,'2013/08/15','2013/08/19',['cor2a','cor2b'];
cme_main_process,'2013/08/25','2013/08/29',['cor2a','cor2b'];
;cme_main_process,'2013/09/08','2013/09/12',['cor2a','cor2b'];
;cme_main_process,'2013/09/22','2013/09/26',['cor2a','cor2b'];

end

pro cme_main_process_jpb,startdate,enddate,list,over=over, $
              no_bg=no_bg,no_sep=no_sep,no_img=no_img, $
              topdata=topdata,delete_whole_day=delete_whole_day, $
              topsave=topsave,lastimage=lastimage,nobackground=nobackground, $
              files_processed=files_processed

nfitsout=1024
njpegout=751

if keyword_set(nobackground) then no_bg=1
;if ~keyword_set(topsave) then topsave=getenv('PROCESSED_DATA') ;JPB
;if keyword_set(lastimage) then topsave=getenv('PROCESSED_DATA')+'/realtime' ;JPB
if ~keyword_set(topsave) then topsave='/home/gail/jbyrne' ;JPB
if keyword_set(lastimage) then topsave='/home/gail/jbyrne/realtime';JPB

get_date,datenow,/time

lunlog=0
if keyword_set(lunlog) then begin
  free_lun,lunlog
  logfile=topsave+'/process_log_jpb/cme_main_process_'+anytim2cal(datenow,form=8)+'.txt'
  make_directories,file_dirname(logfile)
  openw,lunlog,logfile
  printf,lunlog,logfile
  printf,lunlog,'Start = ',startdate
  printf,lunlog,'End = ',enddate
  true=['false','true']
  printf,lunlog,'No bg = '+true[keyword_set(no_bg)]
  printf,lunlog,'No sep = '+true[keyword_set(no_sep)]
  printf,lunlog,'No img = '+true[keyword_set(no_img)]
  printf,lunlog,'Overwrite = '+true[keyword_set(overwrite)]
  printsep,lunlog
endif

if keyword_set(delete_whole_day) then overwrite=1

for ilist=0,n_elements(list)-1 do begin

  npa=1080
  nht=320

  case list[ilist] of

    'c2':begin
      ;soho lasco c2
      sc='lasco'
      mission='soho'  
      ;toptopdata=keyword_set(topdata)?topdata:getenv('SOHO_DATA') ;JPB
      toptopdata=keyword_set(topdata)?topdata:'/home/gail/jbyrne/soho' ;JPB
      topdatadir=keyword_set(lastimage)?toptopdata+'/lasco/lastimage/level_05':toptopdata+'/lasco/lz/level_05'
      topbgdir=topsave+'/soho/lasco/bg_av_st'
      topsavedir=topsave+'/soho/lasco/separated'
      savefitsdir=topsavedir+'/fits'
      saveimgdir=topsavedir+'/img'
    
      COMMON reduce_history, version, prev_a, prev_hdr, zblocks0
      common las_time_correction, c2_offsets, c2_utc_dates, c2_dates, c2datafile
      instr='c2'
      if ~keyword_set(no_bg) then  $
      make_bg_av_st_jpb,startdate,enddate,topdatadir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht,lastimage=lastimage
      if keyword_set(lunlog) then printsep,lunlog
      if ~keyword_set(no_sep) then  $
      make_separation_jpb,startdate,enddate,topdatadir,topsavedir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht,delete_whole_day=delete_whole_day, $
            nfitsout=nfitsout,nobackground=nobackground
      if keyword_set(lunlog) then printsep,lunlog
      if ~keyword_set(no_img) then  $
      wrap_display_cme,startdate,enddate,topsavedir,savefitsdir,saveimgdir,instr,sc,mission, $
            over=over,loglun=lunlog,nfitsout=nfitsout,njpegout=njpegout,delete_whole_day=delete_whole_day, $
            nobackground=nobackground,files_processed=files_processed
      if keyword_set(lunlog) then if keyword_set(lunlog) then  printsep,lunlog
    end
  
    'c3':begin
      ;soho lasco c3
      sc='lasco'
      mission='soho'  
      ;toptopdata=keyword_set(topdata)?topdata:getenv('SOHO_DATA') ;JPB
      toptopdata=keyword_set(topdata)?topdata:'/home/gail/jbyrne/soho' ;JPB
      topdatadir=keyword_set(lastimage)?toptopdata+'/lasco/lastimage/level_05':toptopdata+'/lasco/lz/level_05'
      topbgdir=topsave+'/soho/lasco/bg_av_st'
      topsavedir=topsave+'/soho/lasco/separated'
      savefitsdir=topsavedir+'/fits'
      saveimgdir=topsavedir+'/img'
      
      if total(strmatch(list,'c2')) eq 0 then begin
        COMMON reduce_history, version, prev_a, prev_hdr, zblocks0
        common las_time_correction, c2_offsets, c2_utc_dates, c2_dates, c2datafile
      endif
      instr='c3'
      if ~keyword_set(no_bg) then  $
      make_bg_av_st_jpb,startdate,enddate,topdatadir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht,lastimage=lastimage
      if keyword_set(lunlog) then  printsep,lunlog
      if ~keyword_set(no_sep) then  $
      make_separation_jpb,startdate,enddate,topdatadir,topsavedir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht,delete_whole_day=delete_whole_day, $
            nfitsout=nfitsout,nobackground=nobackground
      if keyword_set(lunlog) then  printsep,lunlog
      if ~keyword_set(no_img) then  $
      wrap_display_cme,startdate,enddate,topsavedir,savefitsdir,saveimgdir,instr,sc,mission, $
            over=over,loglun=lunlog,nfitsout=nfitsout,njpegout=njpegout,delete_whole_day=delete_whole_day, $
            nobackground=nobackground,files_processed=files_processed
      if keyword_set(lunlog) then  printsep,lunlog
    end
  
    'cor1a':begin
      ;cor 1 a
      
      nfitsout=512
      njpegout=501
      npa=720 & nht=200
      
      instr='cor1'
      mission='stereo'
      topdatadir0=keyword_set(topdata)?topdata:getenv('SECCHI_DATA')
      topbgdir=topsave+'/stereo/secchi/bg_av_st'
      sc='a'
      topdatadir=topdatadir0+'/'+sc+'/cor1'
      topsavedir=topsave+'/stereo/secchi/separated/a/cor1'
      savefitsdir=topsavedir+'/fits'
      saveimgdir=topsavedir+'/img'
      
      if ~keyword_set(no_bg) then  $
      make_bg_av_st_cor1,startdate,enddate,topdatadir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht
      if keyword_set(lunlog) then  printsep,lunlog
      if ~keyword_set(no_sep) then  $
      make_separation_cor1,startdate,enddate,topdatadir,topsavedir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht,delete_whole_day=delete_whole_day, $
            nfitsout=nfitsout
      if keyword_set(lunlog) then  printsep,lunlog
      if ~keyword_set(no_img) then  $
      wrap_display_cme,startdate,enddate,topsavedir,savefitsdir,saveimgdir,instr,sc,mission, $
            over=over,loglun=lunlog,nfitsout=nfitsout,njpegout=njpegout,delete_whole_day=delete_whole_day, $
            nobackground=nobackground,files_processed=files_processed
      if keyword_set(lunlog) then  printsep,lunlog
    end
    
    'cor1b':begin
      ;cor 1 b
      
      nfitsout=512
      njpegout=501
      npa=720 & nht=200
      
      instr='cor1'
      mission='stereo'
      topdatadir0=keyword_set(topdata)?topdata:getenv('SECCHI_DATA')
      topbgdir=topsave+'/stereo/secchi/bg_av_st'
      sc='b'
      topdatadir=topdatadir0+'/'+sc+'/cor1'
      topsavedir=topsave+'/stereo/secchi/separated/b/cor1'
      savefitsdir=topsavedir+'/fits'
      saveimgdir=topsavedir+'/img'
      
      if ~keyword_set(no_bg) then  $
      make_bg_av_st_cor1,startdate,enddate,topdatadir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht
      if keyword_set(lunlog) then  printsep,lunlog
      if ~keyword_set(no_sep) then  $
      make_separation_cor1,startdate,enddate,topdatadir,topsavedir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht,delete_whole_day=delete_whole_day, $
            nfitsout=nfitsout
      if keyword_set(lunlog) then  printsep,lunlog
      if ~keyword_set(no_img) then  $
      wrap_display_cme,startdate,enddate,topsavedir,savefitsdir,saveimgdir,instr,sc,mission, $
            over=over,loglun=lunlog,nfitsout=nfitsout,njpegout=njpegout,delete_whole_day=delete_whole_day, $
            nobackground=nobackground,files_processed=files_processed
      if keyword_set(lunlog) then  printsep,lunlog
    end
  
    'cor2a':begin
      ;cor 2 a
      instr='cor2'
      mission='stereo'
      topdatadir0=keyword_set(topdata)?topdata:getenv('SECCHI_DATA')
      topbgdir=topsave+'/stereo/secchi/bg_av_st'
      sc='a'
      topdatadir=topdatadir0+'/'+sc+'/cor2'
      topsavedir=topsave+'/stereo/secchi/separated/a/cor2'
      savefitsdir=topsavedir+'/fits'
      saveimgdir=topsavedir+'/img'
      
      if ~keyword_set(no_bg) then  $
      make_bg_av_st,startdate,enddate,topdatadir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht
      if keyword_set(lunlog) then  printsep,lunlog
      if ~keyword_set(no_sep) then  $
      make_separation,startdate,enddate,topdatadir,topsavedir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht,delete_whole_day=delete_whole_day, $
            nfitsout=nfitsout,nobackground=nobackground
      if keyword_set(lunlog) then  printsep,lunlog
      if ~keyword_set(no_img) then  $
      wrap_display_cme,startdate,enddate,topsavedir,savefitsdir,saveimgdir,instr,sc,mission, $
            over=over,loglun=lunlog,nfitsout=nfitsout,njpegout=njpegout,delete_whole_day=delete_whole_day, $
            nobackground=nobackground,files_processed=files_processed
      if keyword_set(lunlog) then  printsep,lunlog
    end
    
    'cor2b':begin
      ;cor 2 b
      instr='cor2'
      mission='stereo'
      topdatadir0=keyword_set(topdata)?topdata:getenv('SECCHI_DATA')
      topbgdir=topsave+'/stereo/secchi/bg_av_st'
      sc='b'
      topdatadir=topdatadir0+'/'+sc+'/cor2'
      topsavedir=topsave+'/stereo/secchi/separated/b/cor2'
      savefitsdir=topsavedir+'/fits'
      saveimgdir=topsavedir+'/img'
      
      if ~keyword_set(no_bg) then  $
      make_bg_av_st,startdate,enddate,topdatadir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht
      if keyword_set(lunlog) then  printsep,lunlog
      if ~keyword_set(no_sep) then  $
      make_separation,startdate,enddate,topdatadir,topsavedir,topbgdir,instr,sc,mission, $
            over=over,loglun=lunlog,npa=npa,nht=nht,delete_whole_day=delete_whole_day, $
            nfitsout=nfitsout,nobackground=nobackground
      if keyword_set(lunlog) then  printsep,lunlog
      if ~keyword_set(no_img) then  $
      wrap_display_cme,startdate,enddate,topsavedir,savefitsdir,saveimgdir,instr,sc,mission, $
            over=over,loglun=lunlog,nfitsout=nfitsout,njpegout=njpegout,delete_whole_day=delete_whole_day, $
            nobackground=nobackground,files_processed=files_processed
      if keyword_set(lunlog) then  printsep,lunlog
    end
    
  endcase
endfor

if lunlog ne 0 then begin
  close,lunlog
  free_lun,lunlog
endif

end
