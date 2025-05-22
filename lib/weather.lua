-- weather.lua
-- Weather fetching module for Prince Edward Island
-- Uses Open-Meteo API with rate limiting

local weather = {}
local util = require "util"
local constants = include("lib/constants")

-- WMO Weather code mappings
local wmo_codes = {
  [0] = "Clear sky",
  [1] = "Mainly clear",
  [2] = "Partly cloudy", 
  [3] = "Overcast",
  [45] = "Fog",
  [48] = "Depositing rime fog",
  [51] = "Light drizzle",
  [53] = "Moderate drizzle",
  [55] = "Dense drizzle",
  [56] = "Light freezing drizzle",
  [57] = "Dense freezing drizzle",
  [61] = "Slight rain",
  [63] = "Moderate rain",
  [65] = "Heavy rain",
  [66] = "Light freezing rain",
  [67] = "Heavy freezing rain",
  [71] = "Slight snow",
  [73] = "Moderate snow",
  [75] = "Heavy snow",
  [77] = "Snow grains",
  [80] = "Slight rain showers",
  [81] = "Moderate rain showers",
  [82] = "Violent rain showers",
  [85] = "Slight snow showers",
  [86] = "Heavy snow showers",
  [95] = "Thunderstorm",
  [96] = "Thunderstorm with slight hail",
  [99] = "Thunderstorm with heavy hail"
}

-- Simple JSON parser for our specific use case
local function parse_weather_json(json_str)
  if not json_str or json_str == "" then 
    print("Empty JSON response")
    return nil 
  end
  
  -- Clean up the JSON string (remove extra whitespace)
  json_str = json_str:gsub("^%s*(.-)%s*$", "%1")
  
  -- Look for weather_code value with various possible formats
  local weather_code = json_str:match('"weather_code":%s*(%d+)')
  
  if weather_code then
    local code = tonumber(weather_code)
    print("Parsed weather code: " .. code)
    return code
  else
    print("Could not find weather_code in JSON: " .. json_str:sub(1, 200))
    return nil
  end
end

-- Weather module state
local last_fetch_time = 0
local fetch_interval = constants.WEATHER.FETCH_INTERVAL
local current_weather = {
  code = 0,
  description = "Clear sky",
  last_updated = "Never",
  fetching = false
}

-- API configuration  
local API_URL = constants.WEATHER.API_URL
local LATITUDE = tostring(constants.LOCATION.LATITUDE)
local LONGITUDE = tostring(constants.LOCATION.LONGITUDE)

-- Build API URL
local function build_api_url()
  return API_URL .. "?latitude=" .. LATITUDE .. 
         "&longitude=" .. LONGITUDE .. 
         "&current=weather_code"
end

-- Get weather description from WMO code
local function get_weather_description(code)
  return wmo_codes[code] or "Unknown weather (" .. code .. ")"
end

-- Fetch weather from API
local function fetch_weather_data()
  local url = build_api_url()
  
  print("Fetching weather from: " .. url)
  current_weather.fetching = true
  
  -- Use curl command with norns util.os_capture
  clock.run(function()
    local curl_command = "curl -s --connect-timeout " .. constants.WEATHER.CONNECT_TIMEOUT .. " --max-time " .. constants.WEATHER.MAX_TIMEOUT .. " '" .. url .. "'"
    
    -- Execute curl command
    local success, result = pcall(function()
      return util.os_capture(curl_command)
    end)
    
    current_weather.fetching = false
    
    if success and result and result ~= "" then
      print("Weather API response: " .. result)
      
      local weather_code = parse_weather_json(result)
      if weather_code then
        current_weather.code = weather_code
        current_weather.description = get_weather_description(weather_code)
        current_weather.last_updated = os.date("%H:%M")
        last_fetch_time = os.time()
        
        print("Weather updated: " .. current_weather.description .. " (code: " .. weather_code .. ")")
      else
        print("Failed to parse weather data")
        current_weather.description = "Parse error"
      end
    else
      print("Weather API error - Failed to fetch data")
      current_weather.description = "Network error"
    end
  end)
end

-- Initialize weather module
function weather.init()
  print("Weather module initialized")
  current_weather.description = "Not fetched yet"
  current_weather.last_updated = "Never"
  
  -- Start first fetch after a short delay to avoid startup issues
  clock.run(function()
    clock.sleep(2) -- Wait 2 seconds after init
    if not current_weather.fetching then
      fetch_weather_data()
    end
  end)
