require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  private class NativeLifecycleTable < UIng::Table
    getter? native_destroyed = false

    def initialize(model : UIng::Table::Model, row_background_color_model_column : LibC::Int = -1)
      super
    end

    protected def after_destroy : Nil
      @native_destroyed = true
      super
    end
  end

  describe UIng::Table do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

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
      tables = Array(NativeLifecycleTable).new(2) do
        NativeLifecycleTable.new(model, row_background_color_model_column: 3).tap do |table|
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
      tables.first.selection = UIng::Table::Selection.new([0])
      selection = tables.first.selection
      selection.rows.should eq([0])
      selected_row_indices = [] of Int32
      tables.first.each_selected_index { |row_index| selected_row_indices << row_index }
      selected_row_indices.should eq([0])
      tables.first.selection = UIng::Table::Selection.new([] of Int32)
      tables.first.selection.rows.should be_empty
      tables.first.each_selected_index { |row_index| selected_row_indices << row_index }
      selected_row_indices.should eq([0])
      selection.rows.should eq([0])
      destroy_was_requested = false

      UIng.main_steps
      UIng.queue_main do
        windows.each(&.child=(nil))
        tables.each(&.destroy)
        windows.each(&.destroy)
        destroy_was_requested = true
      end

      deadline = Time.instant + 5.seconds
      until destroy_was_requested
        UIng.main_step(false)
        raise "timed out waiting for table destruction request" if Time.instant >= deadline
      end

      # DestroyPending controls are already unavailable through the public API,
      # regardless of whether this backend destroys them synchronously.
      tables.all?(&.released?).should be_true
      model.free
      expect_raises(Exception, /already been released/) { model.to_unsafe }

      until tables.all?(&.native_destroyed?)
        UIng.main_step(false)
        raise "timed out waiting for table destruction" if Time.instant >= deadline
        sleep 1.millisecond
      end
    ensure
      image.try &.free
    end
  end
{% end %}
