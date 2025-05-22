-- avonlea_engine.lua
-- Lua wrapper for the Avonlea SuperCollider engine
-- Updated design based on three basic parameters (depth, glint, wind)

local controlspec = require("core/controlspec")
local weather = include("lib/weather")

local Avonlea = {}

Avonlea.metadata = {
  name = "Avonlea",
  version = "1.0",
  author = "kurogedelic",
  description = "Ambient synthesizer inspired by Green Gables with lullaby elements"
}

-- Parameter definitions
function Avonlea.add_params()
  params:add_separator("Sound Parameters")
  
  -- Three basic parameters
  params:add_control("depth", "Depth", controlspec.new(0, 1, 'lin', 0.01, 0.5))
  params:add_control("glint", "Glint", controlspec.new(0, 1, 'lin', 0.01, 0.4))
  params:add_control("wind", "Wind", controlspec.new(0, 1, 'lin', 0.01, 0.3))
  params:add_control("gain", "Master Gain", controlspec.new(0.1, 2.0, 'lin', 0.01, 0.9))
  
  -- Presets
  params:add_separator("Presets")
  
  params:add_trigger("preset_calm", "Calm Waters")
  params:set_action("preset_calm", function()
    params:set("depth", 0.7)
    params:set("glint", 0.3)
    params:set("wind", 0.1)
  end)
  
  params:add_trigger("preset_night", "Starry Night")
  params:set_action("preset_night", function()
    params:set("depth", 0.5)
    params:set("glint", 0.6)
    params:set("wind", 0.3)
  end)
  
  params:add_trigger("preset_breezy", "Breezy Evening")
  params:set_action("preset_breezy", function()
    params:set("depth", 0.4)
    params:set("glint", 0.5)
    params:set("wind", 0.6)
  end)
  
  params:add_trigger("preset_dreamy", "Dream Lullaby")
  params:set_action("preset_dreamy", function()
    params:set("depth", 0.8)
    params:set("glint", 0.4)
    params:set("wind", 0.2)
  end)
end

-- Connect Norns params to engine
function Avonlea.init()
  params:set_action("depth", function(x) 
    Avonlea.update_weather_adjusted_params()
    -- When depth parameter changes, reflect to visual effects
    if Avonlea.visual then
      Avonlea.visual.set_depth(x)
    end
  end)
  
  params:set_action("glint", function(x)
    Avonlea.update_weather_adjusted_params()
    -- When glint parameter changes, reflect to visual effects
    if Avonlea.visual then
      Avonlea.visual.set_glint(x)
    end
  end)
  
  params:set_action("wind", function(x)
    Avonlea.update_weather_adjusted_params()
    -- When wind parameter changes, reflect to visual effects
    if Avonlea.visual then
      Avonlea.visual.set_wind_speed(x)
    end
  end)
  
  params:set_action("gain", function(x) engine.gain(x) end)
  
  -- Set default parameters on engine startup
  clock.run(function()
    clock.sleep(0.3) -- Wait longer for engine to fully load
    Avonlea.update_weather_adjusted_params()
    engine.gain(params:get("gain"))
    print("Engine initialized with weather-adjusted parameters")
  end)
end

-- Apply weather adjustments to sound parameters
function Avonlea.update_weather_adjusted_params()
  local modifiers = weather.get_sound_modifiers()
  
  -- Get base parameter values
  local base_depth = params:get("depth")
  local base_glint = params:get("glint")
  local base_wind = params:get("wind")
  
  -- Apply weather modifiers
  local adjusted_depth = base_depth * modifiers.depth_factor
  local adjusted_glint = base_glint * modifiers.glint_factor
  local adjusted_wind = math.min(1.0, base_wind + modifiers.wind_offset)
  
  -- Send to engine (with error protection)
  engine.depth(adjusted_depth)
  engine.glint(adjusted_glint)
  engine.wind(adjusted_wind)
  
  -- Check if atmosphere command exists before calling
  pcall(function()
    engine.atmosphere(modifiers.atmosphere)
  end)
  
  -- Debug output
  if modifiers.depth_factor ~= 1.0 or modifiers.glint_factor ~= 1.0 or modifiers.wind_offset ~= 0.0 then
    print(string.format("Weather adjustment - D:%.2f->%.2f G:%.2f->%.2f W:%.2f->%.2f A:%.2f", 
      base_depth, adjusted_depth, base_glint, adjusted_glint, base_wind, adjusted_wind, modifiers.atmosphere))
  end
end

-- Update weather effects (call when weather changes)
function Avonlea.update_weather()
  Avonlea.update_weather_adjusted_params()
end

-- Set up connection with visual module
function Avonlea.connect_visual(visual)
  Avonlea.visual = visual
  print("Connected to visual module")
end

return Avonlea
