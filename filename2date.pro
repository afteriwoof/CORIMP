; 2013-07-11	 Created by Huw, to call in sort_fls.pro

function filename2date,f

fs=strsplit(f,'_.',len=len,count=nst)
isdate=lonarr(nst)
for i=0,nst-1 do begin
  fnow=strmid(f,fs[i],len[i])
  for j=0,len[i]-1 do isdate[i]=isdate[i]+is_number(strmid(fnow,j,1))
endfor

;identify possible dates
ind=where(isdate ge 6,cnt)
if cnt eq 0 then begin
  print,'No dates found in filename!'
  stop
endif
d=''
for i=0,cnt-1 do d=d+strmid(f,fs[ind[i]],len[ind[i]])
date=yyyymmdd2cal(d)

return,date

end
