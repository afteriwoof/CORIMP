; Created:	2013-03-05	to tar up the cme detection files and copy them over to dublin.

pro run_batch_dets

;for i=2013,2013 do begin
i=2013
	for j=10,12 do begin
		if j lt 10 then j2='0'+int2str_huw(j) else j2=int2str_huw(j)
		spawn, 'tar -zcvf '+int2str_huw(i)+j2+'dets.tar.gz /volumes/store/processed_data/soho/lasco/detections/'+int2str_huw(i)+'/'+j2+'/'
		spawn, 'scp -i /home/gail/jbyrne/.ssh/id_dsa_jpb '+int2str_huw(i)+j2+'dets.tar.gz jbyrne@dublin.ifa.hawaii.edu:/Volumes/Bluedisk/detections/'
		spawn, 'rm '+int2str_huw(i)+j2+'dets.tar.gz'
	endfor
;endfor

end
