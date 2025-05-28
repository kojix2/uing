require "../src/uing"

UIng.init

handler = UIng::AreaHandler.new
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

ATTR_STR = UIng::AttributedString.new("")

RED   = UIng.new_color_attribute(0.0, 0.5, 0.0, 0.7)
GREEN = UIng.new_color_attribute(0.5, 0.0, 0.25, 0.7)

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

handler.draw do |_, _, adp|
  area_draw_params = UIng::AreaDrawParams.new(adp)
  default_font = UIng::FontDescriptor.new
  default_font.family = "Georgia"
  default_font.size = 13
  default_font.weight = UIng::TextWeight::Normal
  default_font.italic = UIng::TextItalic::Normal
  default_font.stretch = UIng::TextStretch::Normal

  params = UIng::DrawTextLayoutParams.new
  params.string = ATTR_STR
  params.default_font = default_font
  params.width = area_draw_params.area_width
  params.align = UIng::DrawTextAlign::Left

  text_layout = UIng.draw_new_text_layout(params)
  UIng.draw_text(area_draw_params.context, text_layout, 0, 0)
  UIng.draw_free_text_layout(text_layout)
end

handler.mouse_event { |_, _, _| }
handler.mouse_crossed { |_, _, _| }
handler.drag_broken { |_, _| }
handler.key_event { |_, _, _| 0 }

box = UIng::Box.new(:vertical)
box.padded = true
box.append area, true

main_window = UIng::Window.new(title, 600, 400)
main_window.margined = true
main_window.child = box

main_window.on_closing do
  UIng.free_attributed_string(ATTR_STR)
  UIng.quit
  1
end
main_window.show

UIng.main
UIng.uninit
