require "../src/uing"

UIng.init do
  UIng::Window.new("Hello", 300, 200) do
    on_closing do
      UIng.quit; true
    end
    on_position_changed do |x, y|
      puts "x: #{x}, y: #{y}"
    end
    on_content_size_changed do |width, height|
      puts "width: #{width}, height: #{height}"
    end
    on_focus_changed do |focused|
      puts "focused: #{focused}"
    end
    show
  end
  UIng.main
end
