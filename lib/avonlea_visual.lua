-- avonlea_visual.lua
-- Visual elements and drawing functions for Avonlea
--
-- Handles the rendering of stars, moon, hills, lake and reeds

-- Set fixed global random seed to ensure consistency
math.randomseed(1908)

local visual = {}
local constants = include("lib/constants")

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

-- Weather state
visual.weather = {
  current_state = "clear", -- Current weather state
  fade_alpha = 1.0,        -- For transition effects
  rain_particles = {},     -- Rain particles
  snow_particles = {}      -- Snow particles
}

-- Include the shooting star module
local shooting_star = include("lib/shooting_star")

-- Update and draw rain
function visual.update_and_draw_rain(t)
  for _, rain in ipairs(visual.weather.rain_particles) do
    -- Update position
    rain.y = rain.y + rain.speed
    rain.x = rain.x + visual.wind.speed * 0.5 -- Wind effect

    -- Reset if off screen
    if rain.y > constants.UI.SCREEN_HEIGHT + 6 then
      rain.y = math.random(-20, -5)
      rain.x = math.random(0, constants.UI.SCREEN_WIDTH)
    end
    if rain.x > constants.UI.SCREEN_WIDTH then rain.x = 0 end
    if rain.x < 0 then rain.x = 128 end

    -- Calculate wind wiggle for angle
    local wind_wiggle = 0
    if visual.wind.speed > 0 then
      -- Create subtle angle variation based on wind
      local wiggle_frequency = 0.05 + (visual.wind.speed * 0.03)
      local wiggle_amount = visual.wind.speed * 1.5
      wind_wiggle = math.sin((t * wiggle_frequency) + (rain.x * 0.01)) * wiggle_amount
    end

    -- Draw rain drop with angled line
    screen.level(2 + math.random(0, 2))
    screen.move(rain.x, rain.y)
    screen.line(rain.x + 1 + wind_wiggle, rain.y + rain.length)
    screen.stroke()
  end
end

-- Update and draw snow
function visual.update_and_draw_snow(t)
  for _, snow in ipairs(visual.weather.snow_particles) do
    -- Update position
    snow.y = snow.y + snow.speed
    snow.x = snow.x + snow.drift + visual.wind.speed * 0.3 -- Wind + drift

    -- Reset if off screen
    if snow.y > constants.UI.SCREEN_HEIGHT + 6 then
      snow.y = math.random(-20, -5)
      snow.x = math.random(0, constants.UI.SCREEN_WIDTH)
    end
    if snow.x > constants.UI.SCREEN_WIDTH then snow.x = 0 end
    if snow.x < 0 then snow.x = 128 end

    -- Draw snowflake
    local alpha = 0.7 + 0.3 * math.sin(t + snow.x * 0.1)
    screen.level(math.floor(alpha * 4))
    screen.circle(snow.x, snow.y, snow.size)
    screen.fill()
  end
end

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
  for i = 1, constants.VISUAL.NUM_REEDS do
    local x = math.random(0, constants.UI.SCREEN_WIDTH - 1)
    local y = math.random(constants.VISUAL.REED_Y_MIN, constants.VISUAL.REED_Y_MAX)
    local h = math.random(constants.VISUAL.REED_HEIGHT_MIN, constants.VISUAL.REED_HEIGHT_MAX)
    local phase = math.random(0, 100) / 100
    local color = math.random(1, 4)
    table.insert(visual.reeds, { x = x, y = y, h = h, phase = phase, color = color })
  end

  -- Initialize stars
  visual.stars = {}
  -- Generate more stars and ensure some near the left edge
  for i = 1, constants.VISUAL.NUM_STARS do
    local x, y
    if i <= 5 then
      -- Guarantee some stars in the left 0-20px region
      x = math.random(0, 20)
      y = math.random(0, constants.VISUAL.STAR_Y_MAX) -- above hills
    else
      x = math.random(0, constants.UI.SCREEN_WIDTH - 1)
      y = math.random(0, constants.VISUAL.STAR_Y_MAX) -- above hills
    end
    local phase = math.random(0, 100) / 100
    local freq = math.random(25, 75) / 100 -- Halved frequency for slower animation
    table.insert(visual.stars, { x = x, y = y, phase = phase, freq = freq })
  end

  -- Initialize lake glints
  visual.glints = {}
  -- Increase number of glints for more reflections
  for i = 1, constants.VISUAL.NUM_GLINTS do
    local x = math.random(0, constants.UI.SCREEN_WIDTH - 1)
    local y = math.random(constants.VISUAL.GLINT_Y_MIN, constants.VISUAL.GLINT_Y_MAX) -- lake surface area
    local len = math.random(constants.VISUAL.GLINT_LENGTH_MIN, constants.VISUAL.GLINT_LENGTH_MAX)
    local phase = math.random(0, 100) / 100
    local freq = math.random(20, 50) / 100
    table.insert(visual.glints, { x = x, y = y, len = len, phase = phase, freq = freq })
  end

  -- Initialize trees on distant hills
  visual.trees = {}
  -- Create more groups of trees
  local num_groups = constants.VISUAL.NUM_TREE_GROUPS
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
  if params:get("wind") ~= nil then
    visual.wind.speed = params:get("wind")
  else
    params:set("wind", 0.3)
    visual.wind.speed = 0.3
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

