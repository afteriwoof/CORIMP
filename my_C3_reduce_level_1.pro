; Code to take the steps from REDUCE_LEVEL_!.pro and perform them individually myself.

; Created: 27-08-08

; Last Edited: 27-08-08

pro my_C3_reduce_level_1, fls, in, calibda, unwarpda

szfls = size(fls, /dim)

init = lasco_readfits(fls[0], in_init)

sz = size(init, /dim)

da = fltarr(sz[0], sz[1], szfls[0])
sz = size(da, /dim)
delvarx, szfls

in = replicate(in_init, sz[2])

calibda = fltarr(sz[0], sz[1], sz[2])
unwarpda = calibda

; read in the data
for k=0,sz[2]-1 do begin
	tempim = lasco_readfits(fls[k], tempin)
	da[*,*,k] = tempim
	in[k] = tempin
endfor

; calibrate the data
;for k=0,sz[2]-1 do begin
;	calibda[*,*,k] = c3_calibrate(da[*,*,k], in[k])
;endfor

; get the background for the data and calibrate it
;bkg = getbkgimg(in[0], bkgin)
;bkg = c3_calibrate(bkg, bkgin)

for k=0,sz[2]-1 do calibda[*,*,k] = c3_massimg('bkgrd.fts', fls[k])

; correction for the distortion
for k=0,sz[2]-1 do begin
	unwarpda[*,*,k] = c3_warp(calibda[*,*,k], in[k])
endfor

;*************
; Now copying reduce_level_1.pro to update the other information

