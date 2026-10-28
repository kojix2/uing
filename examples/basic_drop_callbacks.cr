require "../src/uing"

UIng.init

window = UIng::Window.new("Drop callbacks", 480, 240, margined: true)
window.on_closing do
  UIng.quit
  true
end

status = UIng::Label.new("Drop files here.")
window.child = status

window.on_drop(accepts: :files) do |event|
  if paths = event.files
    status.text = "Received #{paths.size} paths"
    paths.each { |path| puts path }
    true
  else
    false
  end
end
window.on_drop_over do |info|
  status.text = "Release to drop at (#{info.x.round(1)}, #{info.y.round(1)})"
  true
end
window.on_drop_leave { status.text = "Drop files here." }

window.show

UIng.main
UIng.uninit
