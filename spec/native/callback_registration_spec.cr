require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  # Callback retention has no public accessor. Observe it without injecting state
  # or relying on the timing of the conservative garbage collector.
  {% for type, fields in {
                           UIng::Button      => [:on_clicked_box],
                           UIng::Slider      => [:on_changed_box, :on_released_box],
                           UIng::Window      => [:on_position_changed_box, :on_content_size_changed_box, :on_closing_box, :on_focus_changed_box],
                           UIng::Table       => [:on_row_clicked_box, :on_row_double_clicked_box, :on_header_clicked_box, :on_selection_changed_box],
                           UIng::ToolbarItem => [:on_clicked_box],
                         } %}
    class {{type}}
      def callback_boxes_for_spec : Array(Pointer(Void)?)
        [{% for field in fields %} @{{field.id}}, {% end %}] of Pointer(Void)?
      end
    end
  {% end %}

  private def expect_callback_rejected_without_retention(control, &)
    before = control.callback_boxes_for_spec
    expect_raises(Exception, /already been (destroyed|released)/) { yield }
    control.callback_boxes_for_spec.should eq(before)
  end

  describe "callback registration on released objects" do
    before_all { UIng.init }
    after_all { UIng.uninit }

    it "does not retain a rejected Button callback" do
      window = UIng::Window.new("Released button", 160, 80)
      button = UIng::Button.new("Button")
      window.child = button
      window.destroy

      expect_callback_rejected_without_retention(button) { button.on_clicked { } }
    ensure
      window.try &.destroy
    end

    it "does not retain either rejected Slider callback" do
      window = UIng::Window.new("Released slider", 160, 80)
      slider = UIng::Slider.new(0, 100)
      window.child = slider
      window.destroy

      expect_callback_rejected_without_retention(slider) { slider.on_changed { |_value| } }
      expect_callback_rejected_without_retention(slider) { slider.on_released { |_value| } }
    ensure
      window.try &.destroy
    end

    it "does not retain rejected Window callbacks" do
      window = UIng::Window.new("Released window", 160, 80)
      window.destroy

      expect_callback_rejected_without_retention(window) { window.on_position_changed { |_x, _y| } }
      expect_callback_rejected_without_retention(window) { window.on_content_size_changed { |_width, _height| } }
      expect_callback_rejected_without_retention(window) { window.on_closing { false } }
      expect_callback_rejected_without_retention(window) { window.on_focus_changed { |_focused| } }
    ensure
      window.try &.destroy
    end

    it "does not retain rejected Table callbacks" do
      handler = UIng::Table::Model::Handler.new
      handler.num_columns { 1 }
      handler.column_type { |_column| UIng::Table::Value::Type::String }
      handler.num_rows { 0 }
      model = UIng::Table::Model.new(handler)
      window = UIng::Window.new("Released table", 160, 80)
      table = UIng::Table.new(model)
      window.child = table
      window.destroy

      expect_callback_rejected_without_retention(table) { table.on_row_clicked { |_row| } }
      expect_callback_rejected_without_retention(table) { table.on_row_double_clicked { |_row| } }
      expect_callback_rejected_without_retention(table) { table.on_header_clicked { |_column| } }
      expect_callback_rejected_without_retention(table) { table.on_selection_changed { |_selection| } }
    ensure
      window.try &.destroy
      model.try &.free
    end

    it "does not retain a rejected ToolbarItem callback" do
      toolbar = UIng::Toolbar.new
      item = toolbar.append_button("Button")
      toolbar.free

      expect_callback_rejected_without_retention(item) { item.on_clicked { |_item| } }
    ensure
      toolbar.try &.free
    end
  end
{% end %}
