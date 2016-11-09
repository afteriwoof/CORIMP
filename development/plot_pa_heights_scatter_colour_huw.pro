pro jason,filter=filter

file=home()+'/20000102_info.sav'
restore,file

if keyword_set(filter) then begin
  nind=identify_outliers_2d(image_no,heights,[5,900],comp=ind,sig=2.)
  index_many_arrays,ind,heights,image_no,pos_angles
endif

ind=where(pos_angles gt 180)
pos_angles[ind]=pos_angles[ind]-360

ctload,0
plot,image_no,heights,/psym,/nodata;,xra=[20,70]
ctload,13
for i=-55,15,1 do begin
  ind=where(abs(pos_angles-i) lt 0.5,cnt)
  if cnt gt 0 then $
  oplot,image_no[ind],heights[ind],color=((i+55)*255./70.),/psym
endfor
colorbar,minra=-55,maxra=15,ncol=255,pos=[0.7,0.2,0.9,0.3],/norm,tit='Position angle'
ctload,0

end