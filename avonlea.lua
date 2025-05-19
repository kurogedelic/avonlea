-- avonlea.lua
-- the Lake of Shining Waters was blue — blue — blue;
-- not the changeful blue of spring, nor the pale azure of summer,
-- but a clear, steadfast, serene blue,
-- as if the water were past all modes and tenses of emotion
-- and had settled down to a tranquillity unbroken by fickle dreams.

engine.name = "Avonlea"

local avonlea = include("avonlea/lib/avonlea_engine")

function init()
  avonlea.add_params()
  avonlea.init()

  -- Optional: set default values
  params:set("depthMorph", 0.4)
  params:set("glintMorph", 0.3)
  params:set("weightMorph", 0.4)
  params:set("gain", 1.0)
end

-- Encoder control: E1–E3 map to depth/glint/weight
function enc(n, d)
  if n == 1 then
    params:delta("depthMorph", d)
  elseif n == 2 then
    params:delta("glintMorph", d)
  elseif n == 3 then
    params:delta("weightMorph", d)
  end
end

-- Optional: simple on-screen feedback
function redraw()
  screen.clear()
  screen.level(15)
  screen.move(10, 20)
  screen.text("Avonlea: Tranquil Lake")
  screen.move(10, 40)
  screen.text("E1: Depth  " .. string.format("%.2f", params:get("depthMorph")))
  screen.move(10, 50)
  screen.text("E2: Glint  " .. string.format("%.2f", params:get("glintMorph")))
  screen.move(10, 60)
  screen.text("E3: Weight " .. string.format("%.2f", params:get("weightMorph")))
  screen.update()
end

function metro_redraw()
  while true do
    clock.sleep(1 / 15)
    redraw()
  end
end

clock.run(metro_redraw)
