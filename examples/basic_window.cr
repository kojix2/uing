require "../src/uing"

UIng.init do
  UIng::Window.new("Hello", 300, 200) do
    on_closing do
      UIng.quit; true
    end
    show
  end
  UIng.main
end
