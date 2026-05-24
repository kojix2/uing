require "../src/uing"

UIng.init do
  UIng::Window.new("Hello World", 300, 200) do |win|
    on_closing do
      UIng.quit
      true
    end
    set_child do
      UIng::Button.new("Click me") do
        on_clicked do
          win.msg_box("Information", "You clicked the button")
        end
      end
    end
    show
  end

  UIng.main
end
