; Created:	20111003	to sum down the image at different angles and see where peaks correspond to (CME tracks).

pro scan_cme_prof, cme_prof

!p.multi=[0,1,2]

plot_image,cme_prof

sz = size(cme_prof,/dim)

ymax = 2500

plot, total(cme_prof,2), xr=[0,sz[0]], yr=[0,ymax], /xs, /ys

for i=1,90 do begin

	im = rot(cme_prof,-i)

	plot_image, im
	
	prof = total(im, 2) ;sum down the image
	
	plot, prof, xr=[0,sz[0]], yr=[0,ymax], /xs, /ys

	print, 'max(prof) ', max(prof)
	print, 'angle ', i

	plots, where(prof eq max(prof)), max(prof), psym=2

	mu = moment(prof,sdev=sdev)
	horline, mu[0]
	horline, median(prof), line=2


	pause	
endfor


end
