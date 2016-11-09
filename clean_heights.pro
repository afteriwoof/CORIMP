;Created	2012-12-05	to clean the height profiles so the jump from C2 to C3 is dominant.

pro clean_heights, datetimes_in, heights_in, angs_in, debug=debug

occulter_crossing = 5743

all_flag = 0

for k=min(angs_in),max(angs_in) do begin

	if where(angs_in eq k) eq [-1] then goto, jump1
	datetimes = datetimes_in[where(angs_in eq k)]
	heights = heights_in[where(angs_in eq k)]
	angs = angs_in[where(angs_in eq k)]
	if n_elements(heights) le 2 then goto, jump1
	if keyword_set(debug) then begin
		set_line_color
		plot, anytim(datetimes), heights, psym=1, yr=[0,2.5e4];, color=1
		horline, occulter_crossing
	endif

	count_up = 0
	jump2:
	; if the points are rising take the initial point
	if heights[1] gt heights[0] then begin
		h = heights[0]
		t = datetimes[0]
		a = angs[0]
	;otherwise move along and see if the next points start rising.
	endif else begin
		heights = heights[1:*]
		datetimes = datetimes[1:*]
		angs = angs[1:*]
		count_up += 1
		if n_elements(heights) le 1 then goto, jump1
		goto, jump2
	endelse

	if keyword_set(debug) then plots, anytim(datetimes[0]), heights[0], psym=6, color=4
	skip = 0
	previous_count_input_h = 0
	count = 1
	while count+skip lt n_elements(heights) do begin
		; if heights are in C3 fov then don't include the drops below the occulter to C2 in the height counting:
		if heights[count+skip] gt h[n_elements(h)-1] then begin
			h = [h, heights[count+skip]]
			t = [t, datetimes[count+skip]]
			a = [a, angs[count+skip]]
			count_input_h = count+skip
			previous_gap = count_input_h - previous_count_input_h
		endif else begin
			if (count+skip+1) lt n_elements(heights) then begin
				if h[n_elements(h)-1] gt occulter_crossing AND heights[count+skip] lt occulter_crossing then begin
					if heights[count+1+skip] gt h[n_elements(h)-1] then begin
						h = [h, heights[count+1+skip]]
						t = [t, datetimes[count+1+skip]]
						a = [a, angs[count+1+skip]]
						count_input_h = count+1+skip
						previous_gap = count_input_h - previous_count_input_h
					endif
					skip += 1
				endif
			endif
		endelse
		current_gap = count - count_input_h
		previous_count_input_h = count_input_h
		count += 1
		;if current_gap gt 2*previous_gap then goto, jump3
	endwhile

	jump3:



	jump1:
	; Save out the new heights
	; code here?

	if exist(h) then begin
		if all_flag eq 0 then begin
			t_all = t
			h_all = h
			a_all = a
			all_flag = 1
		endif else begin
			t_all = [t_all, t]
			h_all = [h_all, h]
			a_all = [a_all, a]
		endelse
		if keyword_set(debug) then plots, anytim(t), h, psym=-6, color=3, line=2
	endif
	if keyword_set(debug) then pause
endfor

if exist(t_all) then begin
	datetimes_in = t_all
	heights_in = h_all
	angs_in = a_all
endif else begin
	print, 'Clean_heights results in nothing!'
endelse


end
