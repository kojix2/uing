require "../../src/uing"

UIng.init

# Improved keyboard API demonstration
# Shows the new convenient methods for key event handling

# Application state
messages = [] of String
current_input = ""

handler = UIng::Area::Handler.new do
  draw { |area, params|
    ctx = params.context

    # Draw background
    bg_brush = UIng::Area::Draw::Brush.new(:solid, 0.95, 0.95, 0.95, 1.0)
    ctx.fill_path(bg_brush) do |path|
      path.add_rectangle(0, 0, 600, 500)
    end

    # Draw title
    title_font = UIng::FontDescriptor.new(
      family: "Arial",
      size: 18,
      weight: :bold,
      italic: :normal,
      stretch: :normal
    )

    title_text = UIng::Area::AttributedString.new("Improved Keyboard API Demo")
    UIng::Area::Draw::TextLayout.open(
      string: title_text,
      default_font: title_font,
      width: 580,
      align: UIng::Area::Draw::TextAlign::Center
    ) do |text_layout|
      ctx.draw_text_layout(text_layout, 10, 10)
    end
    title_text.free

    # Draw instructions
    instruction_font = UIng::FontDescriptor.new(
      family: "Arial",
      size: 12,
      weight: :normal,
      italic: :normal,
      stretch: :normal
    )

    instructions = [
      "Try these key combinations:",
      "• Type any character to see printable detection",
      "• Arrow keys for navigation",
      "• Function keys (F1-F12)",
      "• Ctrl+S, Ctrl+C, Ctrl+V for shortcuts",
      "• Escape to clear messages",
    ]

    y_pos = 50.0
    instructions.each do |instruction|
      inst_text = UIng::Area::AttributedString.new(instruction)
      UIng::Area::Draw::TextLayout.open(
        string: inst_text,
        default_font: instruction_font,
        width: 580,
        align: UIng::Area::Draw::TextAlign::Left
      ) do |text_layout|
        ctx.draw_text_layout(text_layout, 10, y_pos)
      end
      inst_text.free
      y_pos += 20
    end

    # Draw current input
    if !current_input.empty?
      input_bg_brush = UIng::Area::Draw::Brush.new(:solid, 1.0, 1.0, 0.8, 1.0)
      ctx.fill_path(input_bg_brush) do |path|
        path.add_rectangle(10, 180, 580, 30)
      end

      input_text = UIng::Area::AttributedString.new("Current input: #{current_input}")
      UIng::Area::Draw::TextLayout.open(
        string: input_text,
        default_font: instruction_font,
        width: 560,
        align: UIng::Area::Draw::TextAlign::Left
      ) do |text_layout|
        ctx.draw_text_layout(text_layout, 15, 185)
      end
      input_text.free
    end

    # Draw messages
    message_y = 220.0
    messages.last(15).each do |message| # Show last 15 messages
      msg_text = UIng::Area::AttributedString.new(message)
      UIng::Area::Draw::TextLayout.open(
        string: msg_text,
        default_font: instruction_font,
        width: 580,
        align: UIng::Area::Draw::TextAlign::Left
      ) do |text_layout|
        ctx.draw_text_layout(text_layout, 10, message_y)
      end
      msg_text.free
      message_y += 18
    end
  }

  key_event { |area, event|
    if event.pressed? # Only handle key press events
      message = ""

      # Demonstrate the new API methods
      if event.printable?
        # Handle printable characters
        current_input += event.key.to_s
        message = "Printable: '#{event.key}'"

        # Demonstrate case-insensitive character matching
        if event.char?('a', 'e', 'i', 'o', 'u')
          message += " (vowel detected!)"
        end
      elsif event.special_key?
        # Handle special keys
        case event.special_key
        when UIng::Area::ExtKey::Escape
          messages.clear
          current_input = ""
          message = "Escape pressed - cleared all messages"
        when UIng::Area::ExtKey::Backspace
          current_input = current_input[0...-1] if !current_input.empty?
          message = "Backspace pressed"
        when UIng::Area::ExtKey::Enter
          if !current_input.empty?
            messages << "Input submitted: '#{current_input}'"
            current_input = ""
          end
          message = "Enter pressed"
        else
          message = "Special key: #{event.special_key}"
        end

        # Demonstrate arrow key detection
        if event.arrow_key?
          direction = event.arrow_direction
          message += " - Arrow #{direction} detected"
        end

        # Demonstrate function key detection
        if event.function_key?
          fn_num = event.function_key_number
          message += " - Function key F#{fn_num} detected"
        end

        # Demonstrate numpad detection
        if event.numpad_key?
          message += " - Numpad key detected"
        end
      end

      # Demonstrate shortcut detection
      if event.shortcut?(:ctrl, 's')
        message = "Ctrl+S shortcut detected (Save)"
      elsif event.shortcut?(:ctrl, 'c')
        message = "Ctrl+C shortcut detected (Copy)"
      elsif event.shortcut?(:ctrl, 'v')
        message = "Ctrl+V shortcut detected (Paste)"
      elsif event.shortcut?(:ctrl_shift, 'z')
        message = "Ctrl+Shift+Z shortcut detected (Redo)"
      end

      # Add modifier information
      modifiers = [] of String
      modifiers << "Ctrl" if event.ctrl?
      modifiers << "Alt" if event.alt?
      modifiers << "Shift" if event.shift?
      modifiers << "Super" if event.super?

      unless modifiers.empty?
        message += " [#{modifiers.join("+")}]"
      end

      # Add the message to our list
      messages << message if !message.empty?

      # Limit message history
      if messages.size > 50
        messages.shift
      end

      area.queue_redraw_all
    end
    true
  }
end

window = UIng::Window.new("Improved Keyboard API Demo", 600, 500)
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