-- Set weather state
function visual.set_weather_state(state)
  if visual.weather.current_state ~= state then
    if visual.DEBUG then
      print(string.format("Weather changing: %s -> %s", visual.weather.current_state, state))
    end
    visual.weather.current_state = state

    -- Initialize particles for new weather state
    if state == "rainy" then
      visual.init_rain_particles()
    elseif state == "snowy" then
      visual.init_snow_particles()
    end
  end
end

-- Initialize rain particles
function visual.init_rain_particles()
  visual.weather.rain_particles = {}
  for i = 1, constants.VISUAL.NUM_RAIN_PARTICLES do
    table.insert(visual.weather.rain_particles, {
      x = math.random(0, 128),
      y = math.random(-20, 64),
      speed = constants.VISUAL.RAIN_SPEED_MIN + math.random() * (constants.VISUAL.RAIN_SPEED_MAX - constants.VISUAL.RAIN_SPEED_MIN),
      length = constants.VISUAL.RAIN_LENGTH_MIN + math.random() * (constants.VISUAL.RAIN_LENGTH_MAX - constants.VISUAL.RAIN_LENGTH_MIN)
    })
  end
end

-- Initialize snow particles
function visual.init_snow_particles()
  visual.weather.snow_particles = {}
  for i = 1, constants.VISUAL.NUM_SNOW_PARTICLES do
    table.insert(visual.weather.snow_particles, {
      x = math.random(0, 128),
      y = math.random(-20, 64),
      speed = constants.VISUAL.SNOW_SPEED_MIN + math.random() * (constants.VISUAL.SNOW_SPEED_MAX - constants.VISUAL.SNOW_SPEED_MIN),
      drift = math.random() * 0.5 - 0.25,
      size = constants.VISUAL.SNOW_SIZE_MIN + math.random() * (constants.VISUAL.SNOW_SIZE_MAX - constants.VISUAL.SNOW_SIZE_MIN)
    })
  end
end

-- Add functions for other parameters to match engine interface
function visual.set_depth(depth)
  if visual.DEBUG then
    print(string.format("Depth set to: %.2f", depth))
  end
  -- Implement any visual changes based on depth parameter
end

function visual.set_glint(glint)
  if visual.DEBUG then
    print(string.format("Glint set to: %.2f", glint))
  end
  -- Implement any visual changes based on glint parameter
end

