;+
; PROJECT:
;	SDAC
; NAME: 
;	STORE_PLOTVAR
;
; PURPOSE:
;	This procedure loads system variable structures into common.
;
; CATEGORY:
;	Graphics, Utplot
;
; CALLING SEQUENCE:
;	Store_plotvar
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
;	none
; COMMON BLOCKS:
;	STORE_PLOTVAR_COMMON
;
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	none
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	Version 1, ~1990
;	Version 2, Documented, richard.schwartz@gsfc.nasa.gov, 23-mar-1998.
;-
pro store_plotvar
@store_plotvar_common
store_bangx = !x
store_bangy = !y
store_bangz = !z
store_bangp = !p
end
