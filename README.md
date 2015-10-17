# Solar-Irradiance-Calculations

## Programs to handle solar geometry

Description: A set of programs to calculate extraterrestrial solar irradiance, sun paths, direct and diffuse radiation for a given location. Developped for teaching solar geometry.

## rad_extraterrestrial_irradiance.pro

Calculates for a given geographic location the extraterrestrial irradiance (i.e. without effect of the atmosphere) on a hoizontal surface (on Earth) in W/m2.

## rad_relative_sun_position.pro

Calculates the relative position of the sun (solar altitude, solar azimuth) for a given julian time/date in UTC and given coordinates (decimal longitude, and latitude).

## rad_solar_declination.pro

Calculates from a date / time provided in UTC the solar declination angle in radians.

## rad_solar_constant.pro

Calculates the current solar irradiance at top of the atmosphere perpendicular to sun rays in W / m2 using the solar constant and correcting for the changing distance Earth-Sun.

## Programs to handle date and time conversions

### dat_utc2lat.pro

Converts a time provided in UTC to local apparent time (LAT) (i.e. considers the equation of time)

### dat_dat2doy.pro

Calculates for a given day, month, and year the day of the year (DOY).

### dat_months.pro

Returns the first day of year (DOY) for all twelve months. 

### dat_leapyear.pro

Checks if a year is a leap-year.
