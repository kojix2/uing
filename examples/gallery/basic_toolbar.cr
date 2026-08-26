require "../../src/uing"

alias Color = Tuple(UInt8, UInt8, UInt8, UInt8)

def paint(pixels : Bytes, size : Int32, x : Int32, y : Int32, color : Color) : Nil
  return unless 0 <= x < size && 0 <= y < size
  offset = (y * size + x) * 4
  pixels[offset], pixels[offset + 1], pixels[offset + 2], pixels[offset + 3] = color
end

def fill_rect(pixels : Bytes, size : Int32, x0 : Int32, y0 : Int32,
              width : Int32, height : Int32, color : Color) : Nil
  y0.upto(y0 + height - 1) do |y|
    x0.upto(x0 + width - 1) { |x| paint(pixels, size, x, y, color) }
  end
end

def icon_pixels(size : Int32, color : Color, symbol : Symbol) : Bytes
  pixels = Bytes.new(size * size * 4, 0_u8)
  margin = Math.max(1, size // 16)
  white = {255_u8, 255_u8, 255_u8, 255_u8}

  fill_rect(pixels, size, margin, margin, size - margin * 2, size - margin * 2, color)

  stroke = Math.max(2, size // 8)
  middle = (size - stroke) // 2
  inner = size // 5
  span = size - inner * 2

  case symbol
  when :new
    fill_rect(pixels, size, middle, inner, stroke, span, white)
    fill_rect(pixels, size, inner, middle, span, stroke, white)
  when :open
    # A centered down arrow entering a tray.
    arrow_height = size // 5
    fill_rect(pixels, size, middle, inner, stroke, size // 3, white)
    arrow_height.times do |row|
      width = stroke + (arrow_height - row - 1) * 2
      fill_rect(pixels, size, (size - width) // 2, size // 2 + row, width, 1, white)
    end
    fill_rect(pixels, size, inner, size - inner - stroke, span, stroke, white)
  when :pin
    # A pushpin mirrored around its vertical axis.
    fill_rect(pixels, size, inner, inner, span, stroke, white)
    body_width = stroke * 2
    fill_rect(pixels, size, (size - body_width) // 2, inner + stroke, body_width, size // 4, white)
    fill_rect(pixels, size, inner, size // 2, span, stroke, white)
    fill_rect(pixels, size, middle, size // 2 + stroke, stroke, size // 4, white)
  when :help
    # A centered information mark keeps the help icon simple and symmetric.
    fill_rect(pixels, size, middle, inner, stroke, stroke, white)
    fill_rect(pixels, size, middle, inner + stroke * 2, stroke, size // 3, white)
  end
  pixels
end

def new_icon(color : Color, symbol : Symbol) : UIng::Image
  image = UIng::Image.new(16, 16)
  {16, 32}.each do |size|
    pixels = icon_pixels(size, color, symbol)
    image.append(pixels, size, size, size * 4)
  end
  image
end

UIng.init

window = UIng::Window.new("Toolbar", 640, 400)
window.set_child(UIng::Label.new("Resize the window to see the flexible space."))

icons = [
  new_icon({72_u8, 140_u8, 210_u8, 255_u8}, :new),
  new_icon({78_u8, 170_u8, 110_u8, 255_u8}, :open),
  new_icon({225_u8, 145_u8, 55_u8, 255_u8}, :pin),
  new_icon({145_u8, 105_u8, 190_u8, 255_u8}, :help),
]

toolbar = UIng::Toolbar.new

new_item = toolbar.append_button("New", icons[0])
new_item.tooltip = "New document"
new_item.on_clicked { puts "New clicked" }

open_item = toolbar.append_button("Open", icons[1])
open_item.tooltip = "Open document"
open_item.on_clicked { puts "Open clicked" }

toolbar.append_separator
pinned_item = toolbar.append_toggle_button("Pinned", icons[2])
pinned_item.tooltip = "Pin document"
pinned_item.on_clicked { |item| puts "Pinned: #{item.checked? ? "yes" : "no"}" }

toolbar.append_flexible_space
help_item = toolbar.append_button("Help", icons[3])
help_item.tooltip = "Show help"
help_item.on_clicked { puts "Help clicked" }

window.toolbar = toolbar
window.on_closing do
  window.toolbar = nil
  toolbar.free
  icons.each &.free
  UIng.quit
  true
end

window.show
UIng.main
UIng.uninit
