; Created:	2013-04-04	to find the coords of where a line and ellipse (segment being another line) intersect.

pro ell_line_intersect, x_ell, y_ell, x_line, y_line

slope1 = (x_line[1]-x_line[0]) / (y_line[1]-y_line[0])
intercept1 = y_line[0] - slope1*x_line[0]

for i=0,n_elements(x_ell)-2 do begin
	x_test = x_ell[i:i+1]
	y_test = y_ell[i:i+1]
	slope2 = (x_test[1]-x_test[0]) / (y_test[1]-y_test[0])
	intercept2 = y_test[0] - slope2*x_test[0]
	intersect_x = (intercept2-intercept1) / (slope1-slope2)
	intersect_y = slope1*intersect_x + intercept1
	print, intersect_x, intersect_y
endfor


end
