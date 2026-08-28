require "../../src/uing"
require "base64"
require "compress/zlib"

NEW_ICON = "eNpjYKAcePRc+k8OprV+GBgp+okFtNI/0sN/oNL/KBi4MoxacTdq/9CyH1eZOGr/qP2j9g99+6kNRu0fWvaP5r9R+0ftH7V/tP07MuwfqQAAcYgRdg=="
OPEN_ICON = "eNrtlsENACEIBK3wSrnCbNJ73dOosIQQZxKfm0EhxNb8PP0dlhOd/yF/lp9x4l9lI+rfJSqfNf+Qt8NUvcNfy7+z3/Djx4+/ut+K8v5Kt/X9VW5P/xVu7/x53RXmXw3+Wn7+v3f5b+UD4HmCow=="
PIN_ICON = "eNrtlksOABAMRN3KOR3RSdjaiKLU503S5XjBZHBuXjH4NDLafqlW+cupeaT7t/CfdH7leqP5ud0vzT+y6zCtu4N/Fl9b8O/itzpdytHOP3z4O/j0D/3Xk8Pd7z98+PDt+K/9/39VBiV4ujY="
HELP_ICON = "eNpjYKAcTMzc958cTGv9MDBQ+ke6/4e6/oGOP2L1j4KBK8OoFXej9g8t+9HBqP0jy/7R/Dea/0fz36j9o/aP2j9a/43WP6P2D237RyoAAGYovgE="


def decode_icon(data : String) : Bytes
  compressed = Base64.decode(data)
  io = IO::Memory.new(compressed)

  Compress::Zlib::Reader.open(io) do |zlib|
    zlib.getb_to_end
  end
end

def new_icon(data : String) : UIng::Image
  pixels = decode_icon(data)

  image = UIng::Image.new(16, 16)
  image.append(pixels[0, 1024], 16, 16, 64)
  image.append(pixels[1024, 4096], 32, 32, 128)
  image
end

UIng.init

icons = [
  new_icon(NEW_ICON),
  new_icon(OPEN_ICON),
  new_icon(PIN_ICON),
  new_icon(HELP_ICON),
]

window = UIng::Window.new("Toolbar", 400, 100)
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
