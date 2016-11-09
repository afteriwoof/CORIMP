function dir_exist, dirlist
;
;+
;   Name: dir_exist
;
;   Purpose: check if elements of input list are existing directories
;
;   Input Parameters:
;      dirlist - string/string array of directories to check
;
;   Output:
;      function returns boolean (0 - not directory, 1-directory)
;
;   Calling Sequence:
;      dirs=dir_exist(dirlist)
;
;   History:
;      2-Aug-93 (SLF)
;      29-Jun-2000 - RDB - Added Windows case
;
;-
outarr=0
if n_elements(dirlist) gt 0 then outarr=intarr(n_elements(dirlist))

sdirlist=size(dirlist)
if sdirlist(sdirlist(0)+1) ne 7 then begin
   message,/info,'String or String array input required...'
endif else begin
   case strupcase(!version.os_family) of
      'VMS': begin
	     updir=strupcase(dirlist)
             for i=0,n_elements(dirlist)-1 do begin
	         testdir=str_replace(updir(i),'.DIR','') + '.DIR'
		 fil=findfile(testdir,count=dcount)
                 outarr(i)=dcount gt 0
             endfor
         endcase
      'WINDOWS': begin
            for i=0,n_elements(dirlist)-1 do begin
               outarr(i)=file_exist(dirlist(i))
            endfor

         endcase
      else: begin
            for i=0,n_elements(dirlist)-1 do begin
               spawn,['ls','-d',dirlist(i)],out,/noshell
               outarr(i)=out ne ''
            endfor
         endcase
   endcase
endelse

if n_elements(outarr) eq 1 then outarr=outarr(0)

return,outarr
end
