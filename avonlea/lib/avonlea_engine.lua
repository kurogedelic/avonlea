-- avonlea_engine.lua
-- Lua wrapper for the Avonlea SuperCollider engine

local controlspec = require("core/controlspec")

local Avonlea = {}

Avonlea.metadata = {
  name = "Avonlea",
  version = "1.0",
  author = "You",
  description = "Ambient morphing engine with deep filter and spatial movement"
}

-- Declare the engine
engine.name = "Avonlea"

-- Parameter definitions
function Avonlea.add_params()
  params:add_control("depthMorph", "Depth Morph", controlspec.new(0, 1, 'lin', 0.01, 0.4))
  params:add_control("glintMorph", "Glint Morph", controlspec.new(0, 1, 'lin', 0.01, 0.3))
  params:add_control("weightMorph", "Weight Morph", controlspec.new(0, 1, 'lin', 0.01, 0.4))
  params:add_control("gain", "Master Gain", controlspec.new(0.1, 2.0, 'lin', 0.01, 1.0))
end

-- Connect Norns params to engine
function Avonlea.init()
  params:set_action("depthMorph", function(x) engine.set("depthMorph", x) end)
  params:set_action("glintMorph", function(x) engine.set("glintMorph", x) end)
  params:set_action("weightMorph", function(x) engine.set("weightMorph", x) end)
  params:set_action("gain", function(x) engine.set("gain", x) end)
  
  -- エンジン起動時にデフォルトパラメータを設定
  engine.set("depthMorph", params:get("depthMorph"))
  engine.set("glintMorph", params:get("glintMorph"))
  engine.set("weightMorph", params:get("weightMorph"))
  engine.set("gain", params:get("gain"))
end

return Avonlea