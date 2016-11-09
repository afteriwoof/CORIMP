;   Funtion to fit the aerodrag model to height time data
;   intergrating up from v(r) r to h vs t

function h_t_drag_fit, t, p, vr

; Initalise params

	npts = 10000
	R1 = linspc(p[2], 200.0d, npts) ; So will only work for 2.82 - 240 Rsun
	w0 = p[0]
	;v0 = double(p[1])
	rs=6.95508*(10.0d^(5.0d))	;km rsun = 6.95508e8
	rkvlin = dblarr(10001, 1)
	rkvlin[0] = double(p[1])
	alph = double(p[3])
	bet = double(p[4])
	
	
; Initial intergreation a(r)dr to v(r)	

	;4th order runge-kutta
	for i =0, 9998 do begin
		h = double(r1[i+1] - r1[i])
		
		k0 = ( rs * alph * (R1[i]^(double(bet))) * (1.0d/rkvlin[i,0]) *abs(rkvlin[i,0] - (solwin(w0, R1[i]) ) )^P[5] )
		k1 = ( rs * alph * ((R1[i]+(h/2.0))^(double(bet))) * (1.0d/(rkvlin[i,0]+(h/2.0d)*k0)) * abs((rkvlin[i,0]+(h/2.0d)*k0)- (solwin(w0, R1[i]+(h/2.0)) ) )^P[5] )
		k2 = ( rs * alph * ((R1[i]+(h/2.0))^(double(bet))) * (1.0d/(rkvlin[i,0]+(h/2.0d)*k1)) * abs((rkvlin[i,0]+(h/2.0d)*k1)- (solwin(w0, R1[i]+(h/2.0)) ) )^P[5] )
		k3 = ( rs * alph * ((R1[i]+h)^(double(bet))) * (1.0d/(rkvlin[i,0]+(h*k2))) * abs((rkvlin[i,0]+(h*k2))- (solwin(w0, R1[i]+h)) )^P[5] )
		
		if ( max(where(finite([k0, k1, k2, k3]) eq 0)) ne -1) then return, 0
		
		if ( rkvlin[i,0] - solwin(w0, R1[i])  gt 0.0d) then begin
			rkvlin[i+1] = rkvlin[i] - h*((k0+2*k1+2*k2+k3)/6)*!dpi
		endif else begin
			rkvlin[i+1] = rkvlin[i] + h*((k0+2*k1+2*k2+k3)/6)*!dpi
		endelse
	endfor
	
	;vr=rkvlin
	
; Second "integration" v(r) vs r to h vs t	
	rsun=6.95508*(10.0d^(8.0d))
	; Get time taken to move r[i] - r[i-1] at v[i]
	delt = dblarr(npts)
	for i =1, npts-1 do delt[i] = ((R1[i]-R1[i-1])*rsun)/(rkvlin[i]*1000.0d) ; in seconds
	
	; Get total by integrating (sum[delt[0:i]])
	tott = dblarr(npts)
	for i =1, npts-1 do tott[i] = total(delt[0:i]) ; in seconds

; Sup sample back to original data
	
	linterp, tott, rkvlin, t, vr
	linterp, tott, r1, t, r

; Return data

	return, r

end


function solwin, sws, R
	return, sws*sqrt( 1.0 - exp(-1.0d*( (R-2.8d)/8.1d)) )
end