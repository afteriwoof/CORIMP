pro plot_hist_jpb, data, x, h, bin=bin, xrange=xrange, yrange=yrange, $
   title=title, log=log, noerase=noerase, linestyle=linestyle, $
   charsize=charsize, oplot=oplot, xstyle=xstyle, $
   ystyle=ystyle, xticklen=xticklen, yticklen=yticklen, $
   xmargin=xmargin, ymargin=ymargin, xtitle=xtitle, ytitle=ytitle, $
   color=color, position=position, ytickname=ytickname
;
;+
;NAME:
;	plot_hist
;PURPOSE:
;	To plot a histogram with a properly labeled X axis.
;SAMPLE CALLING SEQUENCE:
;	plot_hist, img
;	plot_hist, img, x, h
;	plot_hist, img, bin=0.1
;	plot_hist, img, xrange=xrange, yrange=yrange, tit=tit
;INPUT:
;	data	- The data to perform the historam on
;OUTPUT:
;	x	- The x axis for the plotting
;	h	- The histogram
;OPTIONAL KEYWORD INPUTS:
;	bin	- The bin size to use (default is 1)
;	xrange	- The x plotting range
;	yrange	- The y plotting range
;	[x,y]style  - See plot keyword options
;	{x,y]margin - See plot keyword options
;	[x,y]ticklen - See plot keyword options
;	[x,y]title - Optional titles for the x and y axes
;	title	- The title
;	log	- If set, then plot the y axis in log form
;	oplot   - If set, overplot on previous histogram
;		NOTE:  If bin is not equal 1 then you MUST specify 
;		bin for oplot to match properties of original plot.
;	color   - Choose color for plot
;HISTORY:
;	Written Apr-95 by M.Morrison
;	18-May-95 (MDM) - Added /LOG switch
;			- Plot such that the minimum occurance is 0.1
;	 7-Jul-95 (MDM) - Fixed the plot so that min occurance is 0.1
;	27-Nov-95 (LWA) - Added noerase, linestyle, charsize  keywords.
;	 8-Nov-96 (MDM) - Merged 27-Nov-95 changes with the ones below:
;		17-May-96 (MDM) - Added xtitle
;		11-Sep-96 (MDM) - Added ROUND when creating "data0"
;	 8-Nov-96 (MDM) - Added "oplot" option
;	21-Apr-99 (LWA) - Added xstyle and ystyle keywords.
;	30-Apr-99 (LWA) - Added [x,y]ticklen, [x,y]title, [x,y]margin keywords.
;	 9-Nov-02 (LWA) - Added keyword color
;-
;
if (n_elements(bin) eq 0) then bin = 1
;
data0 = round(data/bin)

h = histogram(data0)
n = n_elements(h)
amin = min(data0)
x = findgen(n)*bin + long(amin)*bin
;
if NOT keyword_set(charsize) then charsize=0 else charsize=charsize
if NOT keyword_set(linestyle) then linestyle=0 else linestyle=linestyle
if NOT keyword_set(xstyle) then xstyle=0 else xstyle=xstyle
if NOT keyword_set(ystyle) then ystyle=0 else ystyle=ystyle
if NOT keyword_set(xticklen) then xticklen=0 else xticklen=xticklen
if NOT keyword_set(yticklen) then yticklen=0 else yticklen=yticklen
if NOT keyword_set(xmargin) then xmargin=[10,3] else xmargin=xmargin
if NOT keyword_set(ymargin) then ymargin=[4,2] else ymargin=ymargin
if (n_elements(xrange) eq 0) then xrange = [min(x), max(x)]
if (n_elements(yrange) eq 0) then yrange = [min(h)>0.1, max(h)]
if (n_elements(title) eq 0) then title = '' else title=title
if (n_elements(xtitle) eq 0) then xtitle = 'Value' else xtitle=xtitle
if (n_elements(ytitle) eq 0) then ytitle='# of Occurrences' else ytitle=ytitle

;
if (keyword_set(oplot)) then begin
    oplot, x, h, psym=10, linestyle=linestyle, color=color
end else begin
    plot, x, h, psym=10, ytitle=ytitle, xtitle=xtitle, $
	xrange=xrange, yrange=yrange, title=title, ytype=keyword_set(log), $
	noerase=noerase, linestyle=linestyle, charsize=charsize, $
	xstyle=xstyle, ystyle=ystyle, xticklen=xticklen, yticklen=yticklen, $
	xmargin=xmargin, ymargin=ymargin, color=color, position=position, $
	ytickname=ytickname
end
;
end
