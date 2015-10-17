;+
; name:
;   rad_solar_declination.pro
;
; purpose:
;   Calculates from a time provided in UTC the solar declination angle in radians
;
; calling sequence:
;   declination =  rad_solar_declination(julian_time_utc)
;
; inputs:
;   julian_time_utc : double-precision number [or array]. julian date in utc.   
;   simplified      : keyword. If set, simplified formula from Oke 1987 is used
;                     (assumes circular orbit)      
;
; output:
;   declination : number [or array]. corresponding solar declination 
;                 angle in radians. Positive when N-hemisphere is tilted 
;                 towards sun (N-sommer)                
;   
; examples
;   print, rad_solar_declination(julday(6,21,2009,00,00))
;   plot, rad_solar_declination(julday(1,1,2010)+findgen(365))
;        
; references
;   http://www.srrb.noaa.gov/highlights/sunrise/solareqns.PDF
;        
; revision history:
;   16-Jun-09  : AC
;   28-Sep-10  : Added simplified keyword
;-


function rad_solar_declination, julian_time_utc, simplified=simplified
  
   ; **************************************************
   ; calculate fractional year in radians
   ; **************************************************
   
   caldat, julian_time_utc, month, day, year
   d_julian_utc = dat_dat2doy(day,month,year) 
   frac_year = (d_julian_utc-1) * 2 * !pi / 365 
   
   if not keyword_set(simplified) then begin
   
   ; **************************************************
   ; calculate solar declination using NOAA formula
   ; **************************************************
 
   declination = 0.006918-0.399912*cos(frac_year)+0.070257*sin(frac_year)-0.006758*cos(2*frac_year) $
      +0.000907*sin(2*frac_year)-0.002697*cos(3*frac_year)+0.00148*sin(3*frac_year) 
      
   endif else begin   

   ; **************************************************
   ; calculate solar declination using Oke (1987)
   ; this is assuming a circular orbit
   ; **************************************************

   declination = !dtor * (-23.4) * cos(2*!pi*(float(d_julian_utc+10)/365))

   endelse

   return, declination  
  
end
