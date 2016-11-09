;THE O.A.R. IDL LIBRARY
;
;radial_profile.pro
;
;DOWNLOAD
;
;+
; NAME:
;
;       RADIAL_PROFILE
;
; PURPOSE:
;
;		Radial profile revolution image with median, mean, min or polyfit.
;
; DESCRIPTION:
;
;		Generates the radial profile image of the given image by using the median,
;		the mean, the min or a polynomial fit.
;		Useful e.g. to fit a vignetting function to an image.
;
;
; CATEGORY:
;
;       Image Processing.
;
; CALLING SEQUENCE:
;
;		Result = RADIAL_PROFILE(image, center = center, levels = levels, $
	;				smoothness=smoothness, mean = mean, min=min, poly=poly)
;
;
; KEYWORD PARAMETERS:
;
;		CENTER: two element vector of the form [xc, yc] with the coordinates of the center of the radial profile.
;				Default is the center of the image.
;
;		SMOOTHNESS:	number of levels to smooth, default = no smoothing
;
;		LEVELS: number of rings for which to compute the profile, default = 100
;
;		MEAN: if set, the profile is the mean around each ring, defalut = median.
;
;		MIN: if set, the profile is the minimum around each ring, defalut = median.
;
;		POLY: degree of a polynomyal to fit the radial profile, default = no polynomial fit
;
;
; OUTPUTS:
;
;       The returned array is the radial smooth of the image.
;
;
;
; MODIFICATION HISTORY:
;
;       Feb 2004 - 	Gianluca Li Causi, INAF - Rome Astronomical Observatory
;					licausi@mporzio.astro.it
;					http://www.mporzio.astro.it/~licausi/
;
;-


FUNCTION Radial_Profile, image, center = center, levels = levels, $
			smoothness=smoothness, mean=mean, min=min, poly=poly


		s = size(image)

		IF n_elements(center) EQ 0 THEN center = [s[1]/2., s[2]/2.]

		IF n_elements(levels) EQ 0 THEN levels = 100.

		IF n_elements(smoothness) EQ 0 THEN smoothness = 0.

		IF n_elements(mean) EQ 0 THEN mean = 0

		IF n_elements(min) EQ 0 THEN min = 0

		IF KEYWORD_SET(poly) THEN IF levels LT (poly+1) THEN MESSAGE, "Levels must be more than (poly + 1)!"


		xc = center[0]
		yc = center[1]

		nraggi = levels

		raggio = shift(dist(2*s[1], 2*s[2]), s[1]/2+xc, s[2]/2+yc)
		raggio = raggio[s[1]/2:s[1]+s[1]/2-1, s[2]/2:s[2]+s[2]/2-1]
		mi = min(raggio)
		delta_raggi = (max(raggio) - mi)/float(nraggi-1)
		raggi = findgen(nraggi)*delta_raggi + mi

		;Compute radial profile:
		profile = fltarr(nraggi)
		FOR r = 0, nraggi-1 DO BEGIN
				indexes = where( fix((raggio - mi)/delta_raggi) EQ r, count)
					IF count GT 0 THEN BEGIN
								IF mean EQ 0 THEN profile[r] = median(image[indexes]) ELSE $
												IF min EQ 0 THEN profile[r] = avg(image[indexes]) ELSE $
																profile[r] = min(image[indexes])
																ENDIF
															ENDFOR

															;Smooth radial profile:
															IF smoothness GT 0 THEN BEGIN
																	profile = [profile, reverse(profile), profile, reverse(profile)]
																		profile = smooth(profile, smoothness, /edge_truncate)
																			profile = profile[2*nraggi:3*nraggi-1]
																		ENDIF

																		;Poly fit radial profile:
																		IF KEYWORD_SET(poly) THEN BEGIN
																				coef = POLY_FIT(raggi, profile, poly)
																					fit = 0
																						FOR i = 0, poly DO fit = fit + coef[i]*raggi^i
																							;plot, profile
																								;oplot, fit, color=255
																									profile=fit
																								ENDIF

																								;Build radial image:
																								flat = fltarr(s[1], s[2])
																								FOR x = 0, s[1]-1 DO BEGIN
																										FOR y = 0, s[2]-1 DO BEGIN
																													flat[x,y] = profile((raggio[x,y]-mi) / delta_raggi)
																														ENDFOR
																													ENDFOR

																													RETURN, flat

																													END





;																													NOTE: All the routines and applications listed here are available to be downloaded by anybody and new routines are welcome from any user.
;																													Anyway, there is no supervision on the uploads, so that each author is responsible for the routines he has provided with its description and images.
;																													Any user is invited to test the routines before use.
;																													The manager of this page is only responsible for the organization and maintainance of the library.
;																													Should any out of topic or offending material be uploaded to this page, the responsible user will be removed from the users list permanently.
;
;
;																													This page is maintained by Gianluca Li Causi
;																													licausi@mporzio.astro.it