for k=0,sz[2]-1 do begin

	; Begin Fits Header Recreation
	get_utc, today, /ecs
	dte = today
	today_dte = strmid(dte,0,4)+'_'+strmid(dte,5,2)+'_'+strmid(dte,8,2)+'T'+strmid(dte,11,12)
	FXHMAKE, fits_hdr, unwarpda[*,*,k]
	fxaddpar, fits_hdr, 'DATE', today_dte
	fxaddpar,fits_hdr,'FILENAME',in[k].filename
	fxaddpar,fits_hdr,'FILEORIG',in[k].fileorig
	fxaddpar,fits_hdr,'DATE-OBS',in[k].date_obs
	fxaddpar,fits_hdr,'TIME-OBS',in[k].time_obs
	fxaddpar,fits_hdr,'EXPTIME', in[k].exptime
	fxaddpar,fits_hdr,'TELESCOP',in[k].telescop
	fxaddpar,fits_hdr,'INSTRUME',in[k].instrume
	fxaddpar,fits_hdr,'DETECTOR',in[k].detector
	fxaddpar,fits_hdr,'READPORT',in[k].readport
	fxaddpar,fits_hdr,'SUMROW',  in[k].sumrow
	fxaddpar,fits_hdr,'SUMCOL',  in[k].sumcol
	fxaddpar,fits_hdr,'LEBXSUM', in[k].lebxsum
	fxaddpar,fits_hdr,'LEBYSUM', in[k].lebysum
	fxaddpar,fits_hdr,'FILTER',  in[k].filter
	fxaddpar,fits_hdr,'POLAR',   in[k].polar
	fxaddpar,fits_hdr,'COMPRSSN',in[k].comprssn
	; ++ required for get_exp_factor.pro
	fxaddpar,fits_hdr,'MID_DATE',in[k].mid_date,'WARNING: Original (Uncorrected)'
	fxaddpar,fits_hdr,'MID_TIME',in[k].mid_time,'WARNING: Original (Uncorrected)'
	; ++
	fxaddpar,fits_hdr,'R1COL',   in[k].r1col
	fxaddpar,fits_hdr,'R1ROW',   in[k].r1row
	fxaddpar,fits_hdr,'R2COL',   in[k].r2col
	fxaddpar,fits_hdr,'R2ROW',   in[k].r2row
	fxaddpar,fits_hdr,'LEVEL', '1.0'

	histlen=1
	cmntlen=1
	inc = 0
	WHILE histlen GT 0 DO BEGIN
		histlen = strlen(in[k].history[inc])
		IF histlen GT 0 and strpos(in[k].history[inc],'bias') LT 0 THEN $		; different bias used in level 1
			fxaddpar,fits_hdr,'HISTORY', ' '+strcompress(in[k].history[inc])
		inc = inc+1
	ENDWHILE
	inc = 0
	WHILE cmntlen GT 0 DO BEGIN
		cmntlen = strlen(in[k].comment[inc])
		IF cmntlen gt 0 then fxaddpar,fits_hdr,'COMMENT', ' '+in[k].comment[inc]
		inc = inc+1
	ENDWHILE

	version= '@(#)my_C3_reduce_level_1.pro'
	ver = strmid(version, 4, strlen(version))
	fname = in[k].filename
	source = strmid(fname, 1, 1)
	if (source EQ 'm') then fname = fls[k]
	dot = strpos(fname, '.')
	root = strmid(fname, 0,dot)
	outname = root+'_my_reduce_level_1.fts'
	s = ver+",'"+fname+"','"+outname+"'"
	fxaddpar,fits_hdr,'HISTORY', ' '+strcompress(s)


	; Now more update stuff from later in reduce_level_1.pro

	tcr = adjust_hdr_tcr(fits_hdr,/verb)
	IF tcr.date EQ "" THEN BEGIN
		r = get_roll_or_xy(in[k],'ROLL',rsrc,/degrees,/median)
		; To correct, rotate image r degrees CCW!
		fxaddpar,fits_hdr,'HISTORY',' ROLL: '+strcompress(cmnver[0])+': '+strcompress(rsrc)
		IF cmnver[1] NE "" THEN fxaddpar,fits_hdr,'HISTORY',' '+strcompress(cmnver[1])
			c= get_sun_center(in[k],csrc,/median,FULL=1024)
			cx=c.xcen
			cy=c.ycen
			fxaddpar,fits_hdr,'HISTORY',' '+strcompress(cmnver)+': '+strcompress(csrc)
			cmnt='WARNING: Interim value ' 
			tcmnt='WARNING: Original uncorrected value'
			obstime=in[k].time_obs
			obsdate=in[k].date_obs
		ENDIF ELSE BEGIN
			; HISTORY (time file, time orig, position file) added in adjust_hdr_tcr
			r = tcr.roll
			cx = tcr.xpos 
			cy = tcr.ypos
			cmnt="Final Correction "
			tcmnt=cmnt
			obsdate=tcr.date
			obstime=tcr.time
		ENDELSE
	; now correct for nominal inverted roll
	IF in[k].crota1 GT 0 THEN BEGIN
		rectify=in[k].crota1
		cntr=511.5
		x=cx-cntr
		y=cy-cntr
		cx=cntr + x*cos(rectify*!pi/180.) - y*sin(rectify*!pi/180.)
		cy=cntr + x*sin(rectify*!pi/180.) + y*cos(rectify*!pi/180.)
		IF rectify EQ 180 THEN BEGIN
			msg="Image rotated 180 degrees."
			print,msg
			printf,lulog,msg
			fxaddpar,fits_hdr,'HISTORY',' '+strcompress(msg)
			unwarpda[*,*,k] = ROTATE ( temporary(unwarpda[*,*,k]) , 2 )
			r=r-180.
		ENDIF	

	ENDIF 
	
	xsumming = (in[k].sumcol>1)*(in[k].lebxsum>1)
	ysumming = (in[k].sumrow>1)*(in[k].lebysum>1)
	summing = xsumming*ysumming
	IF  summing GT 1 THEN unwarpda[*,*,k] = fixwrap(unwarpda[*,*,k])
	; If image is summed, fix integer wrapping
	
	xc = (cx - in[k].r1col+20)/xsumming
	yc = (cy - in[k].r1row+ 1)/ysumming

	r_hdr = -1*r
	crpix_x = xc+1		; IDL to FITS coordinates
	crpix_y = yc+1



	; ** Continue adding updated or new values to header. **
	;
	;sxdelpar,fits_hdr,'READPORT'	; no longer needed in level 1
	fxaddpar,fits_hdr,'FILENAME',outname
	FXADDPAR,fits_hdr,'CRPIX1',crpix_x,' sun center pixel (X), '+cmnt
	FXADDPAR,fits_hdr,'CRPIX2',crpix_y,' sun center pixel (Y), '+cmnt
	FXADDPAR,fits_hdr,'COMMENT',' FITS coordinate for center of full image is (512.5,512.5).'
	FXADDPAR,fits_hdr,'CROTA' ,r_hdr,cmnt
	FXADDPAR,fits_hdr,'COMMENT', ' Rotate image CROTA degrees CW to correct.'
	FXADDPAR,fits_hdr,'CROTA1',r_hdr
	FXADDPAR,fits_hdr,'CROTA2',r_hdr
	;FXADDPAR,fits_hdr,'HISTORY',cmnver+', '+trim(string(xc))+', '+trim(string(yc))+', '+trim(string(r))+' Deg'
	FXADDPAR,fits_hdr,'CRVAL1',0
	FXADDPAR,fits_hdr,'CRVAL2',0
	FXADDPAR,fits_hdr,'CTYPE1','ARCSEC'
	FXADDPAR,fits_hdr,'CTYPE2','ARCSEC'
	platescl = GET_SEC_PIXEL(in[k])
	;FXADDPAR,fits_hdr,'HISTORY',cmnver
	FXADDPAR,fits_hdr,'CDELT1',platescl,' Arcsec/pixel'
	FXADDPAR,fits_hdr,'CDELT2',platescl,' Arcsec/pixel'
	FXADDPAR,fits_hdr,'XCEN',0+platescl*((in[k].naxis1+1)/2. - crpix_x),' Arcsec'
	FXADDPAR,fits_hdr,'YCEN',0+platescl*((in[k].naxis2+1)/2. - crpix_y),' Arcsec'
	
