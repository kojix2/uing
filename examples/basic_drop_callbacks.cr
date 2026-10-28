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

window.show

UIng.main
UIng.uninit
