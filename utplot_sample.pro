utplot, roadmap, gt_filta(roadmap), psym=2			& pause
clear_utplot
utplot, int2secarr(roadmap), gt_filta(roadmap), roadmap(100), psym=2	& pause		;SHOULD NOT DO THIS - int2secarr does
				;difference relative to roadmap(0), but roadmap(100) is passed as the reference
clear_utplot
;
lab = [' ', gt_filta(indgen(6)+1, /str), ' ']
tic = 7
val = indgen(tic+1)
utplot, roadmap, gt_filta(roadmap), ytickname=lab, ytickv=val, yticks=tic, yrange=[0,tic], psym=2		& pause
;
lab = [' ', gt_filtb(indgen(6)+1, /str), ' ']
tic = 7
val = indgen(tic+1)
utplot, roadmap, gt_filtb(roadmap), ytickname=lab, ytickv=val, yticks=tic, yrange=[0,tic], psym=2		& pause
;
if (n_elements(index) ne 0) then begin
    utplot, index, index.sxt.percentd, psym = 2						& pause

    lab = [' ', gt_filtb(indgen(6)+1, /str), ' ']
    tic = 7
    val = indgen(tic+1)
    utplot, index, gt_filtb(index), ytickname=lab, ytickv=val, yticks=tic, yrange=[0,tic], psym=2               & pause
end
;
end
