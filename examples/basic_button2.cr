require "../src/uing"

UIng.init do
  UIng::Window.new("Hello World", 300, 200) { |win|
    on_closing { UIng.quit; true }
    set_child {
      UIng::Button.new("Click me") {
        on_clicked {
          UIng.msg_box(win, "Information", "You clicked the button")
        }
      }
    }
    show
  }

  UIng.main
end
