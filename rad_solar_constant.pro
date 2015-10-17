;+
; name:
;   rad_solar_constant.pro
;
; purpose:
;   Calculates the current solar irradiance at top of the atmosphere 
;   perpendicular to sun rays in W / m2 using the solar constant and correcting
;   for the changing distance Earth-Sun.
;
; calling sequence:
;   I0 = dat_relative_sun_position(julian_time_utc)
;
; inputs:
;   julian_time_utc   : double-precision number [or array [t]]. julian date in utc.
;   
; output:
;   I0 : number or arry[t]. current solar irradiance at top of the atmosphere 
;   perpendicular to sun rays in W / m2
;                         
; examples
;   print, rad_solar_constant(julday(6,17,2009,00,00))
;   1323.06
;        
; references
;   http://solardat.uoregon.edu/SolarRadiationBasics.html
;        
; revision history:
;   16-Jun-09  : AC
;-

function rad_solar_constant, julian_time_utc

   solar_constant_av = 1366.5 ; W m^-2
   
   ; **************************************************
   ; calculate fractional year in radians
   ; **************************************************
   
   caldat, julian_time_utc, month, day, year
   d_julian_utc = dat_dat2doy(day,month,year) 
   frac_year = (d_julian_utc) * 2 * !pi / 365 

   ; **************************************************
   ; calculate ratio (squared) of average radius 
   ; Earth-Sun to actual radius Earth-Sun (R_av / R)^2
   ; **************************************************
 
    ratio_squared = 1.00011 + 0.034221 * cos(frac_year) + 0.001280 * sin(frac_year) + 0.000719 * cos(2*frac_year) + 0.000077 * sin(2*frac_year)
    i0 = ratio_squared * solar_constant_av
    return, i0
    
end