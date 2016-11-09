pro disp,d
pa=wrap_n(!radeg*atan(-d.x,d.y),360)
ht=sqrt(d.x^2+d.y^2)
t=(d.t-anytim2tai('2011/01/13 00:00'))/3600
ctload,0
plot,t,ht,/nodata,/xst
ctload,13
for ipa=0,360 do begin
  ind=where(round(pa) eq ipa,cnt)
  if cnt gt 0 then oplot,t[ind],ht[ind],col=ipa*255./360.,/psym
endfor
ctload,0
end


function call_detect

if n_params() eq 0 then begin
  instr='c2'
  startdate='2011/01/13 00:00'
  enddate='2011/01/14 23:59'
endif

dirs=anytim2cal(timegrid(startdate,enddate,/days),form=11,/date)

topdir=home()+'/data/processed_data'
lascodir=topdir+'/soho/lasco/separated/fits/'+dirs

files=file_search(lascodir,'dynamics_*_soho.fits.gz',count=nfiles)

return,detect(files)


end


function detect,files

nfiles=n_elements(files)

thresh=0.01
ksm=[9,11]

for ifile=0,nfiles-1 do begin
  print,files[ifile]
  instr=strmatch(file_basename(files[ifile]),'*_C2.cme.fits.gz')?'c2':'c3'
  im=readfits_corimp(files[ifile],hdr)
  get_ht_pa_2d_corimp,hdr.naxis1,hdr.naxis2,hdr.crpix1,hdr.crpix2,pix_size=hdr.pix_size/hdr.rsun, $
                            xvoid,yvoid,ht,pa,xx=xx,yy=yy
  ks=instr eq 'c2'?ksm[0]:ksm[1]
  ind=morph_open(im gt thresh,replicate(1,ks,ks))
  ind=where(ind,cnt)
  if cnt gt 0 then begin
    index_many_arrays,ind,xx,yy,im
    build_loop_arrays,replicate(anytim2tai(hdr.date_obs),cnt),t,xx,x,yy,y,im,z
  endif
endfor

d={t:t,x:float(x),y:float(y),z:float(z),thresh:thresh,ks:ksm,files:files}

return,d

end
