require "../spec_helper"

private def pointer_is_unavailable?(control : UIng::Control) : Bool
  control.to_unsafe
  false
rescue
  true
end

private def native_call_cell_value(
  handler : UIng::Table::Model::Handler,
  column : Int32,
) : Pointer(UIng::LibUI::TableValue)
  handler_ptr = handler.to_unsafe
  handler_ptr.value.cell_value.call(
    handler_ptr,
    Pointer(UIng::LibUI::TableModel).null,
    0,
    column
  )
end

private def new_native_table_value(type : UIng::Table::Value::Type) : UIng::Table::Value
  case type
  when .string?
    UIng::Table::Value.new("value")
  when .image?
    ptr = UIng::LibUI.new_table_value_image(Pointer(UIng::LibUI::Image).null)
    UIng::Table::Value.new(ptr, borrowed: false)
  when .int?
    UIng::Table::Value.new(1)
  when .color?
    UIng::Table::Value.new_color(0.1, 0.2, 0.3, 1.0)
  else
    raise "unsupported table value type: #{type}"
  end
end

private def verify_native_table_value(
  value_ptr : Pointer(UIng::LibUI::TableValue),
  expected_type : UIng::Table::Value::Type,
) : Nil
  value_ptr.null?.should be_false
  UIng::LibUI.table_value_get_type(value_ptr).should eq(expected_type)
ensure
  UIng::LibUI.free_table_value(value_ptr) unless value_ptr.null?
end

private def verify_native_table_fallback(
  value_ptr : Pointer(UIng::LibUI::TableValue),
  expected_type : UIng::Table::Value::Type,
) : Nil
  if expected_type.color?
    value_ptr.null?.should be_true
  else
    verify_native_table_value(value_ptr, expected_type)
  end
end

