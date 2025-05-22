-- constants.lua
-- Centralized management of all constants and magic numbers

local constants = {}

-- ===== Geographic Settings =====
constants.LOCATION = {
  LATITUDE = 46.49300,   -- Prince Edward Island
  LONGITUDE = -63.38729,
  ELEVATION = 4,         -- Meters
  TIMEZONE = -3,         -- ADT (Atlantic Daylight Time)
  VIEW_AZIMUTH = 180,    -- View direction (180=South)
  FOV = 120              -- Field of view (degrees)
}

-- ===== UI Settings =====
constants.UI = {
  -- Screen size
  SCREEN_WIDTH = 128,
  SCREEN_HEIGHT = 64,
  
  -- Moon drawing
  MOON_SIZE = 6,         -- Moon diameter (pixels)
  
  -- Display times
  PARAM_DISPLAY_TIME = 1.0,    -- Parameter display time (seconds)
  WEATHER_DISPLAY_TIME = 1.0,   -- Weather display time (seconds)
  
  -- Frame rate
  REDRAW_FPS = 15,       -- Redraw frame rate
  
  -- Levels
  MAX_SCREEN_LEVEL = 15,
  MIN_SCREEN_LEVEL = 1
}

-- ===== Encoder Settings =====
constants.ENCODERS = {
  WIND = 1,              -- Wind control (E1)
  DEPTH = 2,             -- Depth control (E2)  
  GLINT = 3              -- Glint control (E3)
}

-- ===== Audio Parameters =====
constants.AUDIO = {
  -- Default values
  DEFAULT_DEPTH = 0.5,
  DEFAULT_GLINT = 0.4,
  DEFAULT_WIND = 0.3,
  DEFAULT_GAIN = 0.9,
  DEFAULT_ATMOSPHERE = 1.0,
  
  -- Ranges
  MIN_PARAM = 0.0,
  MAX_PARAM = 1.0,
  MIN_GAIN = 0.1,
  MAX_GAIN = 2.0,
  
  -- Encoder sensitivity
  ENCODER_SENSITIVITY = 0.2
}

-- ===== Weather System =====
constants.WEATHER = {
  -- Update intervals
  FETCH_INTERVAL = 3600, -- 1 hour (seconds)
  AUTO_UPDATE_INTERVAL = 300, -- 5 minutes (seconds)
  
  -- API settings
  API_URL = "https://api.open-meteo.com/v1/forecast",
  CONNECT_TIMEOUT = 10,
  MAX_TIMEOUT = 15,
  
  -- Weather states
  STATES = {"auto", "clear", "cloudy", "rainy", "snowy"}
}

-- ===== Visual Settings =====
constants.VISUAL = {
  -- Animation speeds
  STAR_ANIMATION_SPEED = 0.1,
  REED_ANIMATION_SPEED = 0.8,
  GLINT_ANIMATION_SPEED = 0.3,
  REFLECTION_ANIMATION_SPEED = 0.2,
  
  -- Object counts
  NUM_REEDS = 60,
  NUM_STARS = 30,
  NUM_GLINTS = 45,
  NUM_TREE_GROUPS = 10,
  NUM_RAIN_PARTICLES = 10,
  NUM_SNOW_PARTICLES = 30,
  
  -- Position ranges
  STAR_Y_MAX = 17,       -- Maximum Y position for stars (above hills)
  REED_Y_MIN = 56,       -- Minimum Y position for reeds
  REED_Y_MAX = 63,       -- Maximum Y position for reeds  
  REED_HEIGHT_MIN = 4,   -- Minimum reed height
  REED_HEIGHT_MAX = 12,  -- Maximum reed height
  GLINT_Y_MIN = 34,      -- Minimum Y position for glints
  GLINT_Y_MAX = 50,      -- Maximum Y position for glints
  GLINT_LENGTH_MIN = 3,  -- Minimum glint length
  GLINT_LENGTH_MAX = 10, -- Maximum glint length
  
  -- Weather effects
  RAIN_SPEED_MIN = 10,
  RAIN_SPEED_MAX = 15,
  RAIN_LENGTH_MIN = 5,
  RAIN_LENGTH_MAX = 10,
  SNOW_SPEED_MIN = 0.5,
  SNOW_SPEED_MAX = 1.3,
  SNOW_SIZE_MIN = 0.5,
  SNOW_SIZE_MAX = 1.0,
  
  -- Shooting stars
  SHOOTING_STAR_CHANCE = 0.01, -- Appearance probability
  SHOOTING_STAR_ANGLE = 120,   -- Trajectory angle
  SHOOTING_STAR_SPEED_MIN = 1.5,
  SHOOTING_STAR_SPEED_MAX = 2.5,
  SHOOTING_STAR_LENGTH_MIN = 4,
  SHOOTING_STAR_LENGTH_MAX = 10,
  SHOOTING_STAR_BRIGHTNESS_MIN = 8,
  SHOOTING_STAR_BRIGHTNESS_MAX = 15
}

-- ===== Moon Calculations =====
constants.MOON = {
  -- Orbital parameters
  LUNAR_CYCLE_DAYS = 29.53058868,
  ANOMALISTIC_MONTH = 27.55455,
  ORBITAL_INCLINATION = 5.1, -- Degrees
  
  -- Reference date (Julian Date)
  REFERENCE_JD = 2451550.1, -- January 6, 2000 18:00 new moon
  
  -- Mapping ranges
  DEPTH_MIN = 0.3,
  DEPTH_MAX = 0.8,
  GLINT_MIN = 0.2,
  GLINT_MAX = 0.8,
  
  -- Altitude calculation
  BASE_ALTITUDE = 30,    -- Base altitude
  SEASONAL_VARIATION = 15, -- Seasonal variation
  NIGHT_ALTITUDE_BONUS = 20 -- Night altitude bonus
}

-- ===== Debug Settings =====
constants.DEBUG = {
  ENABLED = false,       -- Debug mode
  VERBOSE_WEATHER = false,
  VERBOSE_MOON = false,
  VERBOSE_VISUAL = false,
  SHOW_FPS = false
}

-- ===== System Settings =====
constants.SYSTEM = {
  ENGINE_INIT_DELAY = 0.5, -- Engine initialization wait time
  WEATHER_INIT_DELAY = 2.0, -- Weather initialization wait time
  CLOCK_SLEEP_MIN = 1/60   -- Minimum clock sleep time
}

return constants
