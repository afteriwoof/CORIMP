;+
; PROJECT:
;	SDAC
; NAME: 
;	RESTORE_PLOTVAR
;
; PURPOSE:
;	This procedure reloads system variable structures from stored values.
;
; CATEGORY:
;	Graphics, Utplot
;
; CALLING SEQUENCE:
;	Restore_plotvar
;
; CALLS:
;	STORE_PLOTVAR
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
;	Version 3, richard.schwartz@gsfc.nasa.gov, 10-jun-1998.
;		Ensure variables in common are defined prior to usage.
;-
pro restore_plotvar

@store_plotvar_common

if not keyword_set(store_bangx) or not keyword_set(store_bangy) or not keyword_set(store_bangz) $
	or not keyword_set(store_bangp) then store_plotvar

!x = store_bangx
!y = store_bangy 
!z = store_bangz 
!p = store_bangp 

end
