-- minimal_test.lua
-- Minimal engine test

engine.name = "TestSine"

function init()
  print("Testing minimal engine...")
  
  -- Test commands
  if type(engine.hz) == "function" then
    print("engine.hz is available")
    engine.hz(440)
  else
    print("ERROR: engine.hz is NOT available")
  end
  
  if type(engine.amp) == "function" then
    print("engine.amp is available")
    engine.amp(0.5)
  else
    print("ERROR: engine.amp is NOT available")
  end
end
