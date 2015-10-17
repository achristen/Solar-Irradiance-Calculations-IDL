;+
; name:
;   rad_extraterrestrial_irradiance.pro
;
; purpose:
;   Calculates for a given geographic location the extraterrestrial irradiance 
;   (i.e. without effect of the atmosphere) on a hoizontal surface in W/m2.
;
; calling sequence:
;   kex = rad_extraterrestrial_irradiance(julian_time_utc, longitude_deg, latitude_deg)
;
; inputs:
;   julian_time_utc   : double-precision number [or array]. julian date in utc.
;   longitude_in_deg  : number. geographic longitude with E positive and W negative.              
;   latitude_in_deg   : number. geographic latitude with N positive and S negative.  
;   allow_negative    : keyword. outputs negative values (default is zero) 
;   simplified        : keyword. if set - uses simplified declination formula 
;                       (see rad_solar_declination.pro)
;                          
; output:
;   kex : extraterrestrial irradiance on a hoizontal surface in W/m2.
;                         
; examples
;   utc = julday(6,17,2009,12,00)+8./24
;   print, rad_extraterrestrial_irradiance(utc,-123.078436,49.226125)
;            
; revision history:
;   16-Jun-09  : AC
;-


function rad_extraterrestrial_irradiance, julian_time_utc, longitude_deg, latitude_deg, allow_negative=allow_negative, simplified=simplified

    i0 = rad_solar_constant(julian_time_utc) ; irradiance perpendicular to sun's rays
    alt_az = rad_relative_sun_position(julian_time_utc, longitude_deg, latitude_deg, simplified=simplified)
    kex = (cos((90-alt_az[0,*])*!dtor) * i0) 
    if not keyword_set(allow_negative) then begin
     ltz = where(kex lt 0, ltzcnt)
     if ltzcnt gt 0 then kex[ltz] = 0.0
    endif
    return, kex
    
end

