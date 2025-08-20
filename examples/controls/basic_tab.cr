require "../../src/uing"

UIng.init

window = UIng::Window.new("Tab Example", 300, 200, margined: true)
window.on_closing do
  UIng.quit
  true
end

tab = UIng::Tab.new
tab.append("Tab 1", UIng::Label.new("This is Tab 1"))
tab.append("Tab 2", UIng::Label.new("This is Tab 2"))
tab.on_selected do |idx|
  UIng.msg_box(window, "Tab Changed", "Selected index: #{idx}")
end

window.child = tab
window.show

UIng.main
UIng.uninit
