-- moon_calculator.lua
-- Simple implementation for calculating moon position and phase

local MoonCalc = {}

-- Convert degrees to radians
function MoonCalc.deg_to_rad(deg)
  return deg * (math.pi / 180)
end

-- Convert radians to degrees
function MoonCalc.rad_to_deg(rad)
  return rad * (180 / math.pi)
end

-- Calculate Julian date for the specified date and time
function MoonCalc.calculate_julian_date(year, month, day, hour, minute, second)
  if month <= 2 then
    year = year - 1
    month = month + 12
  end
  
  local a = math.floor(year / 100)
  local b = 2 - a + math.floor(a / 4)
  
  local jd = math.floor(365.25 * (year + 4716)) + math.floor(30.6001 * (month + 1)) + day + b - 1524.5
  jd = jd + (hour + minute / 60 + second / 3600) / 24
  
  return jd
end

-- Calculate moon phase (0-1): 0=new moon, 0.5=full moon
function MoonCalc.calculate_moon_phase(jd)
  -- Approximate value of lunar cycle (days)
  local lunarCycle = 29.53058868
  
  -- Reference date (January 6, 2000 at 18:00): new moon on this date
  local reference = 2451550.1
  
  -- Calculate elapsed days and derive the moon phase
  local daysSinceRef = jd - reference
  local phase = (daysSinceRef % lunarCycle) / lunarCycle
  
  return phase
end

-- Calculate moon azimuth and altitude
function MoonCalc.calculate_moon_position(jd, latitude, longitude)
  -- This is a simplified implementation. Actual astronomical calculations are more complex.
  -- Lunar cycle (days)
  local lunarCycle = 29.53058868
  local anomalisticMonth = 27.55455 -- Anomalistic month (period when moon is closest to Earth)
  
  -- Days since reference date
  local daysSinceRef = jd - 2451550.1
  
  -- Moon phase (radians)
  local phase = (daysSinceRef % lunarCycle) / lunarCycle * 2 * math.pi
  
  -- Moon orbital inclination (about 5.1 degrees)
  local inclination = MoonCalc.deg_to_rad(5.1)
  
  -- Simplified position calculation
  -- In reality, more complex calculations are needed, but this simplified implementation reproduces basic motion
  
  -- Moon right ascension (range 0-360 degrees)
  local ra = (daysSinceRef % 27.32158) / 27.32158 * 360
  
  -- Moon declination (range -5.1 to +5.1 degrees)
  local dec = math.sin(phase) * MoonCalc.rad_to_deg(inclination)
  
  -- Approximate calculation of Local Sidereal Time (LST)
  local lst = (jd % 1) * 360 + longitude
  
  -- Calculate hour angle
  local ha = lst - ra
  if ha < 0 then ha = ha + 360 end
  
  -- Convert to azimuth and altitude
  local lat_rad = MoonCalc.deg_to_rad(latitude)
  local dec_rad = MoonCalc.deg_to_rad(dec)
  local ha_rad = MoonCalc.deg_to_rad(ha)
  
  -- Calculate altitude
  local altitude = math.asin(
    math.sin(lat_rad) * math.sin(dec_rad) + 
    math.cos(lat_rad) * math.cos(dec_rad) * math.cos(ha_rad)
  )
  
  -- Calculate azimuth
  local azimuth = math.atan2(
    math.sin(ha_rad),
    math.cos(ha_rad) * math.sin(lat_rad) - math.tan(dec_rad) * math.cos(lat_rad)
  )
  azimuth = MoonCalc.rad_to_deg(azimuth) + 180 -- 0 is north, clockwise
  
  return {
    azimuth = azimuth % 360,
    altitude = MoonCalc.rad_to_deg(altitude)
  }
end

-- Calculate the screen position (x, y) of the moon with the specified observation conditions
function MoonCalc.calculate_screen_position(azimuth, altitude, view_azimuth, fov, screen_width, screen_height)
  -- Center coordinates of the screen
  local center_x = screen_width / 2
  local center_y = screen_height / 2
  
  -- Calculate azimuth difference (normalized to range from -180 to 180)
  local rel_azimuth = (azimuth - view_azimuth) % 360
  if rel_azimuth > 180 then rel_azimuth = rel_azimuth - 360 end
  
  -- Calculate x-coordinate on screen (based on azimuth)
  local x = center_x + (rel_azimuth / (fov/2)) * (screen_width / 2)
  
  -- Calculate y-coordinate on screen (based on altitude) - higher altitude means lower position on screen
  -- In typical cameras, vertical FOV is narrower than horizontal FOV, so adjust the coefficient
  local vertical_fov = fov * (screen_height / screen_width)
  local y = center_y - (altitude / (vertical_fov/2)) * (screen_height / 2)
  
  -- Check if it's within the screen bounds
  local visible = true
  if x < 0 or x > screen_width or y < 0 or y > screen_height then
    visible = false
  end
  
  return {
    x = x,
    y = y,
    visible = visible
  }
end

-- Generate drawing data for the moon phase
function MoonCalc.generate_moon_shape(phase, size)
  -- Determine the shape of the moon phase based on the phase
  -- phase: 0=new moon, 0.25=first quarter, 0.5=full moon, 0.75=last quarter
  
  local radius = size / 2
  local shape = {}
  
  -- Generate the basic circular shape of the moon
  for i = 0, 360, 5 do
    local angle = math.rad(i)
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius
    table.insert(shape, {x = x, y = y})
  end
  
  -- Calculate waxing and waning based on phase
  local terminator = {}
  local norm_phase = phase % 1
  
  -- Generate the shape of the moon's phase (new moon → full moon → new moon cycle)
  local illumination_ratio
  if norm_phase < 0.5 then
    illumination_ratio = norm_phase * 2 -- 0-0.5 => 0-1
  else
    illumination_ratio = (1 - norm_phase) * 2 -- 0.5-1 => 1-0
  end
  
  -- Calculate the position of the moon's edge (terminator position)
  local terminator_x = math.cos(norm_phase * 2 * math.pi) * radius
  
  -- Determine the shape of the illuminated portion
  local is_waxing = norm_phase >= 0 and norm_phase < 0.5
  
  return {
    shape = shape,
    phase = norm_phase,
    illumination_ratio = illumination_ratio,
    terminator_x = terminator_x,
    is_waxing = is_waxing
  }
end

return MoonCalc
