-- 月を描画する関数
function draw_moon()
  -- デバッグモードでなく、月が画面外なら描画しない
  if not moon.debug_mode and not moon.visible then return end
  
  -- 月が画面上に見える場合のみ描画
  local x, y = moon.x, moon.y
  local radius = MOON_SIZE / 2
  
  -- 月の円を描画
  screen.level(15) -- 最も明るい白
  screen.circle(x, y, radius)
  
  -- 月相に応じた満ち欠けを描画
  if moon.phase < 0.5 then
    -- 上弦から満月まで
    screen.fill()
    screen.level(0) -- 黒
    
    -- 影の部分を描画
    local phase_angle = (0.5 - moon.phase) * math.pi
    local offset = math.cos(phase_angle) * radius
    
    -- 円当たり判定で影の部分を表示
    for yy = y - radius, y + radius do
      for xx = x - radius, x + offset do
        if ((xx - x) * (xx - x) + (yy - y) * (yy - y)) <= (radius * radius) then
          screen.pixel(xx, yy)
          screen.fill()
        end
      end
    end
  else
    -- 満月から下弦まで
    screen.fill()
    screen.level(0) -- 黒
    
    -- 影の部分を描画
    local phase_angle = (moon.phase - 0.5) * math.pi
    local offset = math.cos(phase_angle) * radius
    
    -- 円当たり判定で影の部分を表示
    for yy = y - radius, y + radius do
      for xx = x + offset, x + radius do
        if ((xx - x) * (xx - x) + (yy - y) * (yy - y)) <= (radius * radius) then
          screen.pixel(xx, yy)
          screen.fill()
        end
      end
    end
  end
  
  -- 月の情報を表示
  if params:get("show_moon_info") == 2 or moon.debug_mode then
    screen.move(2, 10)
    screen.level(15)
    screen.text(string.format("Phase: %.2f", moon.phase))
    screen.move(2, 18)
    screen.text(string.format("Az: %.1f", moon.azimuth))
    screen.move(2, 26)
    screen.text(string.format("Alt: %.1f", moon.altitude))
    
    -- デバッグモードの場合はその旨を表示
    if moon.debug_mode then
      screen.level(10)
      screen.move(80, 10)
      screen.text("DEBUG")
    end
  end
end