-- shooting_star.lua
-- Module for handling shooting stars in the Avonlea sky

local shooting_star = {}
local constants = include("lib/constants")

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
  chance = constants.VISUAL.SHOOTING_STAR_CHANCE
}

-- Initialize a new shooting star
function shooting_star.init()
  shooting_star.config.active = true
  shooting_star.config.current_life = 0

  -- Set starting position at the top area of the screen
  shooting_star.config.x = math.random(30, 70)   -- Center-left area
  shooting_star.config.y = math.random(2, 8)     -- Near top of screen

  -- Calculate direction for 120 degrees (southwest direction)
  -- 120 degrees = southwest, pointing down and left
  local angle_rad = math.rad(constants.VISUAL.SHOOTING_STAR_ANGLE)  -- Convert degrees to radians
  local speed = (constants.VISUAL.SHOOTING_STAR_SPEED_MIN + math.random() * (constants.VISUAL.SHOOTING_STAR_SPEED_MAX - constants.VISUAL.SHOOTING_STAR_SPEED_MIN))
  
  shooting_star.config.dx = math.cos(angle_rad) * speed  -- X component (negative = leftward)
  shooting_star.config.dy = math.sin(angle_rad) * speed  -- Y component (positive = downward)

  -- Calculate lifetime based on screen bounds
  -- Estimate when it will exit the screen
  local frames_to_left_edge = (shooting_star.config.x - 0) / math.abs(shooting_star.config.dx)
  local frames_to_bottom = (30 - shooting_star.config.y) / math.abs(shooting_star.config.dy)
  shooting_star.config.lifetime = math.floor(math.min(frames_to_left_edge, frames_to_bottom) * 0.9)

  -- Debug info
  print(string.format("New shooting star: Start(%.1f, %.1f) Angle=%d° Direction(%.2f, %.2f)", 
        shooting_star.config.x, shooting_star.config.y, 
        constants.VISUAL.SHOOTING_STAR_ANGLE, shooting_star.config.dx, shooting_star.config.dy))

  -- Set random properties
  shooting_star.config.length = constants.VISUAL.SHOOTING_STAR_LENGTH_MIN + math.random(constants.VISUAL.SHOOTING_STAR_LENGTH_MAX - constants.VISUAL.SHOOTING_STAR_LENGTH_MIN)
  shooting_star.config.brightness = constants.VISUAL.SHOOTING_STAR_BRIGHTNESS_MIN + math.random(constants.VISUAL.SHOOTING_STAR_BRIGHTNESS_MAX - constants.VISUAL.SHOOTING_STAR_BRIGHTNESS_MIN)
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
     shooting_star.config.x < 5 or shooting_star.config.y > 35 then
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
