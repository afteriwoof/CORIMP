;+
; Search for any file in the IDL !path that contains the
; user-supplied IDL routine (procedure or function) name.  Also
; indicates compilation status of each routine (in IDL lingo,
; whether or not the routine is "resolved".)
;
; <p>
; <b>Restrictions:</b>
; The IDL !path is searched for file names that are simply the
; module (in IDL documentation, "module" and "routine" are used
; interchangeably) name with a ".pro" suffix appended to them.
; A module stored inside a file whose name is different than the
; module name (followed by a ".pro") will not be found UNLESS
; that module happens to be the currently-resolved module!
; E.g., if the module "pro test_proc" lives in a file named
; "dumb_name.pro", then it will not be found:
;
; <pre>
; IDL> which, 'test_proc'
; Module TEST_PROC Not Compiled.
; % WHICH: test_proc.pro not found on IDL !path.
; </pre>
;
; unless it happens to be resolved:
;
; <pre>
; IDL> .run dumb_name
; % Compiled module: TEST_PROC.
; IDL> which, 'test_proc'
; Currently-Compiled Module TEST_PROC in File:
; /home/robishaw/dumb_name.pro
; </pre>
;
; However, this is terrible programming style and sooner or
; later, if you hide generically-named modules in
; inappropriately-named files, bad things will (deservedly)
; happen to you.
;
; The routine further assumes that a file named "dumb_name.pro"
; actually contains a module named "dumb_name"!  If it doesn't,
; then you are a bad programmer and should seek professional
; counseling.
;
; Finally, if the user has somehow compiled a module as a procedure
; and then compiled a module of the same name as a function, they will
; both be available to the user, therefore both are listed.  This
; situation should probably be avoided.
;
; <p>
; <b>Notes:</b>
; First, all currently-compiled procedures and functions are searched.
; Then the remainder of the IDL !path is searched.  The current
; directory is searched before the IDL !path, whether or not the
; current directory is in the IDL !path, because this is the behavior
; of .run, .compile, .rnew, DOC_LIBRARY, etc.
;
; <p>
; <b>MODIFICATION HISTORY:</b>
; <ul>
; <li>30 May 2003  Written by Tim Robishaw, Berkeley
; <li>17 Feb 2004  Fixed oddity where user tries to call a function as
;                  if it were a procedure, thus listing the module in both
;                  the Compiled Functions and Compiled Procedures
;                  list.
; <li>14 Jun 2005  Split code into which_routine function for use
;                  elsewhere in GBTIDL and which.  Reformatted
;                  comments for use with idldoc.
; <li>11 May 2006  Incorporate T. Robishaw changes found in original
;                  version of which into this version.
;                  Fixed scenario where two modules with the same
;                  name are compiled, one as a procedure, the
;                  other as a function.
;                  Add current directory to the top of the path and
;                  make sure the path is a unique list of directories.
;                  Added capability to cope with symbolic links.
;                  Fixed up warning and documentation for the strange
;                  case of having both a procedure and function of the
;                  same name compiled.
; </ul>
;
; @param name {in}{required}{type=string} The procedure or function
; name to search for.
;
; @uses <a href="which_routine.html">which_routine</a>
;
; @examples
; You haven't yet resolved (compiled) the routine (module)
; DEFROI.  Let's look for it anyway:
;
; <pre>
; IDL> which, 'defroi
; Module DEFROI Not Compiled.
;
; Other Files Containing Module DEFROI in IDL !path:
; /usr/local/rsi/idl/lib/defroi.pro
; </pre>
;
; For some reason you have two modules with the same name.
; (This can occur in libraries of IDL routines such as the
; Goddard IDL Astronomy User's Library; an updated version of a
; routine is stored in a special directory while the old version
; is stored in its original directory.) Let's see which version
; of the module ADSTRING we are currently using:
;
; <pre>
; IDL> which, 'adstring.pro'
; Currently-Compiled Module ADSTRING in File:
; /home/robishaw/idl/goddard/pro/v5.4+/adstring.pro
;
; Other Files Containing Module ADSTRING in IDL !path:
; /home/robishaw/idl/goddard/pro/astro/adstring.pro
; </pre>
;
; @version $Id: which.pro,v 1.3 2006/05/13 04:34:01 bgarwood Exp $
;-
pro which_ug, name

    on_error, 2

    ; make sure the input is a single string...
    if (N_params() lt 1) then begin
        message, 'syntax: which, name', /INFO
        return
    endif
    sz = size(name)
    if (sz[0] gt 1) then begin
        message, 'name must be a scalar string.',/info
        return
    endif
    if (sz[sz[0]+1] ne 7) then begin
        message,'name must be a string.',/info
        return
    endif

    proname = name
    resolved = which_routine(proname, unresolved=unresolved)

    if n_elements(resolved) eq 1 then begin
        if strlen(resolved) gt 0 then begin
            print, 'Currently-Compiled Module '+strupcase(proname)+' in File:'
            print, resolved, format='(A,%"\N")'
        endif else print, strupcase(proname), format='("Module ",A," Not Compiled.",%"\N")'
    endif else begin
        if n_elements(resolved) eq 2 then begin
            print, 'Identically-named modules have been compiled as'+$
                   ' a procedure and a function!'
            print, 'The Currently-Compiled modules '+strupcase(proname)+' are in these files'
            print, 'Procedure: ', resolved[0]
            print, ' Function: ', resolved[1]
        endif else begin
            message,'Unexpected error, this should never happen'
        endelse
    endelse

    if strlen(resolved[0]) eq 0 and strlen(unresolved[0]) eq 0 then begin
        message, name + '.pro not found on IDL !path.', /INFO
        return
    endif

    if strlen(unresolved[0]) gt 0 then begin
        ; PRINT THE REMAINING ROUTINES...
        print, 'Other Files Containing Module '+strupcase(name)+' in IDL !path:'
        print, transpose(unresolved)
        print
    endif

end; which
