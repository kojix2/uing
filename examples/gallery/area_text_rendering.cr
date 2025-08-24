require "../../src/uing"

UIng.init

# Text rendering example
# Demonstrates: Text layout, fonts, colors, alignment

handler = UIng::Area::Handler.new do
  draw { |area, params|
    ctx = params.context

    # Draw background
    bg_brush = UIng::Area::Draw::Brush.new(:solid, 0.98, 0.98, 0.98, 1.0)
    ctx.fill_path(bg_brush) do |path|
      path.add_rectangle(0, 0, params.area_width, params.area_height)
    end

    # Example 1: Simple text with default font
    simple_text = UIng::Area::AttributedString.new("Hello, World!")
    default_font = UIng::FontDescriptor.new(
      family: "Arial",
      size: 16,
      weight: :normal,
      italic: :normal,
      stretch: :normal
    )

    UIng::Area::Draw::TextLayout.open(
      string: simple_text,
      default_font: default_font,
      width: params.area_width - 20,
      align: UIng::Area::Draw::TextAlign::Left
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 10, 10)
    end

    # Example 2: Colored text
    colored_text = UIng::Area::AttributedString.new("")
    colored_text.append_unattributed("This is ")

    # Add red text
    red_start = colored_text.len
    colored_text.append_unattributed("red")
    red_color = UIng::Area::Attribute.new_color(0.8, 0.2, 0.2, 1.0)
    colored_text.set_attribute(red_color, red_start, colored_text.len)

    colored_text.append_unattributed(" and this is ")

    # Add blue text
    blue_start = colored_text.len
    colored_text.append_unattributed("blue")
    blue_color = UIng::Area::Attribute.new_color(0.2, 0.2, 0.8, 1.0)
    colored_text.set_attribute(blue_color, blue_start, colored_text.len)

    colored_text.append_unattributed(" text!")

    UIng::Area::Draw::TextLayout.open(
      string: colored_text,
      default_font: default_font,
      width: params.area_width - 20,
      align: UIng::Area::Draw::TextAlign::Left
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 10, 50)
    end

    # Example 3: Different font sizes
    large_font = UIng::FontDescriptor.new(
      family: "Arial",
      size: 24,
      weight: :bold,
      italic: :normal,
      stretch: :normal
    )

    large_text = UIng::Area::AttributedString.new("Large Bold Text")
    UIng::Area::Draw::TextLayout.open(
      string: large_text,
      default_font: large_font,
      width: params.area_width - 20,
      align: UIng::Area::Draw::TextAlign::Left
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 10, 90)
    end

    # Example 4: Italic text
    italic_font = UIng::FontDescriptor.new(
      family: "Arial",
      size: 14,
      weight: :normal,
      italic: :italic,
      stretch: :normal
    )

    italic_text = UIng::Area::AttributedString.new("This text is italic")
    UIng::Area::Draw::TextLayout.open(
      string: italic_text,
      default_font: italic_font,
      width: params.area_width - 20,
      align: UIng::Area::Draw::TextAlign::Left
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 10, 130)
    end

    # Example 5: Center aligned text
    center_text = UIng::Area::AttributedString.new("This text is center aligned")
    UIng::Area::Draw::TextLayout.open(
      string: center_text,
      default_font: default_font,
      width: params.area_width - 20,
      align: UIng::Area::Draw::TextAlign::Center
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 10, 170)
    end

    # Example 6: Right aligned text
    right_text = UIng::Area::AttributedString.new("This text is right aligned")
    UIng::Area::Draw::TextLayout.open(
      string: right_text,
      default_font: default_font,
      width: params.area_width - 20,
      align: UIng::Area::Draw::TextAlign::Right
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 10, 210)
    end

    # Example 7: Multi-line text with word wrapping
    long_text = UIng::Area::AttributedString.new(
      "This is a longer text that demonstrates word wrapping. " \
      "When the text is too long to fit on a single line, it will " \
      "automatically wrap to the next line. This is very useful for " \
      "displaying paragraphs of text in your applications."
    )

    UIng::Area::Draw::TextLayout.open(
      string: long_text,
      default_font: default_font,
      width: params.area_width - 20,
      align: UIng::Area::Draw::TextAlign::Left
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 10, 250)
    end

    # Clean up attributed strings
    simple_text.free
    colored_text.free
    large_text.free
    italic_text.free
    center_text.free
    right_text.free
    long_text.free
  }
end

window = UIng::Window.new("Area - Text Rendering", 500, 400)
window.on_closing do
  UIng.quit
  true
end

area = UIng::Area.new(handler)
box = UIng::Box.new(:vertical, padded: true)
box.append(area, stretchy: true)
window.child = box

window.show

UIng.main
UIng.uninit