-- Draw the stars
function visual.draw_stars(t)
  -- Adjust star visibility based on weather
  local weather_factor = 1.0
  local star_count_factor = 1.0

  if visual.weather.current_state == "cloudy" then
    weather_factor = 0.3    -- Dimmer stars
    star_count_factor = 0.6 -- Fewer visible stars
  elseif visual.weather.current_state == "rainy" then
    weather_factor = 0.1    -- Very dim stars
    star_count_factor = 0.3 -- Very few visible stars
  elseif visual.weather.current_state == "snowy" then
    weather_factor = 0.2    -- Dim stars
    star_count_factor = 0.4 -- Few visible stars
  end

  -- Layer 1: Stars
  for i, s in ipairs(visual.stars) do
    -- Skip some stars based on weather
    if (i / #visual.stars) > star_count_factor then
      goto continue
    end

    -- Fixed base animation, no wind effect for stars
    local base_speed = 0.1
    local alpha = 0.5 + 0.5 * math.sin((t * base_speed) + (s.phase * math.pi * 2))
    local level = math.floor(alpha * 5.0 * weather_factor) -- Apply weather dimming

    if level > 0 then
      screen.level(level)
      -- Make sure stars can be drawn at x=0
      local x = math.max(0.5, math.floor(s.x))
      screen.rect(x, math.floor(s.y), 1, 0) -- Proper rect size for a 1x1 pixel
      screen.stroke()
    end

    ::continue::
  end
end

-- Draw the moon
function visual.draw_moon(t)
  -- Don't draw if moon is off-screen or below horizon
  if not visual.moon.visible then return end
  if visual.moon.altitude < -5 then return end -- Definitely below horizon

  -- Only draw if moon is visible on screen
  local x, y = visual.moon.x, visual.moon.y
  local radius = visual.moon.size / 2

  -- Determine brightness based on altitude
  -- When altitude is near horizon, reduce brightness
  local altitude_brightness = 1.0
  if visual.moon.altitude < 10 and visual.moon.altitude >= 0 then
    -- Moon near horizon (atmospheric extinction)
    altitude_brightness = 0.5 + (visual.moon.altitude / 10) * 0.5
  elseif visual.moon.altitude < 0 and visual.moon.altitude >= -5 then
    -- Moon just below horizon (still partially visible due to atmospheric refraction)
    altitude_brightness = 0.5 * ((visual.moon.altitude + 5) / 5)
  end

  -- Weather effects on moon visibility
  local weather_brightness = 1.0
  if visual.weather.current_state == "cloudy" then
    weather_brightness = 0.4
  elseif visual.weather.current_state == "rainy" then
    weather_brightness = 0.1
  elseif visual.weather.current_state == "snowy" then
    weather_brightness = 0.3
  end

  -- Combine altitude and weather effects
  local total_brightness = altitude_brightness * weather_brightness

  -- Select drawing method based on moon phase
  local phase = visual.moon.phase -- range 0-1

  -- Check for new moon - show very faint outline
  if phase < 0.05 or phase > 0.95 then
    -- New moon - still draw a very faint outline
    local level = math.max(1, math.floor(1 * total_brightness))
    screen.level(level)
    screen.circle(x, y, radius)
    screen.stroke()
  elseif phase > 0.45 and phase < 0.55 then
    -- Near full moon - simple bright circle
    local level = math.max(1, math.floor(15 * total_brightness))
    screen.level(level)
    screen.circle(x, y, radius)
    screen.fill()
  else
    -- For crescent and quarter moons
    local waxing = phase < 0.5 -- Waxing is 0.0-0.5, waning is 0.5-1.0

    -- Normalize moon phase
    local norm_phase
    if waxing then
      norm_phase = phase * 2       -- 0.0-0.5 → 0.0-1.0
    else
      norm_phase = (1 - phase) * 2 -- 0.5-1.0 → 1.0-0.0
    end

    -- Curvature value for crescent shape based on normalized phase
    local curve = math.sin(norm_phase * math.pi / 2) * radius * 1.6

    -- Draw moon outline (circle)
    local level = math.max(1, math.floor(15 * total_brightness))
    screen.level(level)
    screen.circle(x, y, radius)
    screen.fill()

    -- Calculate offset for shadow circle
    local offset_x = waxing and -curve or curve

    -- Draw shadow part using XOR blend mode
    screen.level(0)      -- black
    screen.blend_mode(1) -- XOR mode: erase overlapping parts
    screen.circle(x + offset_x, y, radius * 1.2)
    screen.fill()
    screen.blend_mode(0) -- Reset blend mode
  end

  -- Show time if requested (no moon details)
  if visual.params:get("show_moon_info") == 2 then
    local time_str = os.date("%H:%M")
    local text_width = screen.text_extents(time_str)
    screen.level(15)
    screen.move(128 - text_width - 2, 10)
    screen.text(time_str)
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

      -- Calculate wind sway for trees (much less than reeds)
      local sway = 0
      if visual.wind.speed > 0 then
        -- Trees sway less than reeds due to distance and size
        local tree_wind_factor = 0.3 * visual.wind.speed -- Much less movement than reeds
        local tree_phase = (tree.x + tree.y) * 0.01      -- Unique phase based on position
        local current_time = util.time() - visual.start_time
        local tree_speed = 0.2 * visual.wind.speed       -- Slower movement

        sway = math.sin((current_time * tree_speed) + (tree_phase * math.pi * 2)) * tree_wind_factor
      end

      -- Draw very simple trees, just like reeds but shorter
      if tree.type == 1 then
        -- Straight tree with wind sway
        screen.level(2)
        screen.move(base_x, base_y)
        screen.line(base_x + sway, base_y - tree.height)
        screen.stroke()
      else
        -- Slightly angled tree with wind sway
        screen.level(1)
        local angle = tree.width * 0.3 -- Small angle
        screen.move(base_x, base_y)
        screen.line(base_x + angle + sway, base_y - tree.height)
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
  -- Calculate weather factor for glints (same as stars)
  local weather_factor = 1.0
  local glint_count_factor = 1.0

  if visual.weather.current_state == "cloudy" then
    weather_factor = 0.4     -- Dimmer glints
    glint_count_factor = 0.7 -- Fewer visible glints
  elseif visual.weather.current_state == "rainy" then
    weather_factor = 0.6     -- Moderate glints (rain creates ripples)
    glint_count_factor = 0.8 -- More glints due to rain ripples
  elseif visual.weather.current_state == "snowy" then
    weather_factor = 0.6     -- Same as rainy
    glint_count_factor = 0.8 -- Same as rainy
  end

  -- Layer 6: Lake surface with glints
  for i, g in ipairs(visual.glints) do
    -- Skip some glints based on weather
    if (i / #visual.glints) > glint_count_factor then
      goto continue
    end

    -- No animation if wind is completely off
    if visual.wind.speed <= 0 then
      local base_level = 2 * weather_factor
      screen.level(math.max(1, math.floor(base_level)))
      screen.move(g.x, g.y + 0.5)
      screen.line(g.x + g.len, g.y + 0.5)
      screen.stroke()
    else
      -- Simple animation that scales with wind, using t directly + fixed offset
      local base_speed = 0.2                                            -- Fixed base speed
      local speed = base_speed * visual.wind.speed
      local brightness = (3 + (visual.wind.speed * 4)) * weather_factor -- Apply weather factor

      -- Use time and fixed offset rather than random phase
      local alpha = 0.5 + 0.5 * math.sin((t * speed) + (g.phase * math.pi * 2))
      local level = math.floor(alpha * brightness)

      if level > 0 then
        screen.level(level)
        screen.move(g.x, g.y + 0.5)
        screen.line(g.x + g.len, g.y + 0.5)
        screen.stroke()
      end
    end

    ::continue::
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
    -- Always draw the reflection regardless of altitude
    local reflection_y = 64 - (visual.moon.y - 32)  -- Invert height to position below water
    if reflection_y > 32 and reflection_y < 64 then -- Only if below water surface
      -- Calculate reflection intensity based on moon phase and altitude
      local phase_brightness = 1.0
      if visual.moon.phase < 0.1 or visual.moon.phase > 0.9 then
        -- Near new moon - very dim reflection
        phase_brightness = 0.3
      elseif visual.moon.phase < 0.4 or visual.moon.phase > 0.6 then
        -- Quarter moon - moderate reflection
        phase_brightness = 0.7
      end

      -- Apply weather effects to moon reflection
      local weather_reflection_factor = 1.0
      if visual.weather.current_state == "cloudy" then
        weather_reflection_factor = 0.4
      elseif visual.weather.current_state == "rainy" then
        weather_reflection_factor = 0.7 -- Rain creates more ripples, some reflection visible
      elseif visual.weather.current_state == "snowy" then
        weather_reflection_factor = 0.2
      end

      -- Combine phase and weather effects
      local total_reflection_brightness = phase_brightness * weather_reflection_factor

      -- Draw moon reflection with phase-dependent brightness
      local base_level = 5
      local reflection_level = math.floor(base_level * total_reflection_brightness)
      screen.level(reflection_level > 0 and reflection_level or 1) -- Ensure at least level 1

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

        -- Ripple effect on reflection - multiple ellipses
        local num_ripples = 2 + math.floor(visual.wind.speed * 3)
        for i = 1, num_ripples do
          local ripple_phase = (t * speed + 0.3 * i) % (2 * math.pi)
          local sway = math.sin(ripple_phase) * sway_amount * (i * 0.4)
          local width = (visual.moon.size / 2.5) * (1 - (i - 1) * 0.15)
          local height = (visual.moon.size * stretch / 4) * (1 - (i - 1) * 0.1)

          -- Fade ripples further from center
          local fade = 1 - ((i - 1) / num_ripples) * 0.7
          screen.level(math.floor(reflection_level * fade))

          screen.ellipse(visual.moon.x + sway, reflection_y + (i - 1), width, height)
          screen.fill()
        end
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
  visual.draw_stars(t) -- Layer 1: Stars

  -- Shooting stars only appear in clear weather
  if visual.weather.current_state == "clear" then
    shooting_star.update() -- Check for shooting star generation
    shooting_star.draw()   -- Draw shooting star if active
  end

  visual.draw_moon(t)            -- Layer 2: Moon

  visual.draw_hills()            -- Layers 3-5: Hills and waterline
  visual.draw_trees()            -- Layer 2.5: Trees on distant hills
  visual.draw_lake(t)            -- Layer 6: Lake surface
  visual.draw_reeds(t)           -- Layer 7: Reeds
  visual.draw_moon_reflection(t) -- Layer 8: Moon reflection

  -- Draw weather particles (front layer)
  if visual.weather.current_state == "rainy" then
    visual.update_and_draw_rain(t)
  elseif visual.weather.current_state == "snowy" then
    visual.update_and_draw_snow(t)
  end

  screen.update()
end

return visual