;    ; Add adjust_date_obs version here from common block

	utcdt=anytim2utc(obsdate+'T'+obstime)
	newdt=utc2str(utcdt)	; use dashes instead of slashes
	fxaddpar, fits_hdr, 'DATE-OBS',newdt,tcmnt
	fxaddpar, fits_hdr, 'TIME-OBS',"",' Obsolete'
	FXADDPAR, fits_hdr, 'DATE_OBS',newdt
	
	rsun = get_solar_radius(in[k])	
	fxaddpar, fits_hdr, 'RSUN',rsun,' Arcsec'
	;fxaddpar, fits_hdr, 'NMISSING',nmissing,' Number of missing blocks.'
	;printf,lulog,'NMISSING = ',string(nmissing)
	
	;FXADDPAR, fits_hdr, 'MISSLIST',missing_string
	FXADDPAR, fits_hdr, 'BUNIT','MSB',' Mean Solar Brightness'

	camera = strupcase(strtrim(in[k].detector, 2))
	IF camera EQ 'C3' and in[k].filter EQ 'Clear' THEN BEGIN
		scalemin = 0	;2e-13
		scalemax = 6.5e-9
		REDUCE_STATISTICS2,unwarpda[*,*,k],fits_hdr, SATMAX=scalemax
		;
		;   Convert image to integer type
		;
		datamax=fxpar(fits_hdr,'DATAMAX')
		datamin=fxpar(fits_hdr,'DATAMIN')
		datasat=fxpar(fits_hdr,'DATASAT')
		bscale = (scalemax-scalemin)/65536
		bzero=bscale*32769
		help,bscale,bzero
		nz=where(unwarpda[*,*,k] NE 0)
		bout=fltarr(in[k].naxis1,in[k].naxis2)
		bout[nz] = ROUND(((unwarpda[nz]<scalemax>scalemin)-bzero)/bscale)
		bout = FIX(bout)
		fxaddpar, fits_hdr,'BSCALE',bscale,'Data value = FITS value x BSCALE + BZERO'
		fxaddpar, fits_hdr,'BZERO',bzero
		fxaddpar, fits_hdr,'BLANK',fix(0)
		fxaddpar, fits_hdr,'COMMENT',' Data is scaled between '+trim(string(scalemin))+' and '+trim(string(scalemax))
		fxaddpar, fits_hdr,'COMMENT',' Percentile values are before scaling.'
	ENDIF ELSE BEGIN

		reduce_statistics2,unwarpda[*,*,k],fits_hdr
		bout = float(unwarpda[*,*,k])
		datamax=fxpar(fits_hdr,'DATAMAX')
		datamin=fxpar(fits_hdr,'DATAMIN')	
	
	ENDELSE
	
	maxmin,bout
	yymmdd=strmid(in[k].date_obs,2,2)+strmid(in[k].date_obs,5,2)+strmid(in[k].date_obs,8,2)
	dlm = get_delim()
	sd = './'
	datedir=GETENV_SLASH('RED_L1_PATH')+yymmdd+dlm                  ; KB 050801
	IF not file_exist(datedir) THEN spawn,'mkdir '+datedir ,/sh
	IF not file_exist(sd) THEN spawn,'mkdir '+sd ,/sh	        ; make sure directory exists
	CD, sd, CURRENT=cur_dir
	;endif else sd=sd05
	;neg= where(b lt 0.0D,cnt)
	;if(cnt gt 0) then b(neg)= 0.0D
	;printf,lulog,'Output directory = '+sd
	;print,'Output directory = '+sd

	print,'Writing FITS file to '+sd+dlm+outname
	;writefits,outname,bout,fits_hdr       
	writefits,outname,unwarpda[*,*,k],fits_hdr       
   	;Write disk FITS file (bout is previously rounded)
	
endfor
	
	
end
