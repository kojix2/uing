require "../src/uing"

UIng.init

main_window = UIng::Window.new("Notepad", 500, 300)
main_window.on_closing do
  puts "Bye Bye"
  UIng.quit
  true
end

vbox = UIng::Box.new(:vertical)
main_window.child = vbox

entry = UIng::MultilineEntry.new(wrapping: false)
vbox.append entry, true

main_window.show
UIng.main
UIng.uninit
