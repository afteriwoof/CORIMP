function linspc, min, max, nsteps
	min=double(min) & max=double(max) & nsteps = double(nsteps)
	step = ( max - min )/(nsteps-1)
	res = dblarr(nsteps)
	for i=0, nsteps-1 do res[i] = min + i*step
	return, res
end