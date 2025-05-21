
--
-- The Lake of Shining Waters at night
-- The water gleams quietly beneath the starlight,
-- reeds sway in the evening breeze, distant hills lie in shadow.
-- The lake sleeps in silver-bathed stillness,
-- only small dreamlike ripples disturbing the moon's path.


local util = require "util"
-- 音響エンジンを使用しないバージョン
-- engine.name = "None"


-- coding guide:
-- comments are must write by English

-- Encoder assignments - easily changeable
local WIND_ENCODER = 1         -- Wind speed control (default: E1)
local DEPTH_MORPH_ENCODER = 2  -- Depth morph control (default: E2)
local WEIGHT_MORPH_ENCODER = 3 -- Weight morph control (default: E3)

-- Include modules
-- local avonlea = include("lib/avonlea_engine") -- 音響エンジンモジュールは使用しない
local moon_calc = include("lib/moon_calculator")
local visual = include("lib/avonlea_visual")

-- Check if file exists, create if not
local function check_file_exists(file)
  local f = io.open(file, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- Location information for Green Gables area
local LATITUDE = 46.49300    -- Latitude (North)
local LONGITUDE = -63.38729  -- Longitude (West)
local ELEVATION = 4          -- Elevation (m)
local VIEW_AZIMUTH = 180     -- View direction (180=South)
local FOV = 120             -- Field of view (degrees)

-- Moon drawing settings
local MOON_SIZE = 6    -- Moon diameter (pixels) - reduced size
local current_date = { -- Initial date/time
  year = 2024,
  month = 5,
  day = 20,
  hour = 22,
  minute = 0,
  second = 0,
  time_zone = -3 -- ADT (Atlantic Daylight Time)
}

-- Moon information
local moon = {
  phase = 0,        -- Moon phase (0-1)
  azimuth = 0,      -- Azimuth angle
  altitude = 0,     -- Altitude
  x = 0,            -- X coordinate on screen
  y = 0,            -- Y coordinate on screen
  visible = false,  -- Visible on screen
  shape_data = nil, -- Moon shape data
  size = MOON_SIZE  -- Moon size (for visual module)
}

-- Get and set current time
function set_current_time()
  -- Get Norns time
  local s, us = norns.time.get_time()
  local offset = current_date.time_zone * 3600
  local adjusted_s = s + offset

  -- Split time components
  local t = os.date("%Y-%m-%d %H:%M:%S", adjusted_s)
  local year, month, day, hour, minute, sec = string.match(t, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
  
  -- Debug time info
  print("Current system time: " .. t)
  print(string.format("Time components: %s-%s-%s %s:%s:%s", year, month, day, hour, minute, sec))

  -- Update parameters
  params:set("year", tonumber(year))
  params:set("month", tonumber(month))
  params:set("day", tonumber(day))
  params:set("hour", tonumber(hour))
  params:set("minute", tonumber(minute))

  -- Update moon data
  update_moon_data()
end

-- Calculate moon position and phase
function update_moon_data()
  -- Calculate Julian date
  local jd = moon_calc.calculate_julian_date(
    current_date.year,
    current_date.month,
    current_date.day,
    current_date.hour,
    current_date.minute,
    0
  )

  -- Calculate moon phase
  moon.phase = moon_calc.calculate_moon_phase(jd)

  -- Use simplified position calculation for consistent visibility
  local position = moon_calc.calculate_simplified_position(jd, current_date.month, current_date.hour)
  moon.azimuth = position.azimuth
  moon.altitude = position.altitude

  -- Calculate screen position
  local screen_pos = moon_calc.calculate_screen_position(
    moon.azimuth,
    moon.altitude,
    VIEW_AZIMUTH,
    FOV,
    128, -- Screen width
    64,  -- Screen height
    MOON_SIZE / 2 -- Pass radius
  )

  moon.x = screen_pos.x
  moon.y = screen_pos.y
  moon.visible = screen_pos.visible -- Always show if in view

  -- Generate moon shape data
  moon.shape_data = moon_calc.generate_moon_shape(moon.phase, MOON_SIZE)
  
  -- 月のデータをサウンドエンジンに送信しない
  -- if avonlea then avonlea.update_moon_params(moon.phase, moon.altitude) end

  -- Display debug information
  local date_str = string.format("%04d-%02d-%02d %02d:%02d",
    current_date.year,
    current_date.month,
    current_date.day,
    current_date.hour,
    current_date.minute)
  print("=== Moon update at " .. date_str .. " ===")
  print(string.format("Location: Lat=%.5f, Long=%.5f, View=%d°", LATITUDE, LONGITUDE, VIEW_AZIMUTH))
  print(string.format("Julian Date: %.5f", jd))
  print(string.format("Moon phase: %.2f", moon.phase))
  print(string.format("Moon position: Azimuth=%.2f°, Altitude=%.2f°", moon.azimuth, moon.altitude))
  print(string.format("Screen position: X=%.2f, Y=%.2f", moon.x, moon.y))
  print(string.format("Moon visible: %s", moon.visible and "YES" or "NO"))

  if not moon.visible then
    -- Explain why not visible
    if not screen_pos.visible then
      if moon.altitude < 0 then
        print("Reason: Moon is below horizon (altitude < 0)")
      else
        print("Reason: Outside viewport (azimuth difference too large)")
        local rel_azimuth = (moon.azimuth - VIEW_AZIMUTH) % 360
        if rel_azimuth > 180 then rel_azimuth = rel_azimuth - 360 end
        print(string.format("Relative azimuth: %.2f° (FOV is %.1f°)", rel_azimuth, FOV))
      end
    elseif moon.phase <= 0.01 or moon.phase >= 0.99 then
      print("Reason: Near new moon - too dark")
    end
  else
    -- Summarize visibility conditions
    print("Visibility conditions:")
    print(string.format("- Time: %s", date_str))
    print(string.format("- Phase: %.2f (0=new, 0.5=full)", moon.phase))
    print(string.format("- Altitude: %.1f° (negative=below horizon)", moon.altitude))
    
    local rel_azimuth = (moon.azimuth - VIEW_AZIMUTH) % 360
    if rel_azimuth > 180 then rel_azimuth = rel_azimuth - 360 end
    print(string.format("- Rel. Azimuth: %.1f° (should be between ±%.1f° to be in FOV)", 
      rel_azimuth, FOV/2))
  end
  print("===========================")
end

function init()
  -- 音響エンジンの初期化は行わない
  -- avonlea.add_params()
  -- avonlea.init()
  
  -- 初期化時に月のデータをサウンドエンジンに送信するプリセット

  -- オーディオパラメータは使用しない
  -- params:set("depthMorph", 0.4)
  -- params:set("glintMorph", 0.3)
  -- params:set("weightMorph", 0.4)
  -- params:set("gain", 1.0)

  -- Add wind parameter
  params:add_separator("Visual Parameters")

  params:add_control("wind_speed", "Wind Speed", controlspec.new(0.0, 1.0, 'lin', 0.01, 0.5, ""))
  -- 風速パラメータのアクションを直接設定
  params:set_action("wind_speed", function(val)
    -- ビジュアルモジュールに風速を送信
    visual.set_wind_speed(val)
    print(string.format("Wind speed set to: %.2f", val))
  end)

  -- Add date and time settings
  params:add_separator("Moon Settings")

  params:add_number("year", "Year", 2020, 2030, current_date.year)
  params:set_action("year", function(x)
    current_date.year = x; update_moon_data()
  end)

  params:add_number("month", "Month", 1, 12, current_date.month)
  params:set_action("month", function(x)
    current_date.month = x; update_moon_data()
  end)

  params:add_number("day", "Day", 1, 31, current_date.day)
  params:set_action("day", function(x)
    current_date.day = x; update_moon_data()
  end)

  params:add_number("hour", "Hour", 0, 23, current_date.hour)
  params:set_action("hour", function(x)
    current_date.hour = x; update_moon_data()
  end)

  params:add_number("minute", "Minute", 0, 59, current_date.minute)
  params:set_action("minute", function(x)
    current_date.minute = x; update_moon_data()
  end)

  -- Time sync button
  params:add_trigger("use_current_time", "Use Current Time")
  params:set_action("use_current_time", function() set_current_time() end)

  -- Initialize moon data
  update_moon_data()

  -- Moon info display
  params:add_option("show_moon_info", "Show Moon Info", { "No", "Yes" }, 2)

  -- Initialize visual module
  visual.init(moon, params)
  
  -- エンジンコマンドの初期化は使用しない
  -- clock.run(function()
  --   -- エンジンの完全な初期化を待つ
  --   clock.sleep(0.1)
  --   
  --   -- 月の初期化
  --   avonlea.init_moon()
  --   
  --   -- 風のコマンドが準備できたら進める
  --   if type(engine.wind) == "function" then
  --     engine.wind(params:get("wind_speed"))
  --     print("Wind parameters initialized with: " .. params:get("wind_speed"))
  --   else
  --     print("Warning: engine.wind function not available")
  --   end
  --   
  --   -- 月のデータを最新の値で再送信
  --   avonlea.update_moon_params(moon.phase, moon.altitude)
  -- end)

  -- Set up redraw clock
  redraw_clock = clock.run(function()
    while true do
      clock.sleep(1 / 15)
      redraw()
    end
  end)

  -- Display debug information
  print("=== Moon Visibility Debug Info ===")
  print(string.format("Moon phase: %.2f", moon.phase))
  print(string.format("Moon position: Azimuth=%.2f, Altitude=%.2f", moon.azimuth, moon.altitude))
  print(string.format("Screen position: X=%.2f, Y=%.2f", moon.x, moon.y))
  print(string.format("Moon visible: %s", moon.visible and "YES" or "NO"))
  print("===================================")
end

-- Encoder control update
function enc(n, d)
  -- Map encoders to parameters using the assignment variables
  if n == WIND_ENCODER then
    local old_val = params:get("wind_speed")
    params:delta("wind_speed", d)
    local new_val = params:get("wind_speed")

    if old_val ~= new_val then
      print(string.format("Wind changed: %.2f -> %.2f", old_val, new_val))
      -- Check if reeds phases are stable
      if visual.reeds and visual.reeds[1] then
        print(string.format("Reed 1 phase: %.4f", visual.reeds[1].phase))
      end
    end
  elseif n == DEPTH_MORPH_ENCODER then
    -- 音響パラメータは無効化
    -- params:delta("depthMorph", d)
  elseif n == WEIGHT_MORPH_ENCODER then
    -- 音響パラメータは無効化
    -- params:delta("weightMorph", d)
  end
end

-- Key handler
function key(n, z)
  if n == 2 and z == 1 then
    -- K2 toggles moon info display and prints debugging info
    params:delta("show_moon_info", 1)
    print("\n=== DEBUGGING INFO ====")
    print("Current wind level: " .. params:get("wind_speed"))
    print("Actual wind speed: " .. visual.wind.speed)
    print("Visual module initialized: " .. (visual.initialized and "YES" or "NO"))
    print("Showing first few reeds phases:")
    for i = 1, 3 do
      if visual.reeds[i] then
        print(string.format("Reed %d phase: %.4f", i, visual.reeds[i].phase))
      end
    end
    print("=======================")
  elseif n == 3 and z == 1 then
    -- K3 refreshes current time
    set_current_time()
  end
end

-- Use visual module's redraw function
function redraw()
  visual.redraw()
end