# Native GUI specs are deliberately opt-in. The normal suite must remain usable
# without a display, while CI runs this directory inside a real platform event
# loop (and Xvfb on Linux).
if ENV["UING_NATIVE_GUI_TESTS"]? == "1"
  describe "native GUI lifecycle" do
    before_all { UIng.init }
    after_each { UIng.on_error(nil) }
    after_all { UIng.uninit }

    it "uses a type-correct fallback for every table column after callback failure" do
      types = UIng::Table::Value::Type.values
      errors = [] of Exception
      handler = UIng::Table::Model::Handler.new
      handler.num_columns { types.size }
      handler.column_type { |column| types[column] }
      handler.cell_value { |_row, _column| raise "cell lookup failed" }
      UIng.on_error { |error, _context| errors << error }

      types.each_with_index do |expected_type, column|
        verify_native_table_fallback(native_call_cell_value(handler, column), expected_type)
      end

      errors.size.should eq(types.size)
    end

    it "releases mismatched table values and returns type-correct fallbacks" do
      types = UIng::Table::Value::Type.values
      returned_values = [] of UIng::Table::Value
      handler = UIng::Table::Model::Handler.new
      handler.num_columns { types.size }
      handler.column_type { |column| types[column] }
      handler.cell_value do |_row, column|
        new_native_table_value(types[(column + 1) % types.size]).tap do |value|
          returned_values << value
        end
      end

      types.each_with_index do |expected_type, column|
        verify_native_table_fallback(native_call_cell_value(handler, column), expected_type)
      end

      returned_values.each do |value|
        expect_raises(Exception, /already been released/) { value.to_unsafe }
      end
    end

    it "accepts NULL table cells only for color columns" do
      types = UIng::Table::Value::Type.values
      errors = [] of Exception
      handler = UIng::Table::Model::Handler.new
      handler.num_columns { types.size }
      handler.column_type { |column| types[column] }
      handler.cell_value { |_row, _column| nil }
      UIng.on_error { |error, _context| errors << error }

      types.each_with_index do |expected_type, column|
        verify_native_table_fallback(native_call_cell_value(handler, column), expected_type)
      end

      errors.size.should eq(types.size - 1)
    end

    it "round-trips the full UInt32 range through OpenType features" do
      features = UIng::OpenTypeFeatures.new
      features.get("liga").should be_nil

      features.add("liga", 0_u32)
      features.add("kern", UInt32::MAX)
      features.get("liga").should eq(0_u32)
      features.get("kern").should eq(UInt32::MAX)

      values = {} of String => UInt32
      features.for_each { |tag, value| values[tag] = value }
      values.should eq({"kern" => UInt32::MAX, "liga" => 0_u32})
    ensure
      features.try &.free
    end

    it "represents empty combobox and radio-button selections as nil" do
      combobox = UIng::Combobox.new(["first", "second"])
      radio_buttons = UIng::RadioButtons.new(["first", "second"])

      combobox.selected.should be_nil
      radio_buttons.selected.should be_nil

      combobox.selected = 1
      radio_buttons.selected = 1
      combobox.selected.should eq(1)
      radio_buttons.selected.should eq(1)

      combobox.selected = nil
      radio_buttons.selected = nil
      combobox.selected.should be_nil
      radio_buttons.selected.should be_nil
    ensure
      combobox.try &.destroy
      radio_buttons.try &.destroy
    end

    it "checks typed TableValue and Attribute getters before reading native unions" do
      int_value = UIng::Table::Value.new(7)
      string_value = UIng::Table::Value.new("seven")
      image_value = UIng::Table::Value.new(
        UIng::LibUI.new_table_value_image(Pointer(UIng::LibUI::Image).null),
        borrowed: false
      )
      table_color_value = UIng::Table::Value.new_color(0.7, 0.8, 0.9, 1.0)
      family_attribute = UIng::Area::Attribute.new_family("Sans")
      size_attribute = UIng::Area::Attribute.new_size(12.0)
      weight_attribute = UIng::Area::Attribute.new_weight(UIng::TextWeight::Bold)
      italic_attribute = UIng::Area::Attribute.new_italic(UIng::TextItalic::Italic)
      stretch_attribute = UIng::Area::Attribute.new_stretch(UIng::TextStretch::Expanded)
      color_attribute = UIng::Area::Attribute.new_color(0.1, 0.2, 0.3, 1.0)
      background_attribute = UIng::Area::Attribute.new_background(0.4, 0.5, 0.6, 1.0)
      underline_attribute = UIng::Area::Attribute.new_underline(UIng::Area::Attribute::Underline::Double)
      underline_color_attribute = UIng::Area::Attribute.new_underline_color(
        UIng::Area::Attribute::UnderlineColor::Custom,
        0.2, 0.4, 0.6, 1.0
      )
      source_features = UIng::OpenTypeFeatures.new
      source_features.add("liga", 3_u32)
      features_attribute = UIng::Area::Attribute.new_features(source_features)

      int_value.int.should eq(7)
      string_value.string.should eq("seven")
      image_value.image.null?.should be_true
      table_color_value.color.should eq({0.7, 0.8, 0.9, 1.0})
      family_attribute.family.should eq("Sans")
      size_attribute.size.should eq(12.0)
      weight_attribute.weight.should eq(UIng::TextWeight::Bold)
      italic_attribute.italic.should eq(UIng::TextItalic::Italic)
      stretch_attribute.stretch.should eq(UIng::TextStretch::Expanded)
      color_attribute.color.should eq({0.1, 0.2, 0.3, 1.0})
      background_attribute.color.should eq({0.4, 0.5, 0.6, 1.0})
      underline_attribute.underline.should eq(UIng::Area::Attribute::Underline::Double)
      underline_color_attribute.underline_color.should eq({
        UIng::Area::Attribute::UnderlineColor::Custom,
        0.2, 0.4, 0.6, 1.0,
      })
      cloned_features = features_attribute.features
      cloned_features.get("liga").should eq(3_u32)

      expect_raises(TypeCastError, /expected String, got Int/) { int_value.string }
      expect_raises(TypeCastError, /expected Family, got Size/) { size_attribute.family }
    ensure
      int_value.try &.free
      string_value.try &.free
      image_value.try &.free
      table_color_value.try &.free
      family_attribute.try &.free
      size_attribute.try &.free
      weight_attribute.try &.free
      italic_attribute.try &.free
      stretch_attribute.try &.free
      color_attribute.try &.free
      background_attribute.try &.free
      underline_attribute.try &.free
      underline_color_attribute.try &.free
      features_attribute.try &.free
      source_features.try &.free
      cloned_features.try &.free
    end

    it "rejects OpenTypeFeatures mutation during enumeration and permits nested reads" do
      features = UIng::OpenTypeFeatures.new
      features.add("kern")
      features.add("liga")
      errors = [] of Exception
      UIng.on_error { |error, _context| errors << error }

      visits = 0
      features.for_each do |_tag, _value|
        visits += 1
        features.free
      end

      visits.should eq(1)
      errors.size.should eq(1)
      errors.first.message.to_s.should contain("being enumerated")
      features.get("liga").should eq(1_u32)

      nested_visits = 0
      features.for_each do |_outer_tag, _outer_value|
        features.for_each do |_inner_tag, _inner_value|
          nested_visits += 1
        end
      end
      nested_visits.should eq(4)
    ensure
      UIng.on_error(nil)
      features.try &.free
    end

    it "rejects AttributedString mutation during enumeration and preserves its owner" do
      string = UIng::Area::AttributedString.new("abcd")
      string.set_attribute(UIng::Area::Attribute.new_size(12.0), 0, 2)
      string.set_attribute(UIng::Area::Attribute.new_weight(UIng::TextWeight::Bold), 2, 4)
      errors = [] of Exception
      UIng.on_error { |error, _context| errors << error }

      visits = 0
      string.for_each_attribute do |_attribute, _start, _end|
        visits += 1
        string.append_unattributed("x")
        0_i32
      end

      visits.should eq(1)
      errors.size.should eq(1)
      errors.first.message.to_s.should contain("being enumerated")
      string.string.should eq("abcd")

      nested_visits = 0
      string.for_each_attribute do |_outer_attribute, _outer_start, _outer_end|
        string.for_each_attribute do |_inner_attribute, _inner_start, _inner_end|
          nested_visits += 1
          0_i32
        end
        0_i32
      end
      nested_visits.should eq(4)
    ensure
      UIng.on_error(nil)
      string.try &.free
    end

    it "validates and renders every table column type before safely freeing a shared model" do
      image = UIng::Image.new(1, 1)
      image.append(Bytes[0_u8, 0_u8, 0_u8, 0xff_u8], 1, 1, 4)
      types = [
        UIng::Table::Value::Type::String,
        UIng::Table::Value::Type::Image,
        UIng::Table::Value::Type::Int,
        UIng::Table::Value::Type::Color,
        UIng::Table::Value::Type::Int,
      ]
      handler = UIng::Table::Model::Handler.new
      handler.num_columns { types.size }
      handler.column_type { |column| types[column] }
      handler.num_rows { 1 }
      handler.cell_value do |_row, column|
        case column
        when 0    then UIng::Table::Value.new("value")
        when 1    then UIng::Table::Value.new(image)
        when 2, 4 then UIng::Table::Value.new(1)
        when 3    then UIng::Table::Value.new_color(0.2, 0.3, 0.4, 1.0)
        else           raise "unexpected model column #{column}"
        end
      end
      handler.set_cell_value { |_row, _column, _value| }
      model = UIng::Table::Model.new(handler)
      tables = Array(UIng::Table).new(2) do
        UIng::Table.new(model, row_background_color_model_column: 3).tap do |table|
          table.append_text_column("Text", 0, 4, 3)
          table.append_image_column("Image", 1)
          table.append_image_text_column("Image + text", 1, 0, UIng::Table::ModelColumn::Never, 3)
          table.append_checkbox_column("Checkbox", 2, 4)
          table.append_checkbox_text_column("Checkbox + text", 2, 4, 0, 4, 3)
          table.append_progress_bar_column("Progress", 2)
          table.append_button_column("Button", 0, UIng::Table::ModelColumn::Always)
        end
      end
      windows = tables.each_with_index.map do |table, index|
        UIng::Window.new("UIng table lifecycle spec #{index}", 480, 240).tap do |window|
          window.child = table
          window.show
        end
      end.to_a
      destroy_was_requested = false

      UIng.main_steps
      UIng.queue_main do
        windows.each { |window| window.child = nil }
        tables.each(&.destroy)
        windows.each(&.destroy)
        destroy_was_requested = true
      end

      deadline = Time.instant + 5.seconds
      until destroy_was_requested
        UIng.main_step(false)
        raise "timed out waiting for table destruction request" if Time.instant >= deadline
      end

      tables.all? { |table| !table.released? }.should be_true
      model.free
      expect_raises(Exception, /already been released/) { model.to_unsafe }

      until tables.all?(&.released?) && windows.all?(&.released?)
        UIng.main_step(false)
        raise "timed out waiting for table destruction" if Time.instant >= deadline
        sleep 1.millisecond
      end
    ensure
      image.try &.free
    end

    it "flushes deferred parent and child destruction after an event callback" do
      controls = [] of UIng::Control
      callback_errors = [] of Exception
      destroy_was_requested = false

      UIng.on_error { |error, _context| callback_errors << error }
      begin
        # Exercise several complete native ownership trees. Keeping every
        # control attached to a Window also mirrors real application usage and
        # avoids testing GTK's unrelated floating-widget behavior.
        windows = Array(UIng::Window).new(8) do |index|
          window = UIng::Window.new("UIng lifecycle spec #{index}", 320, 200)
          box = UIng::Box.new(:horizontal)
          button = UIng::Button.new("child #{index}")
          box.append(button)
          window.child = box
          window.show if index == 0
          controls << window << box << button
          window
        end

        # queue_main is a genuine libui user callback, so these destroys are
        # deferred until the callback has returned.
        UIng.main_steps
        UIng.queue_main do
          windows.each(&.destroy)
          destroy_was_requested = true
        end

        deadline = Time.instant + 5.seconds
        until destroy_was_requested && controls.all?(&.released?)
          UIng.main_step(false)
          raise "timed out waiting for native destruction callbacks" if Time.instant >= deadline
          sleep 1.millisecond
        end
      ensure
        UIng.on_error(nil)
      end

      callback_errors.should be_empty
      controls.each do |control|
        control.parent.should be_nil
        pointer_is_unavailable?(control).should be_true
      end
    end
  end
end
