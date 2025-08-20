require "../../src/uing"

UIng.init

window = UIng::Window.new("Spinbox Example", 300, 100, margined: true)
window.on_closing do
  UIng.quit
  true
end

spinbox = UIng::Spinbox.new(0, 100, value: 42) do
  on_changed do |v|
    UIng.msg_box(window, "Spinbox Changed", "Value: #{v}")
  end
end

window.child = spinbox
window.show

UIng.main
UIng.uninit
