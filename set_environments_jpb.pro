; Created	2014-03-20	to set environments.

pro set_environments_jpb

;this one works on UNIX only
spawn,'hostname -s',host
host=(strsplit(host,'.',/ext))(0)

case host of 
	'gail':	begin
		nrl_lib = '/volumes/data/solarsoft/ssw/soho/lasco'
		end


endcase

end
