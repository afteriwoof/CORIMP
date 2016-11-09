PRO display_angle, dmod, dang, drange=drange, pix_step=pix_step

dmodorig=dmod
dangorig=dang


win_xsize=(size(dmod))[1]
win_ysize=(size(dmod))[2]

window,0,xsize=win_xsize/2.,ysize=win_ysize/2.,tit='(0) Modulus',xpos=200,ypos=200
loadct,0
;STOP
;tvscl,dmod^0.25
plot_image, dmod^0.25

loadct,0
!p.background=255
window,1,xsize=win_xsize,ysize=(win_ysize+100),tit='(1) Angle',xpos=(210+win_xsize),ypos=200
;STOP
tvscl,dmod^0.25
;plot_image, dmod^0.25
loadct,6

colorbar,divisions=4,ticknames=['0','90','180','270','360']

dang=dang+180
wrap=where(dang GT 360)
dang(wrap) = dang(wrap)-360

;threshold dmod

IF KEYWORD_SET(drange) THEN BEGIN $
    IF MIN(dmod) LT drange[0] THEN dmod (where(dmod LT drange[0])) = 0
    IF MAX(dmod) GT drange[1] THEN dmod (where(dmod GT drange[1])) = 0
ENDIF

dangcolor=FIX(256*(dang/max(dang)))


;for i=0,1023 do for j=0,1023 do $
;	arrow2,i,j,dang[i,j],dmod[i,j],/norm

IF KEYWORD_SET(pix_step) THEN pix_step=pix_step ELSE pix_step=1

;dmod_show=win_xsize*dmod/MAX(dmod)

FOR i=0,win_xsize-1,pix_step DO $
    FOR j=0,win_ysize-1,pix_step DO $
    	IF  dmod[i,j] NE 0 THEN $
	    ;arrow2,i,j,dang[i,j],dmod_show[i,j],/angle,/device,hsize=3,color=dangcolor[i,j]
    	    arrow2,i,j,dang[i,j],dmod[i,j],/angle,/device,hsize=3,color=dangcolor[i,j]


dmod=dmodorig
IF KEYWORD_SET(drange) THEN BEGIN 
    IF MIN(dmod) LT drange[0] THEN dmod (where(dmod LT drange[0])) = drange[0]
    IF MAX(dmod) GT drange[1] THEN dmod (where(dmod GT drange[1])) = drange[1]
ENDIF


loadct,0
window,2,xsize=1400,ysize=700

;mask=where(dmod EQ 0,nmask)
;tst=(dmod*0.)+1
;IF nmask NE 0 THEN tst(mask)=0
;dmod=dmod*tst
;dang=dang*tst

!p.multi=[2,2,1]

;STOp
contour,sigrange(dmod),nlevels=30,/fill,/xst,/yst

loadct,6
contour,dang,nlevels=30,/fill,/xst,/yst
loadct,6
;contour,dmod,nlevels=15,/over
colorbar,divisions=4,ticknames=['0','90','180','270','360'],pos=[0.51,0.1,0.56,0.9],/vert

!p.multi=[2,2,2]

dmod=dmodorig
dang=dangorig

;reset the background
!p.background=0

END
