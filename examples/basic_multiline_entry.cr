require "../src/uing"

UIng.init

main_window = UIng::Window.new("Notepad", 500, 300, 1)
main_window.on_closing do
  puts "Bye Bye"
  UIng.quit
  1
end

vbox = UIng::Box.new(:vertical)
main_window.set_child(vbox)

entry = UIng::MultilineEntry.new(wrapping: false)
vbox.append(entry, 1)

main_window.show
UIng.main
UIng.uninit
