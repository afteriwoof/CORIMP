;+
; PROJECT:
;	SDAC	
; NAME: 
;	GET_UTAXIS
;
; PURPOSE:
;	This function returns the system variable axis structures set and hidden
;	by UTPLOT (SET_UTPLOT).
;
; CATEGORY:
;	Plotting, UTIL, UTPLOT
;
; CALLING SEQUENCE:
;	axis_structure = get_utaxis() for !x.
;	axis_structure = get_utaxis( /XAXIS ) for !x.
;	axis_structure = get_utaxis( /YAXIS ) for !y.
;	axis_structure = get_utaxis( /ZAXIS ) for !z.
;	axis_structure = get_utaxis( /PLOT  ) for !p.
;
; CALLS:
;	none
;
; INPUTS:
;       none explicit, only through commons;
;
; OPTIONAL INPUTS:
;	none
;
; OUTPUTS:
;       none explicit, only through commons;
;
; OPTIONAL OUTPUTS:
;	none
;
; KEYWORDS:
;	XAXIS - if set return, saved !x
;	YAXIS
;	ZAXIS
;	PLOT
; COMMON BLOCKS:
;	store_plotvar
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	Only 1 structure may be restored at a time, precedence, X, Y, Z, P.
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	Version 1, richard.schwartz@gsfc.nasa.gov, 27-jan-1998, on a suggestion
;	from DMZ to better support calls to AXIS.
;-
function get_utaxis, xaxis=xaxis, yaxis=yaxis, zaxis=zaxis, plot=plot

@store_plotvar_common

case 1 of
	keyword_set(xaxis): out =  store_bangx
	keyword_set(yaxis): out =  store_bangy
	keyword_set(zaxis): out =  store_bangz
	keyword_set(plot ): out =  store_bangp
	else: out =  store_bangx
endcase

return, out
end
