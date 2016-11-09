function nrgf,im0,ht0,indmn,av=av,st=st,hts=hts, $
		nopoly=nopoly,maxbin=maxbin, $
		coeffav=coeffav,coeffst=coeffst

if not(keyword_set(maxbin)) then maxbin=100
im=im0[indmn] & ht=ht0[indmn]
hts=min(ht)+findgen(maxbin)*(max(ht)-min(ht))/(maxbin-1.)
rebin_huw,im,ht,hts,av,st
ind=where(finite(av) eq 1 and finite(st) eq 1)
av=av[ind] & st=st[ind] & hts=hts[ind]

if not(keyword_set(nopoly)) then begin
	av=alog10(av) & st=alog10(st)
	ss=abs(st-median(st,7))
	m=stddev(ss);,/nan)
	inds=where(ss lt m*0.7,cnt)
	if cnt gt 100 then begin
		hts=hts[inds] & av=av[inds] & st=st[inds]
	endif

	coeffav=poly_fit(hts,av,4,yfit=avf)
	av=avf
	coeffst=poly_fit(hts,st,4,yfit=stf)
	st=stf

	im=im0
	im[indmn]=temporary(im[indmn])-10^interpol(av,hts,ht)
	im[indmn]=temporary(im[indmn])/(10^interpol(st,hts,ht))

	av=10^av
	st=10^st

endif else begin
	im=im0
	im[indmn]=temporary(im[indmn])-interpol(av,hts,ht)
	im[indmn]=temporary(im[indmn])/interpol(st,hts,ht)
endelse


return,im

end