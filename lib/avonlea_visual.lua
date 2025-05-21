-- avonlea_visual.lua
-- Visual elements and drawing functions for Avonlea
--
-- Handles the rendering of stars, moon, hills, lake and reeds

-- Set fixed global random seed to ensure consistency
math.randomseed(12345)

local visual = {}

-- Initialize once and persist
visual.initialized = false
visual.DEBUG = true -- Set to true to enable additional debug output

-- Store global time reference for continuous animation
visual.start_time = nil

-- Trees on distant hills
visual.trees = {}

-- Wind settings
visual.wind = {
  speed = 0.0,           -- Wind speed (0-1), start with no wind
  -- Animation base speeds (per-element defaults)
  reed_speed = 0.8,      -- Reed animation base speed
  glint_speed = 0.3,     -- Glint animation base speed
  reflection_speed = 0.2 -- Moon reflection animation base speed
}

-- Include the shooting star module
local shooting_star = include("lib/shooting_star")

-- Initialize with required dependencies
function visual.init(moon_data, params)
  if visual.DEBUG then
    print("\n*** VISUAL INIT CALLED ***")
  end

  -- Only initialize graphics once
  if visual.initialized then
    -- Just update references if already initialized
    visual.moon = moon_data
    visual.params = params

    if visual.DEBUG then
      print("Visual already initialized - skipping full init")
      print("Current wind speed: " .. visual.wind.speed)
    end

    return
  end

  -- First time initialization
  visual.initialized = true

  -- Store references to moon data and params
  visual.moon = moon_data
  visual.params = params

  -- First time full initialization
  if visual.DEBUG then
    print("Doing first-time full initialization...")
  end

  -- Initialize reeds
  visual.reeds = {}
  for i = 1, 60 do
    local x = math.random(0, 127)
    local y = math.random(56, 63)
    local h = math.random(4, 12)
    local phase = math.random(0, 100) / 100
    local color = math.random(1, 4)
    table.insert(visual.reeds, { x = x, y = y, h = h, phase = phase, color = color })
  end

  -- Initialize stars
  visual.stars = {}
  -- Generate more stars and ensure some near the left edge
  for i = 1, 30 do
    local x, y
    if i <= 5 then
      -- Guarantee some stars in the left 0-20px region
      x = math.random(0, 20)
      y = math.random(0, 17) -- above hills
    else
      x = math.random(0, 127)
      y = math.random(0, 17) -- above hills
    end
    local phase = math.random(0, 100) / 100
    local freq = math.random(25, 75) / 100 -- Halved frequency for slower animation
    table.insert(visual.stars, { x = x, y = y, phase = phase, freq = freq })
  end

  -- Initialize lake glints
  visual.glints = {}
  -- Increase number of glints for more reflections
  for i = 1, 45 do
    local x = math.random(0, 127)
    local y = math.random(34, 50) -- lake surface area
    local len = math.random(3, 10)
    local phase = math.random(0, 100) / 100
    local freq = math.random(20, 50) / 100
    table.insert(visual.glints, { x = x, y = y, len = len, phase = phase, freq = freq })
  end

  -- Initialize trees on distant hills
  visual.trees = {}
  -- Create more groups of trees
  local num_groups = 10
  for g = 1, num_groups do
    -- Each group has a cluster of trees
    local group_x = 5 + math.random(0, 118)    -- Spread across screen
    local group_width = 5 + math.random(5, 15) -- Width of cluster
    local num_trees = 3 + math.random(2, 6)    -- More trees per cluster

    local group = {
      x = group_x,
      width = group_width,
      trees = {}
    }

    -- Individual trees in this group
    for t = 1, num_trees do
      local tree_x = group_x + math.random(-math.floor(group_width / 2), math.floor(group_width / 2))
      local tree_y = 29 + math.random(0, 1)
      local tree_height = 2 + math.random(0, 300) / 100                           -- Varied heights
      local tree_width = 0.5 + math.random(0, math.floor(tree_height * 30)) / 100 -- Slimmer trees
      local tree_type = math.random(1, 2)                                         -- 1=straight, 2=slight angle

      table.insert(group.trees, {
        x = tree_x,
        y = tree_y,
        height = tree_height,
        width = tree_width,
        type = tree_type
      })
    end

    table.insert(visual.trees, group)
  end

  -- Set screen anti-aliasing (disabled)
  screen.aa(0)

  -- Initialize with default params
  if params:get("wind_speed") ~= 0 then
    visual.wind.speed = params:get("wind_speed")
  else
    params:set("wind_speed", 0)
    visual.wind.speed = 0
  end

  -- Store initial time for continuous animation
  visual.start_time = util.time()
end

-- Set wind speed
function visual.set_wind_speed(speed)
  if visual.DEBUG and visual.wind.speed ~= speed then
    print(string.format("Wind speed changing: %.2f -> %.2f", visual.wind.speed, speed))
  end

  visual.wind.speed = speed
end

-- Draw the stars
function visual.draw_stars(t)
  -- Layer 1: Stars
  for _, s in ipairs(visual.stars) do
    -- Fixed base animation, no wind effect for stars
    local base_speed = 0.1
    local alpha = 0.5 + 0.5 * math.sin((t * base_speed) + (s.phase * math.pi * 2))
    local level = math.floor(alpha * 5.0) -- subtle stars

    if level > 0 then
      screen.level(level)
      -- Make sure stars can be drawn at x=0
      local x = math.max(0.5, math.floor(s.x))
      screen.rect(x, math.floor(s.y), 1, 0) -- Proper rect size for a 1x1 pixel
      screen.stroke()
    end
  end
end

-- Draw the moon
function visual.draw_moon(t)
  -- Don't draw if moon is off-screen
  if not visual.moon.visible then return end

  -- Only draw if moon is visible on screen
  local x, y = visual.moon.x, visual.moon.y
  local radius = visual.moon.size / 2

  -- Select drawing method based on moon phase
  local phase = visual.moon.phase -- range 0-1

  -- Check for new moon
  if phase < 0.05 or phase > 0.95 then
    -- Near new moon - don't draw anything (too dark or too small to see)
    return
  elseif phase > 0.45 and phase < 0.55 then
    -- Near full moon - simple circle
    screen.level(15) -- white
    screen.circle(x, y, radius)
    screen.fill()
  else
    -- For crescent and quarter moons
    -- Simple drawing using two circles
    local curve
    local waxing = phase < 0.5 -- Waxing is 0.0-0.5, waning is 0.5-1.0

    -- Normalize moon phase
    local norm_phase
    if waxing then
      norm_phase = phase * 2       -- 0.0-0.5 → 0.0-1.0
    else
      norm_phase = (1 - phase) * 2 -- 0.5-1.0 → 1.0-0.0
    end

    -- Curvature value for natural crescent shape
    curve = math.sin(norm_phase * math.pi / 2) * radius * 1.1

    -- Calculate tilt for waxing/waning crescent
    local offset_x, offset_y

    -- Calculate 45-degree tilt for moon (skip if not possible)
    local angle = math.rad(45) -- Convert 45 degrees to radians
    local offset_len = curve

    if waxing then
      -- Waxing: tilt toward top-right
      offset_x = -offset_len * math.cos(angle)
      offset_y = -offset_len * math.sin(angle)
    else
      -- Waning: tilt toward top-left
      offset_x = offset_len * math.cos(angle)
      offset_y = -offset_len * math.sin(angle)
    end

    -- Draw moon outline (circle)
    screen.level(15) -- white
    screen.circle(x, y, radius)
    screen.fill()

    -- Draw shadow part (subtract another circle using blend mode)
    screen.level(0)      -- black
    screen.blend_mode(1) -- XOR mode: erase overlapping parts

    -- Draw tilted circle
    screen.circle(x + offset_x, y + offset_y, radius * 1.2)
    screen.fill()

    -- Reset blend mode
    screen.blend_mode(0)
  end

  -- Display moon information
  if visual.params:get("show_moon_info") == 2 then
    screen.move(2, 10)
    screen.level(15)
    screen.text(string.format("Phase: %.2f", visual.moon.phase))
    screen.move(2, 18)
    screen.text(string.format("Az: %.1f", visual.moon.azimuth))
    screen.move(2, 26)
    screen.text(string.format("Alt: %.1f", visual.moon.altitude))
  end
end

-- Draw trees on hills
function visual.draw_trees()
  -- Layer 2.5: Trees on distant hills (between stars and hills)


  -- Draw each group of trees
  for _, group in ipairs(visual.trees) do
    -- Draw each tree in the group
    for _, tree in ipairs(group.trees) do
      -- Tree base position (at hill level)
      local base_x = tree.x
      local base_y = tree.y -- Hill level, adjust as needed

      -- Draw very simple trees, just like reeds but shorter
      if tree.type == 1 then
        -- Straight tree
        screen.level(2)
        screen.move(base_x, base_y)
        screen.line(base_x, base_y - tree.height)
        screen.stroke()
      else
        -- Slightly angled tree
        screen.level(1)
        local angle = tree.width * 0.3 -- Small angle
        screen.move(base_x, base_y)
        screen.line(base_x + angle, base_y - tree.height)
        screen.stroke()
      end
    end
  end
end

