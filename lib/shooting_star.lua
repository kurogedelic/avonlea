-- shooting_star.lua
-- Module for handling shooting stars in the Avonlea sky

local shooting_star = {}

-- Shooting star settings
shooting_star.config = {
  active = false,   -- Is a shooting star currently active
  x = 0,            -- Current X position
  y = 0,            -- Current Y position
  dx = 0,           -- X movement per frame
  dy = 0,           -- Y movement per frame
  length = 0,       -- Length of the trail
  brightness = 0,   -- Brightness (1-15)
  lifetime = 0,     -- How long it lasts (frames)
  current_life = 0, -- Current lifetime counter
  chance = 0.003    -- Chance of appearing each frame (0.003 = rare)
}

-- Initialize a new shooting star
function shooting_star.init()
  shooting_star.config.active = true
  shooting_star.config.current_life = 0

  -- Set random position at the top-right area of the screen
  shooting_star.config.x = math.random(70, 120) -- Right side of screen
  shooting_star.config.y = math.random(0, 15)   -- Top of screen

  -- Set random direction (right-top to left-bottom)
  local angle = math.rad(math.random(120, 150)) -- Angle for top-right to bottom-left
  local speed = math.random(15, 25) / 10        -- Speed between 1.5-2.5 pixels per frame

  shooting_star.config.dx = math.cos(angle) * speed
  shooting_star.config.dy = math.sin(angle) * speed

  -- Set random properties
  shooting_star.config.length = math.random(4, 10)
  shooting_star.config.brightness = math.random(8, 15)
  shooting_star.config.lifetime = math.random(15, 30) -- Last for 15-30 frames
end

-- Draw the shooting star
function shooting_star.draw()
  if not shooting_star.config.active then return end

  -- Update position
  shooting_star.config.x = shooting_star.config.x + shooting_star.config.dx
  shooting_star.config.y = shooting_star.config.y + shooting_star.config.dy
  shooting_star.config.current_life = shooting_star.config.current_life + 1

  -- Calculate fade based on lifetime
  local fade = 1 - (shooting_star.config.current_life / shooting_star.config.lifetime)
  local brightness = math.floor(shooting_star.config.brightness * fade)

  -- Draw the shooting star and its trail
  screen.level(brightness)

  -- Head of the star
  screen.rect(shooting_star.config.x, shooting_star.config.y, 1, 0)
  screen.stroke()

  -- Trail
  for i = 1, shooting_star.config.length do
    local trail_x = shooting_star.config.x - (shooting_star.config.dx * i * 0.9)
    local trail_y = shooting_star.config.y - (shooting_star.config.dy * i * 0.9)
    local trail_brightness = brightness * (1 - (i / shooting_star.config.length))

    if trail_brightness > 0 then
      screen.level(math.floor(trail_brightness))
      screen.rect(trail_x, trail_y, 1, 0)
      screen.stroke()
    end
  end

  -- Check if shooting star should be deactivated
  if shooting_star.config.current_life >= shooting_star.config.lifetime or
      shooting_star.config.x < 0 or shooting_star.config.x > 128 or
      shooting_star.config.y < 0 or shooting_star.config.y > 32 then
    shooting_star.config.active = false
  end
end

-- Check for random shooting star generation
function shooting_star.update()
  -- Random chance to create a new shooting star if none is active
  if not shooting_star.config.active and math.random() < shooting_star.config.chance then
    shooting_star.init()
  end
end

return shooting_star
