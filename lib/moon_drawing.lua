-- Function to draw the moon
function draw_moon()
  -- Don't draw if not in debug mode and moon is off-screen
  if not moon.debug_mode and not moon.visible then return end
  
  -- Draw only when moon is visible on screen
  local x, y = moon.x, moon.y
  local radius = MOON_SIZE / 2
  
  -- Draw moon circle
  screen.level(15) -- Brightest white
  screen.circle(x, y, radius)
  
  -- Draw moon phases based on phase
  if moon.phase < 0.5 then
    -- From first quarter to full moon
    screen.fill()
    screen.level(0) -- Black
    
    -- Draw shadow part
    local phase_angle = (0.5 - moon.phase) * math.pi
    local offset = math.cos(phase_angle) * radius
    
    -- Use circle hit detection to show shadow part
    for yy = y - radius, y + radius do
      for xx = x - radius, x + offset do
        if ((xx - x) * (xx - x) + (yy - y) * (yy - y)) <= (radius * radius) then
          screen.pixel(xx, yy)
          screen.fill()
        end
      end
    end
  else
    -- From full moon to last quarter
    screen.fill()
    screen.level(0) -- Black
    
    -- Draw shadow part
    local phase_angle = (moon.phase - 0.5) * math.pi
    local offset = math.cos(phase_angle) * radius
    
    -- Use circle hit detection to show shadow part
    for yy = y - radius, y + radius do
      for xx = x + offset, x + radius do
        if ((xx - x) * (xx - x) + (yy - y) * (yy - y)) <= (radius * radius) then
          screen.pixel(xx, yy)
          screen.fill()
        end
      end
    end
  end
  
  -- Display moon information
  if params:get("show_moon_info") == 2 or moon.debug_mode then
    screen.move(2, 10)
    screen.level(15)
    screen.text(string.format("Phase: %.2f", moon.phase))
    screen.move(2, 18)
    screen.text(string.format("Az: %.1f", moon.azimuth))
    screen.move(2, 26)
    screen.text(string.format("Alt: %.1f", moon.altitude))
    
    -- Display DEBUG if in debug mode
    if moon.debug_mode then
      screen.level(10)
      screen.move(80, 10)
      screen.text("DEBUG")
    end
  end
end