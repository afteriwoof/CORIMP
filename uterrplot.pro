
;+

pro uterrplot,time,plus,minus,skip=inskip,horizontal=horizontal,$
	thick=thick,color=color

;NAME:
;     UTERRPLOT
;PURPOSE:
;     Plot Error bars on a UTPLOT
;CATEGORY:
;CALLING SEQUENCE:
;     uterrplot,time,plus,minus
;INPUTS:
;   IF HORIZONTAL=0:
;     time = time vector 
;     plus = the data value at the top of the error range
;     minus = the data value at the bottom of the error range
;   IF HORIZONTAL=1:
;     time = time at earliest point in error range 
;     plus = time at latest point in error range
;     minus = the data value 
;OPTIONAL INPUT PARAMETERS:
;KEYWORD PARAMETERS:
;     /horizontal = Plot a horizontal error bar rather than a vertical error
;                   bar. 
;     skip = integer specifying how frequently an error bar should be
;            plotted. Default is 1 which means plot every error bar.  If skip
;            is set to 2, then every other error bar si plotted, etc.
;OUTPUTS:
;COMMON BLOCKS:
;SIDE EFFECTS:
;RESTRICTIONS:
;     You must call utplot first to plot the data points.  This routine only
;     adds error bars to a data plot which is assumed to already be plotted.
;PROCEDURE:
;     First call utplot to plot your data, then call uterrplot to add error
;     bars. 
;MODIFICATION HISTORY:
;     T. Metcalf 2000-April-05
;     L. Acton 2005-July-15, added thick and color keywords.
;-


   nt = n_elements(time)
   if n_elements(plus) NE nt OR n_elements(minus) NE nt then $
      message,'Bad array size'
   if n_elements(inskip) EQ 1 then skip = long(inskip)>1L else skip = 1L
   for i=0L,nt-1L do begin
      if i MOD skip EQ 0 then begin
         if NOT keyword_set(horizontal) then begin
            outplot,[time(i),time(i)],[plus(i),minus(i)],$
               thick=thick,color=color 
         endif else begin
            outplot,[time(i),plus(i)],[minus(i),minus(i)],$
               thick=thick,color=color
         endelse
      endif
   endfor


end
