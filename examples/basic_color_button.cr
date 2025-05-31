require "../src/uing"

UIng.init do
  UIng::Window.new("Color Button", 300, 200) do
    set_child(UIng::ColorButton.new do
      set_color(0.0, 0.5, 0.5, 1.0)
      on_changed do |r, g, b, a|
        p red: r, green: g, blue: b, alpha: a
      end
    end)

    on_closing do
      UIng.quit; true
    end
    show
  end
  UIng.main
end
