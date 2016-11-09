pro evt_grid, evt_timesx, evt_stoptimesx, labels=labels, data=data, 	$
        noline=noline, notick=notick, labonly=labonly,                  $
        linestyle=linestyle, thick=thick, color=color,  		$
	yrange=yrange, fillstyle=fillstyle, 				$ ; not used yet
	labsize=labsize, labcolor=labcolor, labthick=labthick, $
	labpos=labpos, align=align, noarrow=noarrow, vertical=vertical, $, imdebug=imdebug 
	ticks=ticks, tickpos=tickpos, ticklen=ticklen, $
        arrow=arrow, head=head, $
        quiet=quiet,        imagemap_coord=imagemap_coord, imap=imap, $
        imnoconvert=imnoconvert, imcircle=imcircle, imdebug=imdebug , $
        labdata=labdata, no_blank=no_blank, background=background
;+
;NAME:
;	evt_grid
;
;PURPOSE:
;	To annotate previously drawn utplot output with event times
;
;CALLING SEQUENCE:
;	evt_grid,evt_times			
;       evt_grid,evt_times [labels=labels, linestyle=linestyle, color=color, $
;	                   labsize=labsize, labcolor=labcolor, labpos=labpos,$
;			   align=align, vertical=vertical, noarrow=noarrow,  $
;			   /ticks, tickpos=tickpos, ticklen=ticklen]
;CALLING EXAMPLES:
;	(following any utplot)
;       evt_grid,index([0,20]),/labels		; label with times
;	evt_grid,index([0,20]),labels=['Image A', 'Image B']	
;       evt_grid,'2-dec-92 12:45', linestyle=3, thick=2, label='EVENT X'
;	evt_grid,rmap,/ticks			;ticks instead of full lines
;       evt_grid,index,/arrow			; downward pointing arrows
;       evt_grid,index,/arrow,/head             ; upward pointing arrows
;       evt_grid,index,labdata=thumbdata        ; annotate with images    
;                                               ; (ssw 'index,data' 2d or 3d)
;
;       DUMMY DEMO: 
;          plot_goes,'2-dec-93',24
;          evt_grid,timegrid('06:00 2-dec-93',nsamp=5,hours=2), $
;		/label,labpos=indgen(5)*.04+.7,linestyle=indgen(5) [,/align]
;
;OPTIONAL KEYWORD PARAMTERS:
;       linestyle - for vertical lines
;       thich	  - ditto
;       color     - ditto
;       ticks     - use ticks, not vertical line (a tick IS a short vert line)
;       tickpos   - position of center of tick in normalized coords (def=.85)
;	ticklen   - length of tick in normalized coords (def=.03)
;	arrow     - ticks have arrow head (use arrow.pro) - downward pointing
;       head      - upward point arrows (via arrow2.pro) 
;       labdata     - if data array (2D/3D) supplied, use these for 
;                   the "labels" - for example, annotate a utplot
;                   with images
;       labels - labels for annotation
;       labpos -   y position in normalized coords for optional label position
;                  (/data or  labpos lt 0 or gt 1 implies data coordinates)
;       labcolor - color for optional labels
;       labsize  - size for optional labels
;       vertical - rotate labels (vertical)
;	align - alingment for labels (default=center, see xyouts align desc)
;		(1=leftjustify, 0=right justify with respect to grid line)
;       noarrow - if set, dont draw arrows for right/left justified labels
;       data - if set, label positions are in DATA coordinates 
;       imap - if set, calculate imagemap coords (return via IMAGEMAP_COORD
;              (works only with LABELS input)
;       imagemap_coord - if set, calculate imagemap coordinates of LABELS
;       imcircle=imcircle - if set, IMAGEMAP_COORD are "xc,yc,diam"
;                           (default is rectangle "minx,miny,maxx,maxy" 
;       Note: (imagemap) - this routine returns a string array 1:1 with
;                          number of input times (annotations) for generation
;                          of imagemaps (clickable utplots for example)
;       no_blank - (switch) - if set, do not do the historical "cleaning"
;                             of area around the annotation
;       background - if supplied -and- area around label is "cleaned" using
;                    this value (default is !p.background) - ignored if
;                    NO_BLANK is set
;
;HISTORY:
;	Written S.L.Freeland, 3-Dec-1993 (derived from fem_grid.pro) 
;	5-Dec-1993 (SLF) - add ticks, tickpos, ticklen, arrow	                
;      12-Jul-1994 (SLF) - invert color if PS 
;      22-Sep-1994 (SLF) - added stoptimes positional parameter (for ranges)
;                          added FILLRANGE switch
;       8-oct-1994 (SLF) - added QUIET switch
;       1-nov-1994 (SLF) - allow ytype=1 (log)
;       7-apr-1995 (SLF) - corrected problem for invalid data
;			   (mis align between labels and events)
;      25-apr-1995 (SLF) - add DATA keyword, allow labpos in data coords
;       6-aug-1995 (SLF) - hide IDL inconsistance on !y.type/!y.crange...
;       4-mar-1998 (SLF) - use n_elements in instead of keyword_set
;                          add LABONLY, NOLINE, NOTICK (synonyms)
;      29-Feb-2000 (SLF) - changed 'endif' to 'endcase'
;                          ( 5.3 compiler enforces this end-matching )
;      24-Jul-2000 (SLF) - merge 'label_only' change (annotation)
;      28-Feb-2002 (SLF) - add IMAP,IMAGEMAP_COORD and IMCIRCLE functions 
;                          (calls get_imagemap_coord for each label)
;       6-Mar-2002 (SLF) - add LABDATA keyword and funtion
;       8-May-2002 (SLF) - add a couple of 'anytim' wrappers to extend
;                          function to any SSW input times
;	18-Dec-2002, William Thompson, GSFC, Changed !COLOR to !P.COLOR
;       16-jun-2004 (SLF) - use !p.background for annotate background
;                           (for PostScript) - add /HEAD keyword 
;                           (passed to arrow.pro to invert arrow sense)
;        9-mar-2005 (SLF) - add /NO_BLANK keyword an function
;                           add BACGROUND keyword and function
;
;RESTRICTIONS:
;	Current plot must be UTPLOT/OUTPLOT output
;-
;

; ------------- setup defaults ------------------------

labonly=keyword_set(labonly) or keyword_set(noline) or keyword_set(notick) $
        or data_chk(labdata,/nimage) gt 0
imap=keyword_set(imap)
imdebug=keyword_set(imdebug)
no_blank=keyword_set(no_blank)

if labonly then begin
     ticklen=0.                                 ; inhibit 
     if n_elements(label) eq 0 then label=1     ;
endif 

arrow=keyword_set(arrow) or keyword_set(head) 

if (n_elements(ticks) ne 0) or (n_elements(tickpos) ne 0) $
       or (n_elements(ticklen) ne 0)  or arrow then begin
   if n_elements(ticklen) eq 0 then $
	if keyword_set(arrow) then ticklen=.08 else ticklen=.03		; normalized coord
   if n_elements(tickpos) eq 0 then tickpos=.85
   
   if n_elements(linestyle) eq 0 then linestyle=-1
   if n_elements(yrange) eq 0 then yrange=$
	[tickpos-(ticklen/2),tickpos+(ticklen/2)]
endif

loud=1-keyword_set(quiet)

if n_elements(ncolor) eq 0 then ncolor=!p.color
if n_elements(scolor) eq 0 then scolor=!p.color
; define yrange if not supplied
if not keyword_set(yrange) then begin
   if !y.type and strpos(arr2str(!y.crange),'e') eq -1 then $
       yrange=10.^!y.crange else yrange=!y.crange
   yrange=(convert_coord(!x.crange,yrange,/data,/to_normal))(1,*)
endif
if not keyword_set(fillstyle) then fillstyle=1
if n_elements(linestyle) eq 0  then linestyle=1
if not keyword_set(labsize) then labsize=1.2
if n_elements(labcolor) eq 0 then labcolor=!p.color
if n_elements(color) eq 0 then color=!p.color
if n_elements(align) eq 0 then align=.5			; center over line
if not keyword_set(thick) then thick=1
if n_elements(vertical) eq 0 then laborient=0 else laborient=270
; ------------------------------------------------------------
;
evt_times=anytim(evt_timesx,/int)          ; allow any SSW time
if n_elements(evt_stoptimesx) gt 0 then $
   evt_stoptimes=anytim(evt_stoptimesx,/int) ; (original expected 'int' fmt)

; number of annotations
nevts=n_elements(evt_times)
colors=color
if n_elements(colors) eq 1 then colors = replicate(colors,nevts)
case 1 of 
   n_elements(labcolor) ge nevts: lcolors=labcolor(0:(nevts-1))
   else: lcolors=replicate(labcolor(0),nevts)
endcase   
  
; ----------------- get reference time ----------------------

qtemp=!quiet
getut, xstart=startt, /string			; utplot common block read 
;getut, utbase=startt, /string			; utplot common block read 
stopf=anytim2ints(startt, offset=!x.crange(1))	; last x.crange for stop
ref_time = startt
evt_times=anytim(anytim(evt_times)>anytim(startt),/int)
evt_times=anytim(anytim(evt_times)<anytim(stopf),/int)
; ----------------------------------------------------------------

; ---------------- modify/define labels --------------------------
label=keyword_set(labels) or data_chk(labdata,/nimage) gt 0
if keyword_set(labels) then begin
;  if labels is a switch, use event times for labels
   if 1-data_chk(labels,/string) then labels=anytim(evt_times,/yohkoh,/truncate)
   ljust=[' ','<- ']
   rjust=[' ',' ->']
   larrow=1-keyword_set(noarrow)
   case align of
      0: labels=ljust(larrow) + labels
      1: labels=labels + rjust(larrow)
      else:
   endcase
endif
; --------------------------------------------------------------------

if n_elements(labels) eq 1 and nevts gt 1 then begin
   align=keyword_set(align)
   labels=[strarr(nevts-1),labels]
   if align then labels=reverse(labels)
endif

case 1 of 
   n_elements(labpos) eq 1 and nevts gt 1: labpos=replicate(labpos,nevts)
   1-keyword_set(labpos): labpos= $
      replicate( min(yrange) + (abs(yrange(1)-yrange(0))/2),nevts)
   else:
endcase

lpos=labpos			; dont clobber input

data = (keyword_set(data) or max(lpos) gt 1 or min(lpos) lt 0)
; convert labpos in data coord to normal (plots are via normal)
if data then lpos=(convert_coord(lpos,lpos,/data,/to_normal))(1,*)	

lines=linestyle
if n_elements(lines) eq 1 then lines=replicate(lines,nevts) ; allow array

xsecs=int2secarr(evt_times,ref_time)			; xpos for events
if data_chk(labdata,/nimage) gt 0 then begin 
   secperpix=!x.crange(1)/!d.x_size
   secperhalf=data_chk(labdata,/nx)/2 * secperpix     ; middle of image in X 
   xsecmid=xsecs-secperhalf 
   ; following line constrains tv coords (avoid out of ranger error later)
   xsecs=xsecmid>(!x.crange(0))<(!x.crange(1)-(2.1*secperhalf-1))
endif

ydumm=replicate(!y.crange(0),nevts)
coord=convert_coord(xsecs,ydumm,/data,/to_normal)	; xpos in normal corrd

; ----------- verify times are within current plot range ----------------
;getut, utbase=startt			; CLOBBERS !QUIET
!quiet=qtemp
;stopt=startt + !x.crange(1)
valid = where(xsecs ge !x.crange(0) and xsecs le !x.crange(1),vcount)
case 1 of
   vcount eq 0 and loud: begin
      tbeep
      message,/info,'No input times fall within current plot range
      return
   endcase
   loud and (vcount lt nevts):begin 
         message,/info,'Warning: ' +  $
	strtrim(nevts-vcount,2) + ' input times are outside current plot range'
   endcase
   else:
endcase
; -------------------------------------------------------------

; now draw the lines
blen=.015 * labsize + (laborient/270 *labsize*.02) 	;label buffer (blank out line)
if imap then imagemap_coord=strarr(vcount)
for i=0,vcount-1 do begin
   if keyword_set(arrow) then begin
      arrow2,coord(0,(valid(i))),  yrange(1),coord(0,(valid(i))),  yrange(0), $
	  color=colors(valid(i)), thick=thick,/normal,/solid, head=head
   endif else begin
     if yrange(0) ne yrange(1) then plots,replicate(coord(0,(valid(i))),2),  yrange, 	$
	  linestyle=lines(valid(i)), color=colors(valid(i)), thick=thick,/normal
   endelse

   if label then begin
      if n_elements(background) eq 0 then background=!p.background
      if align eq .5 and (1-no_blank) then $		; blank above and below label
         plots,replicate(coord(0,valid(i)),2),[lpos(i)-blen,lpos(i)+blen+.01], $
	   color=background,/normal, thick=thick
      if imap then dat0=tvrd()
      
      if data_chk(labdata,/nimage) gt i then begin   
        tv,labdata(*,*,valid(i)),coord(0,valid(i)), lpos(valid(i)),/norma
      endif else $ 
      xyouts, coord(0,valid(i)), lpos(valid(i)),/normal,labels(valid(i)), charsize=labsize, $
	 color=lcolors(valid(i)), align=align, orient=laborient
      if imap then begin
         dat1=tvrd()
         imagemap_coord(i)=$
            get_imagemap_coord(dat0,dat1,debug=imdebug, $
                noconvert=imnoconvert, circle=imcircle,/string)
         delvarx,dat0,dat1 
      endif
   endif
endfor

return
end

