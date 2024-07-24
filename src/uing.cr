require "./uing/version"
require "./uing/libui"

module UIng

  # For example:
  #   delegate_class_method window_on_closing, to: LibUI, type: " -> LibC::Int"
  # should generate:
  # 
  # def self.window_on_closing(window, &callback : -> LibC::Int)
  #   boxed_data = Box.box(callback)
  #   @@box = boxed_data
  #   LibUI.window_on_closing(
  #     window,
  #     ->(window, data) {
  #       data_as_callback = Box(typeof(callback)).unbox(data)
  #       data_as_callback.call()
  #     },
  #     boxed_data
  #   )
  # end

  macro delegate_class_method(method, to object, type types = "", var vars = [] of String, has_sender sender = true, to_str c2s = false)
    {% if types == "" %}
      def self.{{method.id}}(*args)
        {% if c2s %} return String.new {% end %} {{object.id}}.{{method.id}}(*args)
      end
    {% else %}
      {% if sender %}
        def self.{{method.id}}(sender, &callback : {{types.id}})
      {% else %}
        def self.{{method.id}}(&callback : {{types.id}})
      {% end %}
          boxed_data = Box.box(callback)
          @@box = boxed_data
          {{object.id}}.{{method.id}}(
            {% if sender %}
              sender,
            {% end %}
            ->({% if sender %}sender, {% end %}{{vars.map { |v| v + ", " }.join(" ").id}}data) {
              data_as_callback = Box(typeof(callback)).unbox(data)
              data_as_callback.call({{vars.join(", ").id}})
            },
            boxed_data
          )
      end
    {% end %}
  end


  # uiInitOptions is not used (but it is required)
  # See https://github.com/libui-ng/libui-ng/issues/208
  @@init_options = Pointer(LibUI::InitOptions).malloc

  # Proc callback is boxed and stored in @@box
  @@box = Pointer(Void).null

  delegate_class_method init, to: LibUI

  # no arguments
  def self.init
    LibUI.init(@@init_options)
  end

  delegate_class_method uninit, to: LibUI
  delegate_class_method free_init_error, to: LibUI
  delegate_class_method main, to: LibUI
  delegate_class_method main_steps, to: LibUI
  delegate_class_method main_step, to: LibUI
  delegate_class_method quit, to: LibUI
  delegate_class_method queue_main, to: LibUI, type: " -> Void", has_sender: false
  delegate_class_method timer, to: LibUI, type: " -> LibC::Int" # first argument is not sender but millisecounds
  delegate_class_method on_should_quit, to: LibUI, type: " -> LibC::Int", has_sender: false
  delegate_class_method free_text, to: LibUI
  delegate_class_method control_destroy, to: LibUI
  delegate_class_method control_handle, to: LibUI
  delegate_class_method control_parent, to: LibUI
  delegate_class_method control_set_parent, to: LibUI
  delegate_class_method control_toplevel, to: LibUI
  delegate_class_method control_visible, to: LibUI
  delegate_class_method control_show, to: LibUI
  delegate_class_method control_hide, to: LibUI
  delegate_class_method control_enabled, to: LibUI
  delegate_class_method control_enable, to: LibUI
  delegate_class_method control_disable, to: LibUI
  delegate_class_method alloc_control, to: LibUI
  delegate_class_method free_control, to: LibUI
  delegate_class_method control_verify_set_parent, to: LibUI
  delegate_class_method control_enabled_to_user, to: LibUI
  delegate_class_method user_bug_cannot_set_parent_on_toplevel, to: LibUI
  delegate_class_method window_title, to: LibUI, to_str: true
  delegate_class_method window_set_title, to: LibUI
  delegate_class_method window_position, to: LibUI
  delegate_class_method window_set_position, to: LibUI
  delegate_class_method window_on_position_changed, to: LibUI, type: " -> Void"
  delegate_class_method window_content_size, to: LibUI
  delegate_class_method window_set_content_size, to: LibUI
  delegate_class_method window_fullscreen, to: LibUI
  delegate_class_method window_set_fullscreen, to: LibUI
  delegate_class_method window_on_content_size_changed, to: LibUI, type: " -> Void"
  delegate_class_method window_on_closing, to: LibUI, type: " -> LibC::Int"
  delegate_class_method window_on_focus_changed, to: LibUI, type: " -> Void"
  delegate_class_method window_focused, to: LibUI
  delegate_class_method window_borderless, to: LibUI
  delegate_class_method window_set_borderless, to: LibUI
  delegate_class_method window_set_child, to: LibUI
  delegate_class_method window_margined, to: LibUI
  delegate_class_method window_set_margined, to: LibUI
  delegate_class_method window_resizeable, to: LibUI
  delegate_class_method window_set_resizeable, to: LibUI
  delegate_class_method new_window, to: LibUI
  delegate_class_method button_text, to: LibUI, to_str: true
  delegate_class_method button_set_text, to: LibUI
  delegate_class_method button_on_clicked, to: LibUI, type: " -> Void"
  delegate_class_method new_button, to: LibUI
  delegate_class_method box_append, to: LibUI
  delegate_class_method box_num_children, to: LibUI
  delegate_class_method box_delete, to: LibUI
  delegate_class_method box_padded, to: LibUI
  delegate_class_method box_set_padded, to: LibUI
  delegate_class_method new_horizontal_box, to: LibUI
  delegate_class_method new_vertical_box, to: LibUI
  delegate_class_method checkbox_text, to: LibUI, to_str: true
  delegate_class_method checkbox_set_text, to: LibUI
  delegate_class_method checkbox_on_toggled, to: LibUI, type: " -> Void"
  delegate_class_method checkbox_checked, to: LibUI
  delegate_class_method checkbox_set_checked, to: LibUI
  delegate_class_method new_checkbox, to: LibUI
  delegate_class_method entry_text, to: LibUI, to_str: true
  delegate_class_method entry_set_text, to: LibUI
  delegate_class_method entry_on_changed, to: LibUI, type: " -> Void"
  delegate_class_method entry_read_only, to: LibUI
  delegate_class_method entry_set_read_only, to: LibUI
  delegate_class_method new_entry, to: LibUI
  delegate_class_method new_password_entry, to: LibUI
  delegate_class_method new_search_entry, to: LibUI
  delegate_class_method label_text, to: LibUI, to_str: true
  delegate_class_method label_set_text, to: LibUI
  delegate_class_method new_label, to: LibUI
  delegate_class_method tab_append, to: LibUI
  delegate_class_method tab_insert_at, to: LibUI
  delegate_class_method tab_delete, to: LibUI
  delegate_class_method tab_num_pages, to: LibUI
  delegate_class_method tab_margined, to: LibUI
  delegate_class_method tab_set_margined, to: LibUI
  delegate_class_method new_tab, to: LibUI
  delegate_class_method group_title, to: LibUI, to_str: true
  delegate_class_method group_set_title, to: LibUI
  delegate_class_method group_set_child, to: LibUI
  delegate_class_method group_margined, to: LibUI
  delegate_class_method group_set_margined, to: LibUI
  delegate_class_method new_group, to: LibUI
  delegate_class_method spinbox_value, to: LibUI
  delegate_class_method spinbox_set_value, to: LibUI
  delegate_class_method spinbox_on_changed, to: LibUI, type: " -> Void"
  delegate_class_method new_spinbox, to: LibUI
  delegate_class_method slider_value, to: LibUI
  delegate_class_method slider_set_value, to: LibUI
  delegate_class_method slider_has_tool_tip, to: LibUI
  delegate_class_method slider_set_has_tool_tip, to: LibUI
  delegate_class_method slider_on_changed, to: LibUI, type: " -> Void"
  delegate_class_method slider_on_released, to: LibUI, type: " -> Void"
  delegate_class_method slider_set_range, to: LibUI
  delegate_class_method new_slider, to: LibUI
  delegate_class_method progress_bar_value, to: LibUI
  delegate_class_method progress_bar_set_value, to: LibUI
  delegate_class_method new_progress_bar, to: LibUI
  delegate_class_method new_horizontal_separator, to: LibUI
  delegate_class_method new_vertical_separator, to: LibUI
  delegate_class_method combobox_append, to: LibUI
  delegate_class_method combobox_insert_at, to: LibUI
  delegate_class_method combobox_delete, to: LibUI
  delegate_class_method combobox_clear, to: LibUI
  delegate_class_method combobox_num_items, to: LibUI
  delegate_class_method combobox_selected, to: LibUI
  delegate_class_method combobox_set_selected, to: LibUI
  delegate_class_method combobox_on_selected, to: LibUI, type: " -> Void"
  delegate_class_method new_combobox, to: LibUI
  delegate_class_method editable_combobox_append, to: LibUI
  delegate_class_method editable_combobox_text, to: LibUI, to_str: true
  delegate_class_method editable_combobox_set_text, to: LibUI
  delegate_class_method editable_combobox_on_changed, to: LibUI, type: " -> Void"
  delegate_class_method new_editable_combobox, to: LibUI
  delegate_class_method radio_buttons_append, to: LibUI
  delegate_class_method radio_buttons_selected, to: LibUI
  delegate_class_method radio_buttons_set_selected, to: LibUI
  delegate_class_method radio_buttons_on_selected, to: LibUI, type: " -> Void"
  delegate_class_method new_radio_buttons, to: LibUI
  delegate_class_method date_time_picker_time, to: LibUI
  delegate_class_method date_time_picker_set_time, to: LibUI
  delegate_class_method date_time_picker_on_changed, to: LibUI, type: " -> Void"
  delegate_class_method new_date_time_picker, to: LibUI
  delegate_class_method new_date_picker, to: LibUI
  delegate_class_method new_time_picker, to: LibUI
  delegate_class_method multiline_entry_text, to: LibUI, to_str: true
  delegate_class_method multiline_entry_set_text, to: LibUI
  delegate_class_method multiline_entry_append, to: LibUI
  delegate_class_method multiline_entry_on_changed, to: LibUI, type: " -> Void"
  delegate_class_method multiline_entry_read_only, to: LibUI
  delegate_class_method multiline_entry_set_read_only, to: LibUI
  delegate_class_method new_multiline_entry, to: LibUI
  delegate_class_method new_non_wrapping_multiline_entry, to: LibUI
  delegate_class_method menu_item_enable, to: LibUI
  delegate_class_method menu_item_disable, to: LibUI
  delegate_class_method menu_item_on_clicked, to: LibUI, type: "Pointer(LibUI::Window) -> Void", var: ["window"]
  delegate_class_method menu_item_checked, to: LibUI
  delegate_class_method menu_item_set_checked, to: LibUI
  delegate_class_method menu_append_item, to: LibUI
  delegate_class_method menu_append_check_item, to: LibUI
  delegate_class_method menu_append_quit_item, to: LibUI
  delegate_class_method menu_append_preferences_item, to: LibUI
  delegate_class_method menu_append_about_item, to: LibUI
  delegate_class_method menu_append_separator, to: LibUI
  delegate_class_method new_menu, to: LibUI
  delegate_class_method open_file, to: LibUI, to_str: true
  delegate_class_method open_folder, to: LibUI, to_str: true
  delegate_class_method save_file, to: LibUI, to_str: true
  delegate_class_method msg_box, to: LibUI
  delegate_class_method msg_box_error, to: LibUI
  delegate_class_method area_set_size, to: LibUI
  delegate_class_method area_queue_redraw_all, to: LibUI
  delegate_class_method area_scroll_to, to: LibUI
  delegate_class_method area_begin_user_window_move, to: LibUI
  delegate_class_method area_begin_user_window_resize, to: LibUI
  delegate_class_method new_area, to: LibUI
  delegate_class_method new_scrolling_area, to: LibUI
  delegate_class_method draw_new_path, to: LibUI
  delegate_class_method draw_free_path, to: LibUI
  delegate_class_method draw_path_new_figure, to: LibUI
  delegate_class_method draw_path_new_figure_with_arc, to: LibUI
  delegate_class_method draw_path_line_to, to: LibUI
  delegate_class_method draw_path_arc_to, to: LibUI
  delegate_class_method draw_path_bezier_to, to: LibUI
  delegate_class_method draw_path_close_figure, to: LibUI
  delegate_class_method draw_path_add_rectangle, to: LibUI
  delegate_class_method draw_path_ended, to: LibUI
  delegate_class_method draw_path_end, to: LibUI
  delegate_class_method draw_stroke, to: LibUI
  delegate_class_method draw_fill, to: LibUI
  delegate_class_method draw_matrix_set_identity, to: LibUI
  delegate_class_method draw_matrix_translate, to: LibUI
  delegate_class_method draw_matrix_scale, to: LibUI
  delegate_class_method draw_matrix_rotate, to: LibUI
  delegate_class_method draw_matrix_skew, to: LibUI
  delegate_class_method draw_matrix_multiply, to: LibUI
  delegate_class_method draw_matrix_invertible, to: LibUI
  delegate_class_method draw_matrix_invert, to: LibUI
  delegate_class_method draw_matrix_transform_point, to: LibUI
  delegate_class_method draw_matrix_transform_size, to: LibUI
  delegate_class_method draw_transform, to: LibUI
  delegate_class_method draw_clip, to: LibUI
  delegate_class_method draw_save, to: LibUI
  delegate_class_method draw_restore, to: LibUI
  delegate_class_method free_attribute, to: LibUI
  delegate_class_method attribute_get_type, to: LibUI
  delegate_class_method new_family_attribute, to: LibUI
  delegate_class_method attribute_family, to: LibUI
  delegate_class_method new_size_attribute, to: LibUI
  delegate_class_method attribute_size, to: LibUI
  delegate_class_method new_weight_attribute, to: LibUI
  delegate_class_method attribute_weight, to: LibUI
  delegate_class_method new_italic_attribute, to: LibUI
  delegate_class_method attribute_italic, to: LibUI
  delegate_class_method new_stretch_attribute, to: LibUI
  delegate_class_method attribute_stretch, to: LibUI
  delegate_class_method new_color_attribute, to: LibUI
  delegate_class_method attribute_color, to: LibUI
  delegate_class_method new_background_attribute, to: LibUI
  delegate_class_method new_underline_attribute, to: LibUI
  delegate_class_method attribute_underline, to: LibUI
  delegate_class_method new_underline_color_attribute, to: LibUI
  delegate_class_method attribute_underline_color, to: LibUI
  delegate_class_method new_open_type_features, to: LibUI
  delegate_class_method free_open_type_features, to: LibUI
  delegate_class_method open_type_features_clone, to: LibUI
  delegate_class_method open_type_features_add, to: LibUI
  delegate_class_method open_type_features_remove, to: LibUI
  delegate_class_method open_type_features_get, to: LibUI
  # delegate_class_method open_type_features_for_each, to: LibUI, type: "(Pointer(Void), Pointer(Void), Pointer(Void)) -> LibC::Int"
  delegate_class_method new_features_attribute, to: LibUI
  delegate_class_method attribute_features, to: LibUI
  delegate_class_method new_attributed_string, to: LibUI
  delegate_class_method free_attributed_string, to: LibUI
  delegate_class_method attributed_string_string, to: LibUI
  delegate_class_method attributed_string_len, to: LibUI
  delegate_class_method attributed_string_append_unattributed, to: LibUI
  delegate_class_method attributed_string_insert_at_unattributed, to: LibUI
  delegate_class_method attributed_string_delete, to: LibUI
  delegate_class_method attributed_string_set_attribute, to: LibUI
  # delegate_class_method attributed_string_for_each_attribute, to: LibUI
  delegate_class_method attributed_string_num_graphemes, to: LibUI
  delegate_class_method attributed_string_byte_index_to_grapheme, to: LibUI
  delegate_class_method attributed_string_grapheme_to_byte_index, to: LibUI
  delegate_class_method load_control_font, to: LibUI
  delegate_class_method free_font_descriptor, to: LibUI
  delegate_class_method draw_new_text_layout, to: LibUI
  delegate_class_method draw_free_text_layout, to: LibUI
  delegate_class_method draw_text, to: LibUI
  delegate_class_method draw_text_layout_extents, to: LibUI
  delegate_class_method font_button_font, to: LibUI
  delegate_class_method font_button_on_changed, to: LibUI, type: " -> Void"
  delegate_class_method new_font_button, to: LibUI
  delegate_class_method free_font_button_font, to: LibUI
  delegate_class_method color_button_color, to: LibUI
  delegate_class_method color_button_set_color, to: LibUI
  delegate_class_method color_button_on_changed, to: LibUI, type: " -> Void"
  delegate_class_method new_color_button, to: LibUI
  delegate_class_method form_append, to: LibUI
  delegate_class_method form_num_children, to: LibUI
  delegate_class_method form_delete, to: LibUI
  delegate_class_method form_padded, to: LibUI
  delegate_class_method form_set_padded, to: LibUI
  delegate_class_method new_form, to: LibUI
  delegate_class_method grid_append, to: LibUI
  delegate_class_method grid_insert_at, to: LibUI
  delegate_class_method grid_padded, to: LibUI
  delegate_class_method grid_set_padded, to: LibUI
  delegate_class_method new_grid, to: LibUI
  delegate_class_method new_image, to: LibUI
  delegate_class_method free_image, to: LibUI
  delegate_class_method image_append, to: LibUI
  delegate_class_method free_table_value, to: LibUI
  delegate_class_method table_value_get_type, to: LibUI
  delegate_class_method new_table_value_string, to: LibUI
  delegate_class_method table_value_string, to: LibUI
  delegate_class_method new_table_value_image, to: LibUI
  delegate_class_method table_value_image, to: LibUI
  delegate_class_method new_table_value_int, to: LibUI
  delegate_class_method table_value_int, to: LibUI
  delegate_class_method new_table_value_color, to: LibUI
  delegate_class_method table_value_color, to: LibUI
  delegate_class_method new_table_model, to: LibUI
  delegate_class_method free_table_model, to: LibUI
  delegate_class_method table_model_row_inserted, to: LibUI
  delegate_class_method table_model_row_changed, to: LibUI
  delegate_class_method table_model_row_deleted, to: LibUI
  delegate_class_method table_append_text_column, to: LibUI
  delegate_class_method table_append_image_column, to: LibUI
  delegate_class_method table_append_image_text_column, to: LibUI
  delegate_class_method table_append_checkbox_column, to: LibUI
  delegate_class_method table_append_checkbox_text_column, to: LibUI
  delegate_class_method table_append_progress_bar_column, to: LibUI
  delegate_class_method table_append_button_column, to: LibUI
  delegate_class_method table_header_visible, to: LibUI
  delegate_class_method table_header_set_visible, to: LibUI
  delegate_class_method new_table, to: LibUI
  delegate_class_method table_on_row_clicked, to: LibUI, type: "LibC::Int -> Void", var: ["row"]        # first argument is uiTable (sender)
  delegate_class_method table_on_row_double_clicked, to: LibUI, type: "LibC::Int -> Void", var: ["row"] # first argument is uiTable (sender)
  delegate_class_method table_header_set_sort_indicator, to: LibUI
  delegate_class_method table_header_sort_indicator, to: LibUI
  delegate_class_method table_header_on_clicked, to: LibUI, type: "LibC::Int -> Void", var: ["column"] # first argument is uiTable (sender)
  delegate_class_method table_column_width, to: LibUI
  delegate_class_method table_column_set_width, to: LibUI
  delegate_class_method table_get_selection_mode, to: LibUI
  delegate_class_method table_set_selection_mode, to: LibUI
  delegate_class_method table_on_selection_changed, to: LibUI, type: " -> Void"
  delegate_class_method table_get_selection, to: LibUI
  delegate_class_method table_set_selection, to: LibUI
  delegate_class_method free_table_selection, to: LibUI

  macro define_cstruct_class(name, to_str members = [] of String)
    class {{name.id}}
      def initialize
        @cstruct = LibUI::{{name.id}}.new
      end

      # Auto convert to and from String
      {% for member in members %}
        def {{member.id}}
          String.new(@cstruct.{{member.id}})
        end

        def {{member.id}}=(value : String)
          @{{member.id}} = value # Try to keep the value alive, but is this necessary?
          @cstruct.{{member.id}} = @{{member.id}}.to_unsafe
        end
      {% end %}

      forward_missing_to @cstruct

      def to_unsafe
        pointerof(@cstruct)
      end
    end
  end

  {% if flag?(:windows) %}
    define_cstruct_class TM
  {% else %}
    define_cstruct_class TM, to_str: ["zone"]
  {% end %}
  define_cstruct_class AreaHandler
  define_cstruct_class AreaDrawParams
  define_cstruct_class AreaMouseEvent
  define_cstruct_class AreaKeyEvent
  define_cstruct_class DrawBrush
  define_cstruct_class DrawStrokeParams
  define_cstruct_class DrawMatrix
  define_cstruct_class DrawBrushGradientStop
  define_cstruct_class FontDescriptor, to_str: ["family"]
  define_cstruct_class DrawTextLayoutParams
  define_cstruct_class TableModelHandler
  define_cstruct_class TableTextColumnOptionalParams
  define_cstruct_class TableParams
  define_cstruct_class TableSelection
end
