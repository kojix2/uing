require "../../src/uing"
require "./config"
require "./log"
require "./math"
require "./pieces"
require "./game"
require "./renderer"
require "./input"
require "./audio"

# ---- Application wiring ----------------------------------------------------
# Everything below is UI setup: initialize libui, connect callbacks, put the
# Area inside a stretchy Box, then start the timer-driven game loop.

AirHockey3DLog.info("starting")
AirHockey3DLog.log_environment

begin
  AirHockey3DLog.info("calling UIng.init")
  UIng.init
  AirHockey3DLog.info("UIng.init succeeded")
rescue e
  AirHockey3DLog.exception("UIng.init", e)
  raise e
end

game = AirHockey3DGame.new
renderer = AirHockey3DRenderer.new(game)
audio = AirHockey3DAudio.start
handler = UIng::Area::Handler.new
shutting_down = false
AirHockey3DLog.info("game objects created")

handler.draw do |_area, params|
  AirHockey3DLog.log_first_draw(params.area_width, params.area_height)
  renderer.draw(params)
end

handler.mouse_event do |area, event|
  AirHockey3DLog.info("mouse event: x=#{event.x}, y=#{event.y}, down=#{event.down}, up=#{event.up}") if event.down != 0 || event.up != 0
  game.handle_mouse(event.x, event.y)
  if event.down != 0
    AirHockey3DLog.info("serve requested by mouse")
    game.serve
  end
  area.queue_redraw_all unless shutting_down || area.released?
  true
end

handler.key_event do |area, event|
  if event.up == 0
    AirHockey3DLog.info("key event: key=#{event.key.inspect}, ext_key=#{event.ext_key}")
    handle_air_hockey_key(game, event)
  end
  area.queue_redraw_all unless shutting_down || area.released?
  true
end

area = UIng::Area.new(handler)
AirHockey3DLog.info("area created")

# Area needs a stretchy container so libui assigns it drawable content size.
vbox = UIng::Box.new(:vertical, padded: false)
vbox.append(area, stretchy: true)
AirHockey3DLog.info("layout box created")

window = UIng::Window.new("Air Hockey 3D", game.screen_width.to_i, game.screen_height.to_i) do
  on_closing do
    AirHockey3DLog.info("window closing")
    shutting_down = true
    UIng.quit
    true
  end
  on_content_size_changed do |width, height|
    AirHockey3DLog.info("window content size changed: #{width}x#{height}")
  end
  set_child(vbox)
  AirHockey3DLog.info("window child set")
  show
end
AirHockey3DLog.info("window created and shown, content_size=#{window.content_size}")

UIng.timer(AirHockey3DConfig::TICK_MS) do
  next 0 if shutting_down || area.released?

  AirHockey3DLog.tick
  game.update
  game.drain_sound_events.each { |event| audio.play(event) }
  area.queue_redraw_all unless area.released?
  1
end
AirHockey3DLog.info("timer registered")

begin
  AirHockey3DLog.info("entering UIng.main")
  UIng.main
  AirHockey3DLog.info("UIng.main returned")
rescue e
  AirHockey3DLog.exception("UIng.main", e)
  raise e
ensure
  AirHockey3DLog.info("closing audio")
  audio.close
  AirHockey3DLog.info("calling UIng.uninit")
  UIng.uninit
  AirHockey3DLog.info("stopped")
end
