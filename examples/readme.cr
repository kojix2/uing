require "../src/uing"

UIng.init do
  Window.new("Hello World", 300, 200) do
    on_closing do
      UIng.quit
      true
    end

    set_child(
      Button.new("Click me") do
        button.on_clicked do
          UIng.msg_box(window, "Info", "Button clicked!")
        end
      end
    )
  end
end
