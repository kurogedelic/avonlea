-- debug_avonlea.lua
-- Avonleaエンジンのデバッグ用スクリプト

engine.name = "Avonlea"

function init()
  print("Avonlea engine debug script")
  
  -- 短い待機時間を設定
  clock.run(function()
    print("Testing commands in 2 seconds...")
    clock.sleep(2)
    
    -- 各コマンドをテスト
    print("\nTesting 'set' command:")
    if type(engine.set) == "function" then
      print("engine.set exists!")
      engine.set("gain", 0.8)
      print("engine.set called with gain=0.8")
    else
      print("ERROR: engine.set is NOT available")
    end
    
    print("\nTesting 'moon' command:")
    if type(engine.moon) == "function" then
      print("engine.moon exists!")
      engine.moon(0.8, 45)
      print("engine.moon called with phase=0.8, altitude=45")
    else
      print("ERROR: engine.moon is NOT available")
    end
    
    print("\nTesting 'wind' command:")
    if type(engine.wind) == "function" then
      print("engine.wind exists!")
      engine.wind(0.7)
      print("engine.wind called with speed=0.7")
    else
      print("ERROR: engine.wind is NOT available")
    end
    
    -- 音を出す
    print("\nSetting parameters:")
    if type(engine.set) == "function" then
      engine.set("depthMorph", 0.6)
      engine.set("weightMorph", 0.8)
      print("Parameters set")
    end
  end)
end

function key(n, z)
  if n == 3 and z == 1 then
    -- Key 3で風を変える
    if type(engine.wind) == "function" then
      print("Changing wind speed to 0.9")
      engine.wind(0.9)
    else
      print("Cannot change wind - command not available")
    end
  elseif n == 2 and z == 1 then
    -- Key 2で月相を変える
    if type(engine.moon) == "function" then
      print("Changing moon phase to 1.0 (full moon)")
      engine.moon(1.0, 60)
    else
      print("Cannot change moon - command not available")
    end
  end
end

-- キーを離した時に元に戻す
function key(n, z)
  if n == 3 and z == 0 then
    if type(engine.wind) == "function" then
      engine.wind(0.5)
    end
  elseif n == 2 and z == 0 then
    if type(engine.moon) == "function" then
      engine.moon(0.5, 30)
    end
  end
end
