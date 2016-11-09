function cme_eta, t_obs, v_cme, print = print

; Time for CME to travel 1 AU

  t_cme = 1.49e8 / v_cme 

; Time for CME to travel to L1
	t_cme_l1 = (1.49e8 *.99) / v_cme

; Calc ETA of CME at 1AU

  t_obs = anytim( t_obs )
	t_obs_l1 = t_obs

  t_arrive = anytim( t_obs + t_cme, /vms )
	t_arrive_l1 = anytim(t_obs_l1+t_cme_l1, /vms)
  
  if keyword_set( print ) then begin

    print, '% Number of days for CME arrival @ 1AU: ', $
  	      arr2str( (t_cme ) / ( 24. * 60. * 60. ), /trim ), ' days'
    print, '% ETA of CME @ 1AU: ', t_arrive

	print, '% Number of days for CME arrival @ L1: ', $
  	      arr2str( (t_cme_l1 ) / ( 24. * 60. * 60. ), /trim ), ' days'
    print, '% ETA of CME @ L1: ', t_arrive_l1

  endif

  return, t_arrive

	; Time for CME to travel to L1
	t_cme = (1.49e8 *.99) / v_cme
	t_arrive

end
