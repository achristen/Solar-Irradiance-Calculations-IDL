;+
; name:
;   rad_model_davies_and_hay.pro
;
; purpose:
;   Models the diffuse and direct solar irradiance on a horizontal surface 
;   (for clear-sky conditions) after Davies and Hay (1979)
;
; calling sequence:
;   model = rad_model_davies_and_hay(julian_time_utc, longitude_deg, latitude_deg)
;
; inputs:
;   julian_time_utc   : double-precision number [or array with t elements]. julian date in utc.
;   longitude_in_deg  : number. geographic longitude with E positive and W negative.              
;   latitude_in_deg   : number. geographic latitude with N positive and S negative.   
;   
; output:
;   model : [structure] {It[t],Id[t],Is[t],Ias[t],Ig[t]}
;   It  : Total solar irradiance (direct + diffuse) on a horizontal surface in W/m2
;   Id  : Direct solar irradiance on a horizontal surface in W/m2
;   Is  : Diffuse solar irradiance (Is = Ias + Ig) on a horizontal surface in W/m2
;   Ias : Solar irradiance on a horizontal surface from atmospheric scattering in W/m2
;   Ig  : Solar irradiance on a horizontal surface from multiple scattering between the 
;         ground and the sky in W/m2 
;                         
; examples
;   time = julday(6,17,2009,00,00)+(8.0/24)+findgen(24*2)/(24.*2) ; create time series over 1 day
;   result = rad_model_davies_and_hay(time,-123.078436,49.226125,total_precipitable_water_mm=5)
;
; references:
;  Davies, J. A., Hay, J. E. 'Calculation of the Solar Radiation Incident on a 
;  Horizontal Surface'. Proc. First Canadian Solar Radiation Workshop, April 17-19, 
;  1978. Can. Atmos. Environment Sercice, 1979.
;  Bird, R. E., and R. L. Hulstrom, Simplified Clear Sky Model for Direct and Diffuse 
;  Insolation on Horizontal Surfaces, Technical Report No. SERI/TR-642-761, Golden, 
;  CO: Solar Energy Research Institute, 1981
;  
; revision history:
;   17-Jun-09  : AC
;-  

function rad_model_davies_and_hay, julian_time_utc, longitude_deg, latitude_deg, $
    total_o3_mm = total_o3_mm, total_precipitable_water_mm=total_precipitable_water_mm, $
    K_aerosol=K_aerosol, surface_pressure=surface_pressure, $
    surface_albedo = surface_albedo
    
    ;****************************************************
    ; Inputs
    ;****************************************************

    if not keyword_set(total_o3_mm) then total_o3_mm = 300.0 ; default total column ozone
    U0 = float(total_o3_mm) / 10 ; mm -> cm
    
    if not keyword_set(total_precipitable_water_mm) then total_precipitable_water_mm = 20.0 ; default precipitable water column
    UW = float(total_precipitable_water_mm) / 10 ; mm -> cm
    
    if not keyword_set(K_aerosol) then K_aerosol = 0.91 ; default from Davies and Hay
    
    if not keyword_set(surface_pressure) then surface_pressure = 1013.0
    
    if not keyword_set(surface_albedo) then surface_albedo = 0.15
    
    ; constants
    W0 = 0.98 ; aerosol single scattering albedo
    Ba = 0.85 ; aerosol forward scattering albedo
    
    ;****************************************************
    ; Solar constant varies with distance Earth-Sun
    ;****************************************************
    
    I0 = rad_solar_constant(julian_time_utc)
    
    ;****************************************************
    ; Solar zenith angle, altitude and azimuth
    ;****************************************************
    
    alt_az = rad_relative_sun_position(julian_time_utc, longitude_deg, latitude_deg)
    Z = (90.0-float(reform(alt_az[0,*])))*!dtor; zenith angle
    cosZ = cos(Z)
    out = where(cosZ ge 1 or cosZ le 0.03, fcnt)
    if fcnt gt 0 then cosZ[out] = !values.f_nan
    
    ;****************************************************
    ; Optical air mass
    ;****************************************************
    
    M = float((cosZ + 0.15 * (93.885 - Z)^(-1.25))^(-1.0)); 
    night = where(M lt 0, ncnt)
    if ncnt gt 0 then M[night] = !values.f_infinity 
    m_prime = (M*surface_pressure) / 1013.0 ; pressure corrected air mass
    
    ;****************************************************
    ; Transmittance of ozone absorptance
    ;****************************************************
    
    X0 = U0 * M
    T0 = 1 - 0.02118 * X0 / (1 + 0.042 * X0 + 0.000323 * X0^2) $
         - 1.082 * X0 / (1 + 138.6 * X0)^0.805 - 0.0658 * X0 / (1 + (103.6 * X0)^3)
         
    ;****************************************************
    ; Transmittance of precipit. water vapour
    ;****************************************************  
         
    XW = UW * M     
    aw = 2.0 * XW / ((1 + 141.5 * XW)^0.635 + 5.925 * XW)     
    
    ;****************************************************
    ; Transmittance of aerosols
    ;****************************************************
    
    TA = K_aerosol^M
    sky_albedo = 0.0685 + (1 - Ba) * (1 - TA) * W0
    
    ;****************************************************
    ; Transmittance of Rayleigh scattering (Bird model)
    ;****************************************************
    
    TR = exp(-0.0903 * M_prime^0.84 * (1 + m_prime - m_prime^1.01))
    
    ;****************************************************
    ; Model
    ;****************************************************
         
    Id_red = (cosz) * (T0*TR-aw)* TA     
    Id  = I0 * Id_red
    zero = where(finite(Id) eq 0 or Id_red ge 1, zcnt)
    if zcnt gt 0 then Id[zero] = 0.0
    
    Ias_red = (cosz) * (T0*(1-TR)*TA*0.5+(T0*TR-aw)*(1-TA)*W0*Ba)
    Ias = I0 * Ias_red
    zero = where(finite(Ias) eq 0 or Ias_red ge 1, zcnt)
    if zcnt gt 0 then Ias[zero] = 0.0
    
    Ig  = sky_albedo * surface_albedo * (Id + Ias) / (1 - sky_albedo * surface_albedo)
    zero = where(finite(Ig) eq 0, zcnt)
    if zcnt gt 0 then Ig[zero] = 0.0
    
    Is = Ias + Ig
    zero = where(finite(Is) eq 0, zcnt)
    if zcnt gt 0 then Is[zero] = 0.0
    
    It  = Id + Ias + Ig

    results = {It:It,Id:Id,Is:Is,Ias:Ias,Ig:Ig}
    return, results
 
end