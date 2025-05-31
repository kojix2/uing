require "../src/uing"

UIng.init

window = UIng::Window.new("Basic Entry", 300, 50) do
  on_closing do
    UIng.quit; true
  end
  show
end

box = UIng::Box.new(:horizontal) do
  entry = UIng::Entry.new(:password) do
    on_changed do |text|
      puts text
    end
  end
  append(entry, stretchy: true)

  button = UIng::Button.new("Button") do
    on_clicked do
      text = UIng.entry_text(entry) || ""
      UIng.msg_box(window, "You entered", text)
      UIng.free_text(text)
    end
  end
  append(button)
end
window.child = box

UIng.main
UIng.uninit
