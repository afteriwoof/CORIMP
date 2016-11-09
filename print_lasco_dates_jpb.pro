; Created	2014-03-20	from Huw's print_lasco_dates.pro to work on my temporary setup.


function print_lasco_dates_jpb,dateusr,instr0,print=print,dir=dir,normal=normal,pb=pb,count=count,tdiff=tdiff,lastimage=lastimage

instr=strlowcase(instr0)

;dir=keyword_set(lastimage)?getenv('SOHO_DATA')+'/lasco/lastimage/level_05':getenv('SOHO_DATA')+'/lasco/lz/level_05'
dir=keyword_set(lastimage)?'/home/gail/jbyrne/soho/lasco/lastimage/level_05':'/home/gail/jbyrne/soho/lasco/lz/level_05'
date=strmid(anytim2cal(dateusr,form=8,/date),2)
dir=dir+'/'+date+'/'+strlowcase(instr)
file=dir+'/img_hdr.txt'
if ~file_exist(file) then begin
  print,'File does not exist ',file
  count=0
  return,-1
endif
nl=file_lines(file)
openr,lun,file,/get_lun
st=''
for i=0,nl-1 do begin
  readf,lun,st
  if keyword_set(print) then print,st
  st2=strsplit(st,'  ',/ext)
  if strmatch(strcompress(strlowcase(st2[11]),/remove_all),'seq*') then begin
    st2[11]=st2[11]+st2[12]
  endif
  if strmatch(strcompress(strlowcase(st2[11]),/remove_all),'de*') then begin
    st2[10]=st2[10]+st2[11]
  endif
  if strmatch(strcompress(strlowcase(st2[12]),/remove_all),'seq*') then begin
    st2[11]=st2[12]+st2[13]
  endif
  if strmatch(st2[0],'*.fts*') then begin
    d={dir:dir,filename:st2[0],date_obs:st2[1]+' '+st2[2],instr:strlowcase(st2[3]), $
        exptime:float(st2[4]),naxis1:long(st2[5]),naxis2:long(st2[6]), $
        filter:st2[9],polar:st2[10],obs_mode:st2[11]}
    dmain=n_elements(dmain) eq 0?d:[dmain,d]
  endif
endfor
free_lun,lun

if n_elements(dmain) eq 0 then begin
  dmain=-1
  count=0
  return,dmain
endif

filter=instr eq 'c2'?'orange':'clear'
if keyword_set(normal) then begin
   index=where(strlowcase(dmain.filter) eq filter and $
        strlowcase(dmain.instr) eq instr and $
        strlowcase(dmain.polar) eq 'clear' and $
        (strcompress(strlowcase(dmain.obs_mode),/remove_all) eq 'normal') and $
        dmain.naxis1 gt 0 and $
        dmain.naxis1 gt 0,nfiles)
   if nfiles eq 0 then dmain=-1 else dmain=dmain[index]
endif
if keyword_set(pb) then begin
 index=where(strlowcase(dmain.filter) eq filter and $
              strcompress(strlowcase(dmain.obs_mode),/remove_all) eq 'seqpw' and $
              dmain.naxis1 eq 512 and $
              dmain.naxis2 eq 512,nfiles)
 if nfiles eq 0 then dmain=-1  else dmain=dmain[index]
endif

if size(dmain,/type) ne 8 then begin
  dmain=-1
  count=0
  return,dmain
endif

if strlen(dateusr) gt 11 then begin
  taiusr=anytim2tai(dateusr)
  taifiles=anytim2tai(dmain.date_obs)
  tdiff=min(abs(taiusr-taifiles),index)
  if ~keyword_set(pb) then begin
    print,'Closest file found is within ',tdiff/60. ,' minutes'
    dmain=dmain[index]
  endif else begin
    ind=where(abs(taifiles-taifiles[index]) lt 10*60.)
    print,'Closest files found are within ',abs(taifiles[ind]-taiusr)/60. ,' minutes'
    dmain=dmain[index]
  endelse
endif

indnoexist=where(~file_exist(dmain.dir+'/'+dmain.filename),cntnoexist)
cntbad=0  
for i=0,cntnoexist-1 do begin
  filenamenow=file_basename(file_search(dmain[indnoexist[i]].dir, $
                                  strmid(dmain[indnoexist[i]].filename,0,8)+'*'))
  if filenamenow eq '' then begin
    cntbad++
    build_loop_array,indnoexist[i],indbad,/onedim,reset=i eq 0
    continue
  endif
  dmain[indnoexist[i]].filename=filenamenow
endfor
count=n_elements(dmain)
if cntbad gt 0 then begin
  indkeep=nind(count,indbad)
  dmain=dmain[indkeep]
  count=n_elements(dmain)
endif

return,dmain

end
