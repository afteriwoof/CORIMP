;+
; Project     : SOHO - CDS
;
; Name        : JSMOVIE2
;
; Purpose     : Make a Javascript movie HTML file for a series of GIF/JPEG images
;              
;
; Category    : Imaging
;
; Explanation : Program reads a template HTML file 
;               and replaces key parameters with user specified values
;
; Syntax      : IDL> jsmovie,file,images
;
; Inputs      : FILE = filename to which Javascript code will be written
;                      [def=jsmovie_new.html]
;               IMAGES = array of image filenames (e.g. ['frame0.gif','frame1.gif..])
;                  or single filename with individual image filenames
; Opt. Inputs : None
;
; Outputs     : None other than Javascript HTML file
;
; Opt. Outputs: None
;
; Keywords    : DELAY = millisecond delay between frames [def=250]
;               INCREMENT  = % increment for speed control [def= 10]
;               URL = optional URL path to images [def = relative to current dir]
;               SIZE = optional pixel size of images as 2-d vector [nx,ny]
;               TITLE = optional HTML title
;               BORDER, CELL = optional border width & cellpadding for image
;                              frame (def = 10 & 8 pixels)
;               TEMPLATE = template file name [def= "jsmovie_temp.html"]
;               CONTEXT = name of IMAGE to use for context window
;                (URL of context IMAGE must be same as that of movie IMAGE files)
;               CTITLE = optional title for context window
;               PERCENT = % to resize image
;               VERBOSE = print some progress messages
;               OUTPUT  = direct HTML to STDOUT instead of file
;               TIMES   = string array of times for input images
;               NO_RANGE   = set to inhibit RANGE display
;               FRANGE  = frame range to include [start,end]
;               REFRESH = seconds after which to refresh page automatically
;
;
; History     : Version 1,  4-July-1997,  D.M. Zarro (NASA/GSFC) - Written
;               Version 2,  4-July-1998,  D.M. Zarro.  
;                 - Added option for file list input
;               Version 3,  2-October-1998,  D.M. Zarro.  
;                 - Added auto determining of IMAGE file size
;               Version 4,  9-October-1998,  D.M. Zarro.  
;                 - Added context image option
;               Version 5,  14-October-1998,  D.M. Zarro.  
;                 - Modularized
;               Version 6,  29-Jan-1999, Zarro (SM&A) 
;                 - removed stringent check that all IMAGEs be present
;                 - removed unnecessary common block
;                 - added JPEG support
;               Version 6.5, 16-April-1999, Zarro (SM&A/GSFC)
;                 - added OUTPUT, VERBOSE, & TIMES keywords
;                Version 7, 20-May-1999, S.L.Freeland, LMSAL
;                 -  Added /RANGE keyword and function
;               Version 8, 20-Feb-2000, Zarro (SM&A/GSFC)
;                 - added FRANGE, REFRESH, NO_RANGE, and merged previous changes 
;		Version 9, 04-Apr-2002, William Thompson, GSFC
;			Changed "<img...>" for Netscape 6.2 compatibility
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro jsmovie2,file,images,url=url,delay=delay,increment=increment,$
      context=context,template=template,size=gsize,title=title,no_range=no_range,$
      force=force,border=border,cell=cell,ctitle=ctitle,percent=percent,$
      output=output,verbose=verbose,times=times,frange=frange,refresh=refresh,$
      range=range

if (datatype(images) ne 'STR') then begin
 message,'Syntax -> jsmovie,output_html_file,input_image_images',/cont
 return
endif

verbose=keyword_set(verbose)
output=keyword_set(output)
if output then verbose=0

;-- first look for script template in standard SSW place

if datatype(template) eq 'STR' then template_file=template else $
 template_file='$SSW/gen/idl/http/jsmovie_temp2.html' 

chk=loc_file(template_file,count=count)

;-- if not found, check IDL !path

if (count eq 0) then begin
 break_file,template_file,tdsk,tdir,tname,text
 chk=find_with_def(tname+text,!path)
endif

if chk(0) eq '' then begin
 message,'template file "'+template_file+'" not found',/cont
 return
endif

template_name=chk(0)
if verbose then message,'using template file --> '+template_name,/cont

;-- read template_name

jsfile=rd_ascii(template_name)
if n_elements(jsfile) eq 1 then begin
 message,'invalid template file: '+template_name,/cont
 return
endif

;-- check where to output HTML (def = current directory)

if datatype(file) ne 'STR' then file='jsmovie_new.html'
break_file,file,fdsk,fdir,fname,fext
floc=trim(fdsk+fdir)
cd,curr=cdir
if floc eq '' then floc=cdir
chk=test_dir(floc)
if fext eq '' then fext='.html'
fname=concat_dir(floc,fname+fext)

;-- check if input images is a single file containing list of image file names

image_names=images
if n_elements(images) eq 1 then begin
 chk=loc_file(images,count=count)
 if count gt 0 then begin
  lfile=chk(0)
  image_names=rd_ascii(lfile)
 endif
endif
 
;-- check for non-IMAGE file inputs

imax=n_elements(image_names)
ok=where(trim(image_names) ne '',imax)
if imax eq 0 then begin
 message,'found all blank image file names',/cont
 return
endif
image_names=image_names(ok)
 
if n_elements(frange) eq 2 then begin
 fmin=min(frange) & fmax=max(frange)
 if (fmin ge 0) and (fmin lt imax) and $
    (fmax ge 0) and (fmax lt imax) then begin
  image_names=image_names(fmin:fmax)
  imax=n_elements(image_names)
 endif else begin
  message,'FRANGE out of range',/cont
  return
 endelse
endif

;-- check keywords

if not exist(border) then border=10
if not exist(cell) then cell=8
if not exist(delay) then delay=250.
if not exist(increment) then increment=50.
if datatype(title) eq 'STR' then stitle=title

;-- check if refreshing

meta='<meta http-equiv="Refresh"'
meta_loc=grep(meta,jsfile,index=index)

if index(0) gt -1 then begin
 if is_number(refresh) then begin
  jsfile(index(0))='<meta http-equiv="Refresh" content='+trim(refresh)+'>' 
 endif else jsfile(index(0))=''
endif

;-- check if RANGE display is switched off

if keyword_set(no_range) then begin
 range_loc=grep('show_range=true',jsfile,index=index)
 if index(0) gt -1 then jsfile(index(0))='var show_range=false'
 fstart_loc=grep('NAME="fstart"',jsfile,index=index)
 if index(0) gt -1 then jsfile(index(0))=''
 fstop_loc=grep('NAME="fstop"',jsfile,index=index)
 if index(0) gt -1 then jsfile(index(0))=''
endif

;-- update titles

if datatype(stitle) eq 'STR' then begin
 def_label='<h2> Javascript Movie Player'
 jtitle=grep(def_label,jsfile,index=index)
 if index(0) gt -1 then begin
  if trim(title) ne '' then jtitle='<H2>'+title+'</H2>' else jtitle=''
  jsfile(index(0))=jtitle
 endif
endif

;-- update TABLE parameters

jtable=grep('<TABLE',jsfile,index=index)
if index(0) gt -1 then begin
 jtable='<TABLE BORDER="'+num2str(border)+'" CELLPADDING="'+$
          num2str(cell)+'">'
 jsfile(index(0))=jtable
endif

;-- set movie URL to location of IMAGE files (unless user specifies URL)

break_file,image_names(0),gdsk,gdir
if datatype(url) ne 'STR' then surl=trim(gdsk+gdir) else surl=trim(url)
if surl eq '' then surl='.'
have_delim=(rstrpos(surl(0),'/')) eq (strlen(surl(0))-1)

nurl=n_elements(surl)
if surl(0) ne '' then begin
 jimax=grep('var url_path',jsfile,index=index)
 if index(0) gt -1 then begin
  jsfile(index(0))='var url_path = "'+surl(0)+'"'
 endif
endif 

;-- set context IMAGE file and title

if datatype(context) eq 'STR' then begin
 context_par='var context = "'+context+'"'
 jcontext=grep('var context',jsfile,index=index)
 if index(0) gt -1 then begin
  jsfile(index(0))=context_par
 endif
 if datatype(ctitle) eq 'STR' then begin
  context_title='var ctitle ="'+ctitle+'"'
  jcontext=grep('var ctitle',jsfile,index=index)
  if index(0) gt -1 then begin
   jsfile(index(0))=context_title
  endif
 endif
endif else begin
 fcontext=grep('popUp(url_context',jsfile,index=index)
 if (index(0) gt -1) then jsfile(index(0))=''
endelse

;-- get actual IMAGE dimensions from first file 

nx=0 & ny=0
chk=loc_file(image_names(0),count=count)
if count eq 0 then chk=loc_file(concat_dir(surl(0),image_names(0)),count=count)
if count gt 0 then begin
 case 1 of
  valid_gif(chk(0),dim): begin
   nx=dim(0) & ny=dim(1)
  end
  valid_jpeg(chk(0),dim): begin
   nx=dim(0) & ny=dim(1)
  end
  else:do_nothing=1
 endcase
 if (nx gt 0) and (ny gt 0) and verbose then begin
  message,'input IMAGE size: '+num2str(nx)+','+num2str(ny),/cont
 endif
endif

;-- override with SIZE keyword

if exist(gsize) then begin
 gx=gsize(0) & gy=gx
 if n_elements(gsize) gt 1 then gy=gsize(1)
 if keyword_set(percent) then begin
  if (nx gt 0) and (ny gt 0) then begin
   nx=nint(nx*gx/100.) & ny=nint(ny*gy/100.)
  endif
 endif else begin
  nx=gx & ny=gy
 endelse
 if (nx gt 0) and (ny gt 0) and verbose then $
  message,'output IMAGE size: '+num2str(nx)+','+num2str(ny),/cont
endif

;-- set movie control variables
 
inc=num2str(1.+increment/100.,format='(f5.2)')
imax=num2str(imax)
sdelay=num2str(long(delay))
control_par='var imax = '+imax+', inc = '+inc+', delay = '+sdelay

jimax=grep('var imax',jsfile,index=index)
if index(0) gt -1 then jsfile(index(0))=control_par

;-- presize Image object 

if (nx gt 0) and (ny gt 0) then begin
 jsize=grep('var iwidth',jsfile,index=index)
 control_par='var iwidth = '+num2str(nx)+',iheight = '+num2str(ny)
 if index(0) gt -1 then jsfile(index(0))=control_par
endif

;-- load images in cache

break_file,image_names,dsk,dir,gnames,gext
gimage_names=gnames+gext
if have_delim then delim='' else delim='/'

for i=0,imax-1 do begin
 ifile='url_path+"'+delim+gimage_names(i)+'"'
 istring='urls['+num2str(i)+']='+ifile
 new_string=append_arr(new_string,istring)
endfor

jimg=grep('urls[0]=',jsfile,index=index)
if index(0) gt -1 then begin
 jsfile(index(0))=''
 pre=jsfile(0:index(0))
 post=jsfile(index(0)+1:*)
 jsfile=pre
 for i=0,imax-1 do jsfile=[jsfile,new_string(i)]
 jsfile=[jsfile,post]
endif

;-- display first image while loading

jsrc=grep('NAME=animation',jsfile,index=index)
if index(0) gt -1 then begin
 first_img=surl(0)+delim+gimage_names(0)
;jsrc='<img src = "'+first_img+'" NAME=animation ALT="FRAME"'
 jsrc='<img NAME=animation ALT="FRAME"'
 if (nx gt 0) and (ny gt 0) then begin
  jsrc=jsrc+' width='+num2str(nx)+' height='+num2str(ny)
 endif
 jsrc=jsrc+'>'
 jsfile(index(0))=jsrc
endif

;-- record name of template file

jtemp=grep('(template)',jsfile,index=index)
if index(0) gt -1 then begin
 temp='<B>Template</B>:<I><SCRIPT>document.write("'+template_name+'")</SCRIPT></I></BR>'
 jsfile(index(0))=temp
endif

if keyword_set(output) then printf,-1,jsfile else $
 file_append,fname,jsfile,/new

if verbose then message,'wrote Javascript file: '+fname,/cont

return & end

