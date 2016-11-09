;+ ; NAME: x2png.pro 
; converts the current x-displayed window to png 
; 
; 
; PURPOSE: 
; converts the current x-displayed window to png 
; makes this easy - and in every case i have tried looks great :) 
; 
; 
; CATEGORY: data visualisation 
; 
; 
; OPTIONAL INPUTS: 
; filename: filename for the png image with or without the .png 
; if none specified idl.png is created 
; 
; 
; 
; KEYWORD PARAMETERS: 
; SILENT: silent mode 
; TRANSPARENT: Set this keyword to an array of pixel index values 
; which are to be treated as "transparent" for the purposes of image 
; display. This keyword is only valid for single channel (color 
; indexed) 
;
; OUTPUTS: 
; the png image created from the x-display 
; 
; 
; 
; PROCEDURE: 
; uses tvrd to create image array 
; writes the png 
; 
; 
; EXAMPLE: 
; plot, findgen(100) 
; x2png, 'mygraph' 
; 
; MODIFICATION HISTORY:
; 
; Tue Feb 10 15:02:01 2004, Brian Larsen 
; <larsen@ssel.montana.edu> 
; 
; Stolen from x2jpg written by me 
; 
; Wed Nov 5 17:01:27 2003, Brian Larsen 
; <larsen@ssel.montana.edu> 
; 
; added sil mode 
; 
; Mon Jul 15 17:54:43 2002, Brian Larsen 
; <larsen@mithra.physics.montana.edu> 
; 
; Written, tested, I just learned how to do this and 
; imagine doing it a lot so this will be handy 
; 
;- 


PRO x2png, filename, SILENT=silent, TRANSPARENT=transparent 
img = tvrd(/true) 
IF total(img) EQ 0 THEN BEGIN 
print, 'You need a x-window open to convert' 
wdelete 
GOTO, bailout 
ENDIF 
IF n_elements(filename) EQ 0 THEN filename = 'idl.png' 
filename = TRIM(filename) 
IF STRMID(filename, 3, 4, /reverse_offset) NE '.png' THEN $ 
	filename = string(filename) + '.png' 
write_png, filename, img, TRANSPARENT=transparent 
IF NOT KEYWORD_SET(silent) THEN BEGIN 
	print, 'X was written to '+ filename 
ENDIF 
bailout: 
END 