; Created to shift the pa_total so that the position anges start from 0 at Solar North, clockwise.

pro shift_pa_total, pa_total

sz = size(pa_total, /dim)

temp = intarr(sz[0]+90,sz[1])

temp[90:*,*] = pa_total

temp[0:89,*] = pa_total[270:359,*]

pa_total = temp[0:359,*]

end
