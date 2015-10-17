;+
; name:
;   dat_utc2lat.pro
;
; purpose:
;   Converts a time provided in UTC to local apparent time (i.e. considers
;   the equation of time)
;
; calling sequence:
;   julian_time_lat = dat_utc2lat(julian_time_utc, longitude_in_deg)
;
; inputs:
;   julian_time_utc   : double-precision number [or array]. julian date in utc.
;   longitude_in_deg  : number. geographic longitude with E positive and W negative.              
;
; output:
;   julian_time_lat   : double-precision number [or array]. corresponding julian 
;                       date in in local apparent time.
;   
; examples
;   date = julday(2,22,2009,00,00)
;   print, dat_jul2string(date,/time)
;        22.2.2009 0:00
;   print, dat_jul2string(dat_utc2lat(date,123.00),/time)
;        22.2.2009 8:25   
;        
; references
;   http://www.srrb.noaa.gov/highlights/sunrise/solareqns.PDF
;        
; revision history:
;   16-Jun-09  : AC
;-


function dat_utc2lat, julian_time_utc, longitude_in_deg
    
   ; **************************************************
   ; calculate fractional year in radians
   ; **************************************************
   
   caldat, julian_time_utc, month, day, year
   d_julian_utc = dat_dat2doy(day,month,year) 
   frac_year = (d_julian_utc-1) * 2 * !pi / 365 
   
   ; **************************************************
   ; convert UTC to LMST (Local mean solar time)
   ; **************************************************
   
   julian_time_lmst = julian_time_utc + float(longitude_in_deg)/360
   
   ; **************************************************
   ; solve equation of time
   ; **************************************************
   
   eq_of_time_in_min = 229.18*(0.000075+0.001868*cos(frac_year)-0.032077*sin(frac_year)-0.014615*cos(2*frac_year)-0.040849*sin(2*frac_year))
   eq_of_time_in_days = eq_of_time_in_min / (60.*24)
   julian_time_lat = julian_time_lmst - eq_of_time_in_days 
   return, julian_time_lat



end
