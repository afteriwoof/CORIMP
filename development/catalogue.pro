; Created:	01-03-11	To read in CME detection info and generate catalogue output file.


pro catalogue, in, da, xf, yf, xf_out_new, yf_out_new, res, xe, ye, xe_noflanks, ye_noflanks, xe_full, ye_full, p_noflanks

xcen = in.xcen
ycen = in.ycen
in.xcen=0
in.ycen=0
index2map, in, da, map

plot_map, map, /limb

xfmap = (xf-xcen)*in.cdelt1
yfmap = (yf-ycen)*in.cdelt2

recpol, xfmap, yfmap, r_front, a_front, /degrees
max_h_front = max(r_front)

x_ellipse = (xe_noflanks-xcen)*in.cdelt1
y_ellipse = (ye_noflanks-ycen)*in.cdelt2

recpol, x_ellipse, y_ellipse, r_ellipse, a_ellipse, /degrees
apex_r = max(r_ellipse)
apex_a = (a_ellipse[where(r_ellipse eq apex_r)])[0]
polrec, apex_r, apex_a, x_apex, y_apex, /degrees
print, 'apex_a: ', apex_a

........



plot, xf, yf, psym=1, color=4

recpol, xf, yf, r_front, a_front, /degrees


plots, xf_out_new, yf_out_new, psym=4, color=3

plots, res[0,*], res[1,*], psym=3, color=5

plots, xe, ye, psym=-3, color=3 ;fit to front including arb flank points
plots, xe_noflanks, ye_noflanks, psym=-3, color=2 ;fit to front only not including arb flank points
plots, xe_full, ye_full, psym=-3, color=4 ;fit to all outer CME edge points

; The ellipse coords I want to work with are fit to front only
x_ellipse = xe_noflanks
y_ellipse = ye_noflanks

recpol, x_ellipse-in.xcen, y_ellipse-in.ycen, r_ellipse, a_ellipse, /degrees


; Take the furthest point on the ellipse from Sun centre
apex_r = max(r_ellipse)
apex_a = (a_ellipse[where(r_ellipse eq apex_r)])[0]
print, apex_r, apex_a

polrec, apex_r, apex_a, x_apex, y_apex, /degrees
print, '******'
print, 'apex_a: ', apex_a
print, '******'

;height_apex = sqrt( (x_apex)^2. + (y_apex)^2. )

stop

; Does the ellipse cut the 0/360 line which means it needs shifting to obtain the angular width.
true = shift_ell_corimp(in, da, x_ellipse, y_ellipse, p_noflanks)
print, 'true: ', true
if true eq 0 then begin	
	; Cone of Ellipse
	min_cone_a = min(a_ellipse)
	max_cone_a = max(a_ellipse)
	min_cone_r = r_ellipse[where(a_ellipse eq min_cone_a)]
	max_cone_r = r_ellipse[where(a_ellipse eq max_cone_a)]
	polrec, min_cone_r, min_cone_a, min_cone_x, min_cone_y, /degrees
	polrec, max_cone_r, max_cone_a, max_cone_x, max_cone_y, /degrees
	if noplot eq 0 then begin
		plots, [0,min_cone_x], [0,min_cone_y]
		plots, [0,max_cone_x], [0,max_cone_y]
	endif
	aw = max_cone_a - min_cone_a
	print, 'angular width(degrees): ', aw
endif else begin
	; do the shift now...
	aes = (a_ellipse+180) mod 360
	aes_min = min(aes)
	aes_max = max(aes)
	aw = aes_max - aes_min
	re_cone1 = r_ellipse[where(aes eq aes_min)]
	re_cone2 = r_ellipse[where(aes eq aes_max)]
	polrec, r_ellipse, aes, xes, yes, /degrees
	ae_min = (aes_min+180) mod 360
	ae_max = (aes_max+180) mod 360
	polrec, re_cone1, ae_min, min_cone_x, min_cone_y, /degrees
	polrec, re_cone2, ae_max, max_cone_x, max_cone_y, /degrees
		plots, [0,min_cone_x], [0,min_cone_y]
		plots, [0,max_cone_x], [0,max_cone_y]
	print, 'angular width (degrees): ', aw
endelse


; Clause for when the ellipse runs away and the height is not within the CME cone
;if true eq 0 then begin
	if apex_a lt min(a_front) or apex_a gt max(a_front) then begin
		temp_a_ellipse = a_ellipse[where(a_ellipse lt max(a_front) and a_ellipse gt min(a_front))]
		temp_r_ellipse = r_ellipse[where(a_ellipse lt max(a_front) and a_ellipse gt min(a_front))]
		temp_apex_r = max(temp_r_ellipse)
		temp_apex_a = (temp_a_ellipse[where(temp_r_ellipse eq temp_apex_r)])[0]
		polrec, temp_apex_r, temp_apex_a, temp_x_apex, temp_y_apex, /degrees
		plots, temp_x_apex, temp_y_apex, psym=1, color=3
		print, 'temp_apex_a: ', temp_apex_a
		max_h_ell = sqrt( (temp_x_apex)^2. + (temp_y_apex)^2. )
		print, 'max_h_ell(arcsec): ', max_h_ell
		plots, [0,temp_x_apex], [0,temp_y_apex], color=4
	endif else begin
		max_h_ell = height_apex[0]
	endelse
; needs case for true eq 1 when shift is involved!
;endif	



end
