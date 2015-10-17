;+
; name:
;   rad_relative_sun_position.pro
;
; purpose:
;   Calculates the relative position of the sun for a given julian time/date in
;   UTC and given coordinates (decimal longitude, and latitude)
;
; calling sequence:
;   alti_az = rad_relative_sun_position(julian_time_utc, longitude_deg, latitude_deg)
;
; inputs:
;   julian_time_utc   : double-precision number [or array]. julian date in utc.
;   longitude_in_deg  : number. geographic longitude with E positive and W negative.              
;   latitude_in_deg   : number. geographic latitude with N positive and S negative.   
;   simplified        : keyword. if set - uses simplified declination formula 
;                       (see rad_solar_declination.pro)
; output:
;   alt_az            : array[2,t] with solar altiude in alt_az[0,*] and 
;                                       solar azimuth in alt_az[1,*] 
;                       solar altiude is angle in degrees of sun above local horizon                
;                       solar azimuth is angle in degrees of sun from local geogr. North
;                         
; examples
;   print, rad_relative_sun_position(julday(12,21,2009,12,00),.0,49.5)
;   print, rad_relative_sun_position(julday(6,21,2009,12,00),.0,49.5)
;   alti_az = rad_relative_sun_position(julday(21,21,2009,00,00)+dindgen(24*60)/(24*60)-(8./24),123.5,49.5)
;   plot, alti_az[0,*] ; solar altitude in degrees  
;   plot, alti_az[1,*] ; solar azimuth in degrees  
;        
; references
;   http://www.srrb.noaa.gov/highlights/sunrise/solareqns.PDF
;   T.R. Oke, 'Boundary Layer Climates'
;        
; revision history:
;   16-Jun-09  : AC
;   28-Sep-10  : Added simplified keyword
;-

function rad_relative_sun_position, julian_time_utc, longitude_deg, latitude_deg, simplified=simplified
  
  lat_rad = latitude_deg * !dtor
  
  ; **************************************************
  ; calculate solar declination
  ; **************************************************
  
  decl_rad = rad_solar_declination(julian_time_utc, simplified=simplified)
  
  ; **************************************************
  ; calculate locl apparent time
  ; **************************************************
  
  time_julian_lat = dat_utc2lat(julian_time_utc,longitude_deg) 
  
  ; **************************************************
  ; calculate solar hour angle in radians
  ; **************************************************
  
  caldat, time_julian_lat, mm, dd, yyyy, hh, ii
  tj = dat_dat2doy(dd,mm,yyyy)
  ha = (15. * (12.-(hh+(float(ii)/60)))) * !dtor
  
  cosZ = sin(lat_rad)*sin(decl_rad)+cos(lat_rad)*cos(decl_rad)*cos(ha)
  beta = asin(cosZ) * !radeg
  
  cos180mintheta = ((sin(lat_rad)*cosZ)-sin(decl_rad))/(cos(lat_rad)*sin(acos(cosZ))) < 1
  cos180mintheta = cos180mintheta > (-1) 
  solar_azimuth = 180 - (acos(cos180mintheta) * !radeg)
  afternoon = where(ha le 0, cnt)
  if cnt gt 0 then solar_azimuth[afternoon] = 360 - solar_azimuth[afternoon]
  
  solar_altitude = 90-(acos(cosZ)*!radeg)
  
  return, transpose([[reform(solar_altitude)],[reform(solar_azimuth)]])
  
end
