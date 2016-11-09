PRO windows_close_all, skip=skip

device, window_state=ws
index=where(ws eq 1,count)

if n_elements(skip) eq 0 then skip = .5

for i=0,n_elements(index)-1 do begin
	no=where(index[i] eq skip, count)
	if count eq 0 then wdelete, index[i]
endfor

END
