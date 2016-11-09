FUNCTION circle, xcentre, ycentre, radius

points = (2.*!PI/99.) * findgen(100)

x = xcentre + radius*cos(points)
y = ycentre + radius*sin(points)

return, [ [x], [y] ]

END
