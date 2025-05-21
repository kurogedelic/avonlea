-- test_avonlea_engine.lua
-- Simple test script for Avonlea engine

engine.name = "Avonlea"

function init()
  print("Testing Avonlea engine commands...")
  
  -- Check if moon command is available
  if type(engine.moon) == "function" then
    print("engine.moon is available")
    engine.moon(0.5, 30)
    print("engine.moon called with phase=0.5, altitude=30")
  else
    print("ERROR: engine.moon is NOT available")
  end
  
  -- Check if wind command is available
  if type(engine.wind) == "function" then
    print("engine.wind is available")
    engine.wind(0.5)
    print("engine.wind called with speed=0.5")
  else
    print("ERROR: engine.wind is NOT available")
  end
  
  -- Check if set command is available
  if type(engine.set) == "function" then
    print("engine.set is available")
    engine.set("depthMorph", 0.4)
    print("engine.set called with depthMorph=0.4")
  else
    print("ERROR: engine.set is NOT available")
  end
  
  -- Wait and check again after a delay
  clock.run(function()
    print("\nChecking again after delay...")
    clock.sleep(1)
    
    if type(engine.moon) == "function" then
      print("After delay: engine.moon is available")
    else
      print("After delay: engine.moon is still NOT available")
    end
    
    if type(engine.wind) == "function" then
      print("After delay: engine.wind is available")
    else
      print("After delay: engine.wind is still NOT available")
    end
  end)
end
