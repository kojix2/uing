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
