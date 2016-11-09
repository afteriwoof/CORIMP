; Created	18-07-11	from gather_plots.pro

; INPUTS	in_das	-	the list of in_da_*.sav
;		plot_savs	-	the list of plots_*.sav


pro gather_gail, in_das, plot_savs, out_dir

window, xs=1024, ys=1024

;restore,'c2mask.sav'
;restore,'c3mask.sav'

count=0

for i=0,n_elements(in_das)-1 do begin

	loadct, 0
	restore, in_das[i]
	print, 'restoring ', in_das[i]

	tvscl, da
	legend, strmid(in_das[i],strpos(in_das[i],'in_da_')+6,12),/left,/device,box=0,charsize=2
	;case strmid(in_das[i],strpos(in_das[i],'in_da_')+20,2) of
	;	'C2':	tvscl, sigrange(da*c2mask,/use_all)
	;	'C3':	tvscl, sigrange(da*c3mask,/use_all)
	;endcase

	date = strmid(in_das[i],strpos(in_das[i],'in_da_')+6,12)
	print, 'date ', date

	if (i-count) lt n_elements(plot_savs) then begin
		test_date = strmid(plot_savs[i-count],strpos(plot_savs[i-count],'plots_')+6,12)
		print, 'test_date ', test_date
		if test_date eq date then begin
			restore, plot_savs[i-count]
			print, 'restoring ', plot_savs[i-count]
			help,i,count
			set_line_color
			plots, res[0,*], res[1,*], psym=3, color=5, /device
			plots, xf_out, yf_out, psym=1, color=3, /device
		endif else begin
			legend, 'No CME detections', /right, /device, box=0, charsize=2
			count+=1
		endelse
	endif else begin
		legend, 'No CME detections', /right, /device, box=0, charsize=2
	endelse

	case strmid(in_das[i],strpos(in_das[i],'in_da_')+20,2) of
		'C2':	x2png, out_dir+'/'+strmid(in_das[i],strpos(in_das[i],'in_da_')+6,12)+'_C2.png'
		'C3':	x2png, out_dir+'/'+strmid(in_das[i],strpos(in_das[i],'in_da_')+6,12)+'_C3.png'
	endcase

endfor


end
