-- avonlea_engine.lua
-- Lua wrapper for the Avonlea SuperCollider engine
-- 月のパラメータとの連携機能を追加

local controlspec = require("core/controlspec")

local Avonlea = {}

Avonlea.metadata = {
  name = "Avonlea",
  version = "1.0",
  author = "You",
  description = "Ambient morphing engine with deep filter and spatial movement"
}

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

-- 月の初期化関数 - エンジンが準備できた後に呼び出す
function Avonlea.init_moon()
  -- エンジンのmoon関数を安全に呼び出す
  if type(engine.moon) == "function" then
    -- 初期月パラメータ設定（デフォルト値）
    engine.moon(0.5, 30) -- デフォルト：月の満ち欠け=0.5（半月）、高度=30度
    print("Moon parameters initialized")
  else
    print("Warning: engine.moon function not available yet")
  end
end

-- 風速パラメータのアクションを設定する関数
function Avonlea.set_wind_action(visual)
  params:set_action("wind_speed", function(val)
    -- ビジュアルモジュールに風速を送信
    if visual then
      visual.set_wind_speed(val)
    end
    
    -- サウンドエンジンに風速を送信 - 安全に呼び出す
    if type(engine.wind) == "function" then
      engine.wind(val)
      print(string.format("Wind speed sent to engine: %.2f", val))
    else
      print("Warning: engine.wind function not available yet")
    end
  end)
  
  -- 初期アクション設定のみで、初期化は行わない
end

-- 月のパラメータをエンジンに送信する関数
function Avonlea.update_moon_params(phase, altitude)
  -- 月のパラメータを安全に送信
  if type(engine.moon) == "function" then
    engine.moon(phase, altitude)
    print(string.format("Moon params sent to engine - Phase: %.2f, Altitude: %.1f", phase, altitude))
  else
    print("Warning: Cannot update moon parameters - engine.moon not available")
  end
end

return Avonlea