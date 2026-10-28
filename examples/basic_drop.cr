require "../src/uing"

UIng.init
window = UIng::Window.new("Drop files or text", 520, 320, margined: true)
begin
  box = UIng::Box.new(:vertical)
  status = UIng::Label.new("Drop files or text on the window or the blank area.")
  entry = UIng::Entry.new
  entry.text = "This entry keeps its native text drop behavior."
  area = UIng::Area.new(UIng::Area::Handler.new)
  box.append(status)
  box.append(entry)
  box.append(area, true)
  window.child = box

  handler = UIng::Drop::Handler.new do
    over do |target, info|
      location = target.is_a?(UIng::Area) ? "area" : "window"
      status.text = "#{info.format} on #{location} at (#{info.x.round(1)}, #{info.y.round(1)})"
      true
    end

    leave { |_target| status.text = "Drop files or text here." }

    drop do |_target, event|
      if paths = event.files
        status.text = "Received #{paths.size} paths"
        paths.each { |path| puts path }
      elsif text = event.text
        status.text = text
        puts text
      end
      true
    end
  end

  # The same Handler can be shared. Registered Areas are exclusive drop zones;
  # the Window handles content not claimed by a native child receiver.
  window.drop_handler = handler
  area.drop_handler = handler
  window.on_closing do
    UIng.quit
    true
  end
  window.show
  UIng.main
ensure
  window.destroy unless window.released?
  UIng.uninit
end
