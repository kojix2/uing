require "../spec_helper"
require "../support/native_controls"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  # Callback retention has no public accessor. Observe it without injecting state
  # or relying on the timing of the conservative garbage collector.
  {% for type, fields in {
                           UIng::Button           => [:on_clicked_box],
                           UIng::Checkbox         => [:on_toggled_box],
                           UIng::Entry            => [:on_changed_box],
                           UIng::MultilineEntry   => [:on_changed_box],
                           UIng::Combobox         => [:on_selected_box],
                           UIng::EditableCombobox => [:on_changed_box],
                           UIng::RadioButtons     => [:on_selected_box],
                           UIng::Spinbox          => [:on_changed_box],
                           UIng::Slider           => [:on_changed_box, :on_released_box],
                           UIng::ColorButton      => [:on_changed_box],
                           UIng::FontButton       => [:on_changed_box],
                           UIng::DateTimePicker   => [:on_changed_box],
                           UIng::Window           => [:on_position_changed_box, :on_content_size_changed_box, :on_closing_box, :on_focus_changed_box],
                           UIng::Table            => [:on_row_clicked_box, :on_row_double_clicked_box, :on_header_clicked_box, :on_selection_changed_box],
                           UIng::ToolbarItem      => [:on_clicked_box],
                         } %}
    class {{ type }}
      def callback_boxes_for_spec : Array(Pointer(Void)?)
        [{% for field in fields %} @{{ field.id }}, {% end %}] of Pointer(Void)?
      end
    end
  {% end %}

  private def expect_callback_rejected_without_retention(control, &)
    before = control.callback_boxes_for_spec
    expect_raises(Exception, /already been (destroyed|released)/) { yield }
    control.callback_boxes_for_spec.should eq(before)
  end

  describe "control callback lifecycle" do
    before_all { UIng.init }
    after_all { UIng.uninit }

    # These controls share callback retention and clearing contracts. Keep the
    # matrix explicit so each callback API, including aliases, is instantiated.
    {% for callback_case in [
                              {UIng::Button, ["Button"], [[:on_clicked, :clear_on_clicked]]},
                              {UIng::Checkbox, ["Checkbox"], [[:on_toggled, :clear_on_toggled]]},
                              {UIng::Entry, [] of Nil, [[:on_changed, :clear_on_changed]]},
                              {UIng::MultilineEntry, [] of Nil, [[:on_changed, :clear_on_changed], [:on_changed_with_text, :clear_on_changed_with_text]]},
                              {UIng::Combobox, [["first"]], [[:on_selected, :clear_on_selected]]},
                              {UIng::EditableCombobox, [] of Nil, [[:on_changed, :clear_on_changed]]},
                              {UIng::RadioButtons, [["first"]], [[:on_selected, :clear_on_selected]]},
                              {UIng::Spinbox, [0, 100], [[:on_changed, :clear_on_changed]]},
                              {UIng::Slider, [0, 100], [[:on_changed, :clear_on_changed], [:on_released, :clear_on_released]]},
                              {UIng::ColorButton, [] of Nil, [[:on_changed, :clear_on_changed]]},
                              {UIng::FontButton, [] of Nil, [[:on_changed, :clear_on_changed]]},
                              {UIng::DateTimePicker, [] of Nil, [[:on_changed, :clear_on_changed]]},
                            ] %}
      {% type, arguments, callbacks = callback_case[0], callback_case[1], callback_case[2] %}
      describe {{ type }} do
        {% for callback in callbacks %}
          describe {{ callback[0].id.stringify }} do
            it "replaces the retained callback and keeps its replacement across garbage collection" do
              SpecSupport.with_native_control({{ type }}.new({{ arguments.splat }})) do |control|
                control.{{ callback[0].id }} { }
                original = control.callback_boxes_for_spec.compact
                original.size.should eq(1)
                control.{{ callback[0].id }} { }
                control.callback_boxes_for_spec.compact.should_not eq(original)
                GC.collect
                control.callback_boxes_for_spec.compact.size.should eq(1)
              end
            end

            it "releases the retained callback through either clearing form" do
              SpecSupport.with_native_control({{ type }}.new({{ arguments.splat }})) do |control|
                control.{{ callback[0].id }} { }
                control.callback_boxes_for_spec.compact.size.should eq(1)
                control.{{ callback[1].id }}
                control.callback_boxes_for_spec.compact.should be_empty
                control.{{ callback[0].id }} { }
                control.callback_boxes_for_spec.compact.size.should eq(1)
                control.{{ callback[0].id }}(nil)
                control.callback_boxes_for_spec.compact.should be_empty
              end
            end

            it "does not retain a callback rejected after destruction" do
              window = UIng::Window.new("Rejected callback", 160, 80)
              control = {{ type }}.new({{ arguments.splat }})
              window.child = control
              window.destroy

              expect_callback_rejected_without_retention(control) { control.{{ callback[0].id }} { } }
            ensure
              window.try &.destroy
            end
          end
        {% end %}

        it "releases retained callbacks when the parent destroys the control" do
          window = UIng::Window.new("Callback cleanup", 160, 80)
          control = {{ type }}.new({{ arguments.splat }})
          window.child = control
          {% for callback in callbacks %}
            control.{{ callback[0].id }} { }
          {% end %}
          control.callback_boxes_for_spec.compact.should_not be_empty

          window.destroy
          deadline = Time.instant + 5.seconds
          until control.callback_boxes_for_spec.compact.empty?
            UIng.main_step(false)
            raise "timed out waiting for callback cleanup" if Time.instant >= deadline
          end
          control.released?.should be_true
        ensure
          window.try &.destroy
        end
      end
    {% end %}

    describe UIng::Window do
      {% for callback in [:on_position_changed, :on_content_size_changed, :on_closing, :on_focus_changed] %}
        it {{ "does not retain a rejected " + callback.id.stringify + " callback" }} do
          window = UIng::Window.new("Released window", 160, 80)
          window.destroy

          expect_callback_rejected_without_retention(window) do
            window.{{ callback.id }} do
              {% if callback == :on_closing %}
                false
              {% end %}
            end
          end
        ensure
          window.try &.destroy
        end
      {% end %}
    end

    describe UIng::Table do
      {% for callback in [:on_row_clicked, :on_row_double_clicked, :on_header_clicked, :on_selection_changed] %}
        it {{ "does not retain a rejected " + callback.id.stringify + " callback" }} do
          handler = UIng::Table::Model::Handler.new
          handler.num_columns { 1 }
          handler.column_type { |_column| UIng::Table::Value::Type::String }
          handler.num_rows { 0 }
          model = UIng::Table::Model.new(handler)
          window = UIng::Window.new("Released table", 160, 80)
          table = UIng::Table.new(model)
          window.child = table
          window.destroy

          expect_callback_rejected_without_retention(table) { table.{{ callback.id }} { } }
        ensure
          window.try &.destroy
          model.try &.free
        end
      {% end %}
    end

    describe UIng::ToolbarItem do
      it "does not retain a rejected ToolbarItem callback" do
        toolbar = UIng::Toolbar.new
        item = toolbar.append_button("Button")
        toolbar.free

        expect_callback_rejected_without_retention(item) { item.on_clicked { |_item| } }
      ensure
        toolbar.try &.free
      end
    end
  end
{% end %}
