require "../src/uing"

UIng.init do
  UIng::Window.new("Hello", 300, 200) do
    on_closing do
      UIng.quit; true
    end
    on_position_changed do |a, b|
      p "x: #{a}, y: #{b}"
    end
    on_content_size_changed do |w, h|
      p "width: #{w}, height: #{h}"
    end
    on_focus_changed do |focused|
      p "focused: #{focused}"
    end
    show
  end
  UIng.main
end
