pro addpath, newpath_in, EXPAND=expand, APPEND=append, ALL_DIRS=all_dirs
;+
; NAME:
;       ADDPATH
;     
; PURPOSE:
;       To add a path to the !PATH IDL environment system variable. 
;     
; EXPLANATION:
;       !PATH is a string variable listing the directories IDL will search 
;       for libraries, include files, and executive commands.  This
;       routine allows the user to add a new path to !PATH.  If a
;       directory already exists in !PATH, then this directory is moved
;       to the front of !PATH.
;     
; CALLING SEQUENCE:
;       ADDPATH, Newpath [,/EXPAND][,/APPEND][,/ALL_DIRS]
;     
; INPUTS:
;       NEWPATH : The string containing the name of the directory to be
;                 added to !PATH.  Can be a scalar or an array. If the
;                 directory specified in the string does not have a "+"
;                 character prepended to it, it is copied to the output
;                 string verbatim. However, if it does have a leading "+"
;                 then EXPAND_PATH searches the directory and all of its
;                 subdirectories for files of  the appropriate type for the
;                 path. This can be accomplished by setting the EXPAND
;                 keyword also.
;     
; OUTPUTS:
;       None.
;
; KEYWORDS:
;       /EXPAND : Default is for ADDPATH not to expand the added directory. 
;                 If this keyword is set, any directory below the specified 
;                 directory is added to the path if it contains an IDL file 
;                 (either a .pro or a .sav file.) Setting this keyword is 
;                 equivalent to prepending a "+" to the directory to be added.
;
;       /APPEND : Default is for ADDPATH to prepend the directory to the
;                 !PATH system variable, assuming you'd like to have
;                 access to modules in the added directories ahead of any
;                 identically-named modules that already exist in !PATH.
;                 In some cases it might be desirable to have the directory
;                 appended to the end of !PATH, so this can be accomplished
;                 via the /APPEND keyword.
;
;       /ALL_DIRS : Set this keyword to return all directories without 
;                   concern for their contents, otherwise; EXPAND_PATH 
;                   only returns those directories that contain .pro or 
;                   .sav files.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       !PATH system variable is changed.
;
; EXAMPLES:
;       Suppose you have a directory with no .pro or .sav files in it,
;       and you'd like to add this, and only this, directory to !path:
;
;       IDL> addpath, '/home/robishaw/hvc', /ALL_DIRS
;
;       To add all the directories below /home/robishaw/hvc regardless of
;       whether any has a .pro or .sav file, either of the following
;       will work:
;
;       IDL> addpath, '/home/robishaw/hvc', /EXPAND, /ALL_DIRS
;       IDL> addpath, '+/home/robishaw/hvc', /ALL_DIRS
;
;       To add multiple directories, send in an array of paths:
;       IDL> addpath, ['+~/idl','/home/user/lib/pro'], /APPEND
;
; PROCEDURES CALLED:
;       EXPAND_PATH
;       ARRAY_EQUAL
;
; MODIFICATION HISTORY:
;       Written Tim Robishaw, Berkeley  26 Jul 2001
;	Added /APPEND keyword.  Fixed documentation.
;                                     T. Robishaw  23 Mar 2006
;       Use recursion to handle case of passing in vector of
;       new paths to be added. I'm lazy. T. Robishaw  24 Mar 2006
;-

; USE RECURSION TO HANDLE CASE OF USER PASSING AN ARRAY OF
; PATHS TO BE ADDED...
newpath = shift(newpath_in,(keyword_set(APPEND)))
if (N_elements(newpath_in) gt 1) $
   then addpath, newpath[1:*], $
                 EXPAND=keyword_set(expand), $
                 APPEND=keyword_set(append), $
                 ALL_DIRS=keyword_set(all_dirs)

; STRIP ANY SPACES FROM THE FRONT AND BACK OF THE PATH NAME...
newpath = strtrim(newpath[0],2)

; IF "+" ENTERED IN FRONT OF NEW PATH, GET RID OF IT...
if (strmid(newpath,0,1) eq '+') then begin
    newpath = strmid(newpath,1,strlen(newpath))
    expand  = 1L
endif

; ADD THE CURRENT DIRECTORY IF ONE IS NOT PROVIDED...
if (N_elements(newpath) eq 0) $
  then cd, current=newpath $
  else begin
    ; MAKE SURE DIRECTORY EXISTS!
    if not file_test(newpath, /DIRECTORY) then begin
        message, newpath+' does not exist!', /INFO
        return
    endif
  endelse

; SEPARATE PATH INTO STRING ARRAY...
path = strsplit(!path, ':', /EXTRACT)

; EXPAND ANY ~'S IN !PATH...
lazy = where(strmid(path,0,1) eq '~', N_lazy)
if (N_lazy gt 0) then $
  for i = 0, N_lazy-1 do $
    path[lazy[i]] = expand_path(path[lazy[i]])

; THE DEFAULT IS TO ADD ALL DIRECTORIES BELOW THIS WHICH CONTAIN
; A .pro OR .sav FILE!
if keyword_set(EXPAND) then newpath = '+'+newpath

; EXPAND THE NEW PATH AND RETURN A STRING ARRAY...
newpath = expand_path(newpath, /ARRAY, COUNT=N_paths, $
                      ALL_DIRS=keyword_set(ALL_DIRS))

; ARE WE TRYING TO ADD !PATH TO ITSELF...
if array_equal(newpath, path) then return

; REMOVE ALL THE NEW PATHS FROM THE CURRENT PATH...
for i = 0L, N_paths-1L do begin

    ; HOW MANY ELEMENTS IN !PATH...
    pathlen = N_elements(path)

    ; IS THE NEW PATH ALREADY IN !PATH...
    indx = (where(path eq newpath[i], N_indx))[0]

    ; IF IT IS, GET RID OF IT...
    if (N_indx ne 0) then $
      case indx of
                0 : path = path[1:*]
        pathlen-1 : path = path[0:indx-1]
             else : path = [path[0:indx-1],path[indx+1:*]]
      endcase
endfor

; PREPEND THE NEW PATH, UNLESS APPEND KEYWORD IS SET...
path = (not keyword_set(APPEND)) ? [newpath,path] : [path,newpath]

; CONSTRUCT !PATH FROM STRING ARRAY...
!path = strjoin(path,':')

end; addpath
