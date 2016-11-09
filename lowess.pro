FUNCTION LOWESS,X,Y,WINDOW,NDEG, NOISE
;
;+
; NAME:
;	LOWESS
;
; PURPOSE:
;	Robust smoothing of 1D data. A non-parametric way of drawing a smooth
;	curve to represent data. (For 2D (map) data, use LOESS.)
;
; CALLING SEQUENCE:
;	YSmooth = LOWESS( X, Y, Window, NDeg, Noise )
;
; INPUT ARGUMENTS:
;	X = X values
;	Y = Y values, to be smoothed
;	WINDOW = width of smoothing window
;	NDEG   = degree of polynomial to be used within the window (1 or 2 
;		recommended)
;
; OUTPUT:
;	Ysmooth - LOWESS returns the vector of smoothed Y values
;
; OPTIONAL OUTPUT ARGUMENT:
;	Noise = the robust std. deviation w.r.t. the fit, at each point
;
; NOTE:
;	This routine uses a least-squares fit within a moving window. The fit
;	is weighted by statistical weights and weights that are a function of
;	distance from the center of the window. This is a "local weighted
;	polynomial regression smoother" (Cleveland 1979, Journal of the Amer.
;	Statistical Association, 74, 829-836).
;	A polynomial of degree NDEG+1 is fitted directly to the first and last 
;	WINDOW/2 points. 
;
;	This routine is fairly slow. 
;
; SUBROUTINES CALLED:
;	ROBUST_LINEFIT
;	ROBUST_POLY_FIT
;	ROB_CHECKFIT
;	ROBUST_SIGMA
;	POLYFITW
;	MED
;
; REVISION HISTORY:
;	Written,  H.T. Freudenreich, HSTX, 1/8/93
;	H.T. Freudenreich, 2/94 Return sigma rather than slope
;-

ON_ERROR,2

EPS = 1.0E-20

ITMAX = 3

M=WINDOW/2
N=N_ELEMENTS(X)

IF N_PARAMS() GT 4 THEN BEGIN
	   WANT_NOISE=1 
	      NOISE=FLTARR(N)
      ENDIF ELSE WANT_NOISE=0

      Z=Y

      FOR I=M,N-M-1 DO BEGIN
	        WIDENED=0

		  FITIT:
		    U=X(I-M:I+M) - X(I)
		      V=Y(I-M:I+M)

		      ; If V is constant, do nothing:
		        IF MAX(V) EQ MIN(V) THEN BEGIN
				     Z(I)=V(0)
				          IF WANT_NOISE EQ 1 THEN NOISE(I)=0.
					       GOTO,NEXT
					         ENDIF

						 ; First, a robust fit. Allowing more than 3 iterations is usually a waste
						 ; of time.
						   IF NDEG EQ 1 THEN CC=ROBUST_LINEFIT(  U,V,     YFIT, NUMIT=ITMAX )  ELSE $
							                       CC=ROBUST_POLY_FIT( U,V,NDEG,YFIT, NUMIT=ITMAX )
								       ; If no fit possible...
								         NCOEF=N_ELEMENTS(CC)
									   IF NCOEF NE (NDEG+1) THEN BEGIN
										        IF (I GT M) AND (I LT (N-M-1)) THEN BEGIN
												;       Widen the window temporarily and try again.
												        WINDOW=WINDOW+2 & M=M+1
													        PRINT,'LOWESS: Expanding window by 2 points to try again'
														        WIDENED = 1
															        GOTO,FITIT
																     ENDIF ELSE BEGIN
																	             Z(I) = MED(V)
																		             IF WANT_NOISE EQ 1 THEN NOISE(I)=ROBUST_SIGMA(V-Z(I),/ZERO)
																			             PRINT,'LOWESS: Taking Y median instead of fit'
																				             GOTO,NEXT
																					          ENDELSE
																						    ENDIF

																						    ; Now calculate the biweights from the residuals:
																						      R = V-YFIT
																						        SIG = ROBUST_SIGMA(R,/ZERO)
																							  IF WANT_NOISE EQ 1 THEN NOISE(I)=SIG
																							    IF SIG LT eps THEN SIG=TOTAL(ABS(R))/.8/N_ELEMENTS(R)
																							      IF SIG LT eps THEN BEGIN
																								           W=FLTARR(WINDOW)
																									        W(*)=1.0  ; equal weights
																										  ENDIF ELSE BEGIN
																											       R = ( R/(6.*SIG) )^2
																											            Q = WHERE(R GT 1.,COUNT) & IF COUNT GT 0 THEN R(Q)=1.
																												         W =(1.-R)^2
																													   ENDELSE

																													   ; Now multiply by the "distance" weights:
																													     DEL = .5*( U(1)-U(0)+U(M)-U(M-1) )
																													       D = DEL+MAX([U(WINDOW-1)-U(M),U(M)-U(0)]) ;=max distance of any point from Xi
																													         WD= ( 1.- ( ABS( ( U-U(M) )/D ) )^3 )^3

																														   W = W*WD
																														     W = W/TOTAL(W)

																														     ; Now a weighted polynomial fit:
																														       CC=POLYFITW(U,V,W,NDEG,YFIT)

																														         Z(I) = CC(0)
																															   IF WIDENED EQ 1 THEN BEGIN 
																																        WINDOW=WINDOW-2 & M=M-1
																																	     WIDENED=0
																																	       ENDIF

																																	         NEXT:
																																	 ENDFOR

																																	 ; Now take care of the end points! Fit a polynomial of degree NDEG to them.

																																	 I1=WINDOW-1
																																	 FITSTART:
																																	 U=X(0:I1)  &  V=Z(0:I1)
																																	 CC=ROBUST_POLY_FIT( U,V,NDEG,YFIT,SIG )  
																																	 IF N_ELEMENTS(CC) NE (NDEG+1) THEN BEGIN
																																		    I1=I1+1 
																																		       GOTO,FITSTART
																																	       ENDIF
																																	       Z(0:M-1) = YFIT(0:M-1)
																																	       IF WANT_NOISE EQ 1 THEN NOISE(0:M-1)=SIG

																																	       I1=N-WINDOW 
																																	       FITEND:
																																	       U=X(I1:N-1)  &  V=Z(I1:N-1)
																																	       CC=ROBUST_POLY_FIT( U,V,NDEG,YFIT,SIG )  
																																	       IF N_ELEMENTS(CC) NE (NDEG+1) THEN BEGIN
																																		          I1=I1-1 
																																			     GOTO,FITEND
																																		     ENDIF
																																		     IEND=N_ELEMENTS(YFIT)
																																		     Z(N-M:N-1)=YFIT(IEND-M:IEND-1)
																																		     IF WANT_NOISE EQ 1 THEN NOISE(N-M:N-1)=SIG

																																		     RETURN,Z
																																		     END

