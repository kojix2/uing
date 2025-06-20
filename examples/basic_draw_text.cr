require "../src/uing"

UIng.init

handler = UIng::Area::Handler.new
area = UIng::Area.new(handler)

title = "Michael Ende (1929-1995) The Neverending Story"

str1 = \
   "  At last Ygramul sensed that something was coming toward " \
 "her. With the speed of lightning, she turned about, confronting " \
 "Atreyu with an enormous steel-blue face. Her single eye had a " \
 "vertical pupil, which stared at Atreyu with inconceivable malignancy. "

str2 = \
   "  A cry of fear escaped Bastian. "

str3 = \
   "  A cry of terror passed through the ravine and echoed from " \
 "side to side. Ygramul turned her eye to left and right, to see if " \
 "someone else had arrived, for that sound could not have been " \
 "made by the boy who stood there as though paralyzed with " \
 "horror. "

str4 = \
   "  Could she have heard my cry? Bastion wondered in alarm. " \
 "But that's not possible. "

str5 = \
   "  And then Atreyu heard Ygramuls voice. It was very high " \
 "and slightly hoarse, not at all the right kind of voice for that " \
 "enormous face. Her lips did not move as she spoke. It was the " \
 "buzzing of a great swarm of hornets that shaped itself into " \
 "words. "

ATTR_STR = UIng::Area::AttributedString.new("")

RED   = UIng::Area::Attribute.new_color(0.0, 0.5, 0.0, 0.7)
GREEN = UIng::Area::Attribute.new_color(0.5, 0.0, 0.25, 0.7)

def append_to_attr_str(attr_str, text, color)
  start = attr_str.len
  attr_str.append_unattributed(text)
  attr_str.set_attribute(color, start, start + text.size)
  attr_str.append_unattributed("\n\n")
end

append_to_attr_str(ATTR_STR, str1, GREEN)
append_to_attr_str(ATTR_STR, str2, RED)
append_to_attr_str(ATTR_STR, str3, GREEN)
append_to_attr_str(ATTR_STR, str4, RED)
append_to_attr_str(ATTR_STR, str5, GREEN)

handler.draw do |area, area_draw_params|
  default_font = UIng::FontDescriptor.new(
    family: "Georgia",
    size: 13,
    weight: :normal,
    italic: :normal,
    stretch: :normal
  )

  params = UIng::Area::Draw::TextLayout::Params.new
  params.string = ATTR_STR
  params.default_font = default_font
  params.width = area_draw_params.area_width
  params.align = UIng::Area::Draw::TextAlign::Left

  text_layout = UIng::Area::Draw::TextLayout.new(params)
  ctx = area_draw_params.context
  ctx.text(text_layout, 0, 0)
  text_layout.free
end

handler.mouse_event { |_, _| }
handler.mouse_crossed { |_, _| }
handler.drag_broken { |_| }
handler.key_event { |_, _| false }

box = UIng::Box.new(:vertical)
box.padded = true
box.append area, true

main_window = UIng::Window.new(title, 600, 400)
main_window.margined = true
main_window.child = box

main_window.on_closing do
  ATTR_STR.free
  UIng.quit
  true
end
main_window.show

UIng.main
UIng.uninit
