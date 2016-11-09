function int2str,num,width=width
return,string(num,format=n_elements(width) eq 0?'(I0)':$
              '(I' + int2str(width) + '.' + int2str(width) +')')
end