end

-- Update weather if needed (call this periodically)
function weather.update()
  local current_time = os.time()
  
  -- Check if we need to fetch (and not currently fetching)
  if (current_time - last_fetch_time) >= fetch_interval and not current_weather.fetching then
    fetch_weather_data()
  end
end

-- Force weather update (for manual refresh)
function weather.force_update()
  if not current_weather.fetching then
    last_fetch_time = 0 -- Reset timer to force immediate fetch
    fetch_weather_data()
  else
    print("Weather fetch already in progress")
  end
end

-- Get current weather info
function weather.get_current()
  return {
    description = current_weather.description,
    code = current_weather.code,
    last_updated = current_weather.last_updated,
    fetching = current_weather.fetching,
    next_update_in = math.max(0, fetch_interval - (os.time() - last_fetch_time))
  }
end

-- Get time until next update
function weather.get_next_update_time()
  return math.max(0, fetch_interval - (os.time() - last_fetch_time))
end

-- Check if weather affects visuals (for future integration)
function weather.is_clear()
  return current_weather.code <= 3
end

function weather.is_rainy()
  local code = current_weather.code
  return (code >= 51 and code <= 67) or (code >= 80 and code <= 82)
end

function weather.is_snowy()
  local code = current_weather.code
  return (code >= 71 and code <= 77) or (code >= 85 and code <= 86)
end

function weather.is_stormy()
  local code = current_weather.code
  return code >= 95
end

function weather.has_fog()
  local code = current_weather.code
  return code == 45 or code == 48
end

-- Get basic weather state (4 categories)
function weather.get_basic_state()
  if weather.is_snowy() then
    return "snowy"
  elseif weather.is_rainy() or weather.is_stormy() then
    return "rainy" 
  elseif weather.is_clear() then
    return "clear"
  else
    return "cloudy"
  end
end

-- Manual weather override for testing/artistic control
local manual_weather_override = nil
local weather_states = constants.WEATHER.STATES
local manual_weather_index = 1

-- Set manual weather override
function weather.set_manual_weather(state)
  manual_weather_override = state
  print("Manual weather set to: " .. state)
end

-- Cycle through weather states manually
function weather.cycle_manual_weather()
  manual_weather_index = (manual_weather_index % #weather_states) + 1
  local state = weather_states[manual_weather_index]
  
  if state == "auto" then
    manual_weather_override = nil
    print("Weather set to Auto (real weather)")
  else
    manual_weather_override = state
    print("Manual weather cycled to: " .. manual_weather_override)
  end
  
  return state
end

-- Get current effective weather state (manual override or actual)
function weather.get_effective_state()
  return manual_weather_override or weather.get_basic_state()
end

-- Check if using manual override
function weather.is_manual_mode()
  return manual_weather_override ~= nil
end

-- Get current display state (for UI)
function weather.get_display_state()
  if manual_weather_override == nil then
    return "Auto"
  else
    return manual_weather_override:gsub("^%l", string.upper)
  end
end

-- Weather-based sound parameter adjustments
local weather_sound_modifiers = {
  clear = {
    depth_factor = 1.0,    -- No change to moon-based depth
    glint_factor = 1.0,    -- No change to moon-based glint
    wind_offset = 0.0,     -- No additional wind
    atmosphere = 1.0       -- Full clarity
  },
  cloudy = {
    depth_factor = 0.9,    -- Slightly muted depth
    glint_factor = 0.7,    -- Reduced sparkle
    wind_offset = 0.1,     -- Light atmospheric movement
    atmosphere = 0.8       -- Slightly muffled
  },
  rainy = {
    depth_factor = 1.2,    -- Enhanced low frequencies
    glint_factor = 0.5,    -- Subdued highs
    wind_offset = 0.3,     -- Active atmospheric movement
    atmosphere = 0.6       -- More muffled
  },
  snowy = {
    depth_factor = 0.8,    -- Crisp, clear lows
    glint_factor = 0.4,    -- Very subdued highs
    wind_offset = 0.15,    -- Gentle movement
    atmosphere = 0.7       -- Crystal-clear but quiet
  }
}

-- Get weather-adjusted sound parameters
function weather.get_sound_modifiers()
  local state = weather.get_effective_state()
  return weather_sound_modifiers[state] or weather_sound_modifiers.clear
end

-- Disable manual override (return to actual weather)
function weather.use_actual_weather()
  manual_weather_override = nil
  print("Switched to actual weather")
end

return weather