-- Draw the hills
function visual.draw_hills()
  -- Layer 3: Distant hills
  screen.level(1)
  screen.move(0, 25)
  screen.curve(32, 26, 64, 24, 100, 32)
  screen.line(0, 32)
  screen.close()
  screen.fill()
  screen.stroke()

  -- Layer 4: Hills using Bezier curves
  screen.level(2)
  screen.move(0, 30)
  -- screen.curve(32, 26, 64, 30, 96, 27)
  screen.curve(96, 30, 98, 25, 128, 27)
  screen.line(128, 32)
  screen.close()
  screen.fill()
  screen.stroke()

  -- Layer 5: Waterline (hill to water transition)
  screen.level(5)
  screen.move(0, 30)
  screen.curve(32, 30, 64, 32, 128, 31)
  screen.stroke()
end

-- Draw the lake with glints
function visual.draw_lake(t)
  -- screen.level(1)
  -- screen.rect(0, 32, 128, 64)
  -- screen.fill()
  -- Layer 6: Lake surface with glints
  for _, g in ipairs(visual.glints) do
    -- No animation if wind is completely off
    if visual.wind.speed <= 0 then
      screen.level(2) -- Minimal static brightness
      screen.move(g.x, g.y + 0.5)
      screen.line(g.x + g.len, g.y + 0.5)
      screen.stroke()
    else
      -- Simple animation that scales with wind, using t directly + fixed offset
      local base_speed = 0.2 -- Fixed base speed
      local speed = base_speed * visual.wind.speed
      local brightness = 3 + (visual.wind.speed * 4)

      -- Use time and fixed offset rather than random phase
      local alpha = 0.5 + 0.5 * math.sin((t * speed) + (g.phase * math.pi * 2))
      local level = math.floor(alpha * brightness)

      screen.level(level)
      screen.move(g.x, g.y + 0.5)
      screen.line(g.x + g.len, g.y + 0.5)
      screen.stroke()
    end
  end
end

-- Draw the reeds
function visual.draw_reeds(t)
  -- Layer 7: Reeds
  for _, r in ipairs(visual.reeds) do
    -- No movement if wind is completely off
    if visual.wind.speed <= 0 then
      screen.level(r.color)
      screen.move(r.x, r.y)
      screen.line(r.x, r.y - r.h)
      screen.stroke()
    else
      -- Very gentle animation that scales with wind speed
      local base_speed = 0.4 -- Fixed base speed
      local speed = base_speed * visual.wind.speed
      local amount = 1.5 * visual.wind.speed

      -- Use direct time rather than multiplying by random frequency
      local sway = math.sin((t * speed) + (r.phase * math.pi * 2)) * amount
      screen.level(r.color)
      screen.move(r.x, r.y)
      screen.line(r.x + sway, r.y - r.h)
      screen.stroke()
    end
  end
end

-- Draw the moon's reflection on the water
function visual.draw_moon_reflection(t)
  -- Layer 8: Moon reflection on water surface
  if visual.moon.visible then
    local reflection_y = 64 - (visual.moon.y - 30)  -- Invert height to position below water
    if reflection_y > 32 and reflection_y < 64 then -- Only if below water surface
      -- Draw moon reflection
      screen.level(5)                               -- Reflection is dimmer

      if visual.wind.speed <= 0 then
        -- Completely still reflection
        local width = visual.moon.size / 2.5
        local height = visual.moon.size * 0.4 / 4

        screen.ellipse(visual.moon.x, reflection_y, width, height)
        screen.fill()
      else
        -- Animate based on wind - use fixed factors
        local base_speed = 0.1 -- Very slow base speed
        local speed = base_speed * visual.wind.speed
        local sway_amount = visual.wind.speed * 2
        local stretch = 0.4 + (visual.wind.speed * 0.3)

        -- Simple animation with fixed phase offset
        local sway = math.sin(t * speed + 0.5) * sway_amount
        local width = visual.moon.size / 2.5
        local height = visual.moon.size * stretch / 4

        screen.ellipse(visual.moon.x + sway, reflection_y, width, height)
        screen.fill()
      end
    end
  end
end

-- Main redraw function that calls all drawing elements in order
function visual.redraw()
  -- Calculate elapsed time since start for animation
  local current_time = util.time()
  local elapsed_time = current_time - visual.start_time

  -- Use this elapsed time for all animations to ensure continuity
  local t = elapsed_time

  screen.clear()

  -- Draw all elements in layer order
  visual.draw_stars(t)           -- Layer 1: Stars
  shooting_star.update()         -- Check for shooting star generation
  shooting_star.draw()           -- Draw shooting star if active
  visual.draw_moon(t)            -- Layer 2: Moon

  visual.draw_hills()            -- Layers 3-5: Hills and waterline
  visual.draw_trees()            -- Layer 2.5: Trees on distant hills
  visual.draw_lake(t)            -- Layer 6: Lake surface
  visual.draw_reeds(t)           -- Layer 7: Reeds
  visual.draw_moon_reflection(t) -- Layer 8: Moon reflection

  screen.update()
end

return visual
