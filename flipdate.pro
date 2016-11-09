; NAME:   
;	Flipdate
;
; PURPOSE:  invert date strings from dd/mm/yy to yy/mm/dd and vice versa
;
;
; CATEGORY: string and time manipulation
;
;
; CALLING SEQUENCE: newdate = flipdate( old_date, error=error)
;
;
; CALLED BY:
;
;
; CALLS TO:
;       arr2str, str2arr
;
; INPUTS:
;       old_date - date string of form  xx/yy/zz where xx,yy, and zz are numbers
;		   also on xx-mon-zz where xx and zz are numbers and mon is
;		   a character string
; OPTIONAL INPUTS:
;       none
;
; OUTPUTS:
;       e.g. print, flipdate( 'xx/yy/zz')
;            zz/yy/xx
;
; OPTIONAL OUTPUTS:
;       none
;
; COMMON BLOCKS:
;       none
;
; SIDE EFFECTS:
;       none
;
; RESTRICTIONS:
;       date string must be parsed with '/' or '-'
; PROCEDURE:
;       
; ras, 16-sept-94
; ras, 3-June-1996, added strtrim(old_date,2)
;+
function flipdate, old_date, error=error


error = 0 
result = strtrim(old_date,2)

for i=0,n_elements(old_date)-1 do begin
  line = result(i)
  case 1 of
  strpos(line,'/') ne -1 : delim='/'
  strpos(line,'-') ne -1 : delim='-'
  else: begin
	print,'Error in FLIPDATE, bad delimiter, use "/" or "-" '
	print, line
	error=1
        return, result
    end
  endcase
  line = str2arr(line, delim=delim)
  result(i) = line(2)+delim+line(1)+delim+line(0)
endfor

return, result
end
