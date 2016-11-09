pro ut_label, times, ypos, labels, _extra=_extra
;+
;   Name: ut_label
;
;   Purpose: label previously drawn utplot / outplot (via evt_grid.pro)
;
;   Input Parameters:
;      times - xvalue (any SSW time ok)
;      ypos  - corresponding Y (data or normalized coords)
;  
;   Keyword Parameters:
;      ( keywords accepted by evt_grid.pro, including)
;      labsize, labcolor - (obvious)
;      align (same interp as 'align' in xyouts)
;      vertical - switch, if set, rotate label to vertical
;
;   Calling Sequence:
;      IDL> [utplot / outplot ]
;      IDL> ut_label, times [, ypositions , labels] [,KEYWORDS=KEYWORDS ]
;      
;   History:
;      4-March-1998 - S.L.Freeland - simplified one common evt_grid use  
;    
;   Restrictions:
;      current plot must be via utplot, times must fall within time range
;-
if n_params() lt 1 then begin
   box_message,['IDL> ut_label, times, yposition, labels [,keywords=keywords]', $
		'     (see evt_grid.pro for keywords)']
   return
endif		

if n_elements(ypos) eq 0 then ypos=.8
if n_elements(labels) eq 0 then label=1 else label=labels

evt_grid, anytim(times,out='yohkoh'), $             ; anything in, standard out
  labpos=ypos, /labonly, label=label, _extra=_extra

return
end
