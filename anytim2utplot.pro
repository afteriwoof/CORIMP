function anytim2utplot, str
;
;Convert to the "utplot" time format of yy/mm/dd, hhmm:ss.xxx
;from any type of input
;
tarr = anytim2ex(str)
;
fmt = "(i2.2, '/', i2.2, '/', i2.2, ', ', 2i2.2, ':', i2.2, '.', i3.3)"
ss = [6,5,4,0,1,2,3]
out = string(tarr(ss), format=fmt)
;
return, out
end
