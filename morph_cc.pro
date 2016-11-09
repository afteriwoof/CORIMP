Function morph_cc,A,start,filter=filter,max_iterations=max_iterations,count=count
IF n_params() LT 2 THEN Message, 'Too Few Arguments to Functionâ'
IF KEYWORD_SET(filter) THEN B=filter ELSE B=[[1b,1b,1b],[1b,1b,1b],[1b,1b,1b]]
IF NOT KEYWORD_SET(max_iterations) THEN max_iterations=10000L
sa=Size(A,/dim)
X=BytArr(sa[0],sa[1]) & X[start]=1b
Y=BytArr(sa[0],sa[1])
count=0
WHILE ((min(X EQ Y) EQ 0) AND (count LT max_iterations)) DO BEGIN
	count=count+1
	Y=X
	X=Dilate(Y,B) AND A
ENDWHILE
RETURN,X
END
