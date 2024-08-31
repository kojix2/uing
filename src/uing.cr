require "./uing/version"
require "./uing/lib_ui"
require "./uing/tm"

require "./uing/*"

module UIng
  # uiInitOptions is not used (but it is required)
  # See https://github.com/libui-ng/libui-ng/issues/208
  @@init_options = Pointer(LibUI::InitOptions).malloc

  # Proc callback is boxed and stored in @@box
  @@box = Pointer(Void).null

  # Convert control to Pointer(LibUI::Control)
  private def self.to_control(control)
    if control.is_a?(Pointer)
      control.as(Pointer(LibUI::Control))
    else
      control.to_unsafe.as(Pointer(LibUI::Control))
    end
  end

  def self.init : Nil
    str_ptr = LibUI.init(@@init_options)
    return if str_ptr.null?
    err = String.new(str_ptr)
    LibUI.free_init_error(str_ptr)
    raise err
  end

  def self.init(init_options : Pointer(LibUI::InitOptions)) : String?
    @@init_options = init_options
    self.init
  end

  def self.uninit : Nil
    LibUI.uninit
  end

  # should not be used.
  # See the implementation of `init` above.

  def self.free_init_error(err) : Nil
    LibUI.free_init_error(err)
  end

  def self.main : Nil
    LibUI.main
  end

  def self.main_steps : Nil
    LibUI.main_steps
  end

  def self.main_step(wait) : LibC::Int
    LibUI.main_step(*args)
  end

  def self.quit : Nil
    LibUI.quit
  end

  def self.queue_main(&callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.queue_main(->(data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.timer(sender, &callback : -> LibC::Int) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.timer(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.on_should_quit(&callback : -> LibC::Int) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.on_should_quit(->(data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.free_text(text) : Nil
    LibUI.free_text(text)
  end

  def self.control_destroy(control) : Nil
    LibUI.control_destroy(to_control(control))
  end

  def self.control_handle(control)
    LibUI.control_handle(to_control(control))
  end

  def self.control_parent(control)
    LibUI.control_parent(to_control(control))
  end

  def self.control_set_parent(control, parent) : Nil
    LibUI.control_set_parent(to_control(control), to_control(parent))
  end

  def self.control_toplevel(control)
    LibUI.control_toplevel(to_control(control))
  end

  def self.control_visible(control) : LibC::Int
    LibUI.control_visible(to_control(control))
  end

  def self.control_show(control) : Nil
    LibUI.control_show(to_control(control))
  end

  def self.control_hide(control) : Nil
    LibUI.control_hide(to_control(control))
  end

  def self.control_enabled(control) : LibC::Int
    LibUI.control_enabled(to_control(control))
  end

  def self.control_enable(control) : Nil
    LibUI.control_enable(to_control(control))
  end

  def self.control_disable(control) : Nil
    LibUI.control_disable(to_control(control))
  end

  def self.alloc_control(*args)
    LibUI.alloc_control(*args)
  end

  def self.free_control(control) : Nil
    LibUI.free_control(to_control(control))
  end

  def self.control_verify_set_parent(control, parent) : Nil
    LibUI.control_verify_set_parent(to_control(control), to_control(parent))
  end

  def self.control_enabled_to_user(control) : LibC::Int
    LibUI.control_enabled_to_user(to_control(control))
  end

  def self.user_bug_cannot_set_parent_on_toplevel(*args) : Nil
    LibUI.user_bug_cannot_set_parent_on_toplevel(*args)
  end

  def self.window_title(window) : String?
    str_ptr = LibUI.window_title(window)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.window_set_title(*args) : Nil
    LibUI.window_set_title(*args)
  end

  def self.window_position(*args) : Nil
    LibUI.window_position(*args)
  end

  def self.window_set_position(*args) : Nil
    LibUI.window_set_position(*args)
  end

  def self.window_on_position_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.window_on_position_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.window_content_size(*args) : Nil
    LibUI.window_content_size(*args)
  end

  def self.window_set_content_size(*args) : Nil
    LibUI.window_set_content_size(*args)
  end

  def self.window_fullscreen(*args)
    LibUI.window_fullscreen(*args)
  end

  def self.window_set_fullscreen(*args) : Nil
    LibUI.window_set_fullscreen(*args)
  end

  def self.window_on_content_size_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.window_on_content_size_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.window_on_closing(sender, &callback : -> LibC::Int) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.window_on_closing(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.window_on_focus_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.window_on_focus_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.window_focused(*args)
    LibUI.window_focused(*args)
  end

  def self.window_borderless(*args)
    LibUI.window_borderless(*args)
  end

  def self.window_set_borderless(*args) : Nil
    LibUI.window_set_borderless(*args)
  end

  def self.window_set_child(window, control) : Nil
    LibUI.window_set_child(window, to_control(control))
  end

  def self.window_margined(*args)
    LibUI.window_margined(*args)
  end

  def self.window_set_margined(*args) : Nil
    LibUI.window_set_margined(*args)
  end

  def self.window_resizeable(*args)
    LibUI.window_resizeable(*args)
  end

  def self.window_set_resizeable(*args) : Nil
    LibUI.window_set_resizeable(*args)
  end

  def self.new_window(*args)
    LibUI.new_window(*args)
  end

  def self.button_text(button) : String?
    str_ptr = LibUI.button_text(button)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.button_set_text(*args) : Nil
    LibUI.button_set_text(*args)
  end

  def self.button_on_clicked(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.button_on_clicked(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_button(*args)
    LibUI.new_button(*args)
  end

  def self.box_append(box, control, stretchy) : Nil
    LibUI.box_append(box, to_control(control), stretchy)
  end

  def self.box_num_children(*args)
    LibUI.box_num_children(*args)
  end

  def self.box_delete(*args) : Nil
    LibUI.box_delete(*args)
  end

  def self.box_padded(*args)
    LibUI.box_padded(*args)
  end

  def self.box_set_padded(*args) : Nil
    LibUI.box_set_padded(*args)
  end

  def self.new_horizontal_box
    LibUI.new_horizontal_box
  end

  def self.new_vertical_box
    LibUI.new_vertical_box
  end

  def self.checkbox_text(checkbox) : String?
    str_ptr = LibUI.checkbox_text(checkbox)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.checkbox_set_text(*args) : Nil
    LibUI.checkbox_set_text(*args)
  end

  def self.checkbox_on_toggled(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.checkbox_on_toggled(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.checkbox_checked(*args)
    LibUI.checkbox_checked(*args)
  end

  def self.checkbox_set_checked(*args) : Nil
    LibUI.checkbox_set_checked(*args)
  end

  def self.new_checkbox(*args)
    LibUI.new_checkbox(*args)
  end

  def self.entry_text(entry) : String?
    str_ptr = LibUI.entry_text(entry)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.entry_set_text(*args) : Nil
    LibUI.entry_set_text(*args)
  end

  def self.entry_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.entry_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.entry_read_only(*args)
    LibUI.entry_read_only(*args)
  end

  def self.entry_set_read_only(*args) : Nil
    LibUI.entry_set_read_only(*args)
  end

  def self.new_entry
    LibUI.new_entry
  end

  def self.new_password_entry
    LibUI.new_password_entry
  end

  def self.new_search_entry
    LibUI.new_search_entry
  end

  def self.label_text(label) : String?
    str_ptr = LibUI.label_text(label)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.label_set_text(*args) : Nil
    LibUI.label_set_text(*args)
  end

  def self.new_label(*args)
    LibUI.new_label(*args)
  end

  def self.tab_append(tab, name, control) : Nil
    LibUI.tab_append(tab, name, to_control(control))
  end

  def self.tab_insert_at(tab, name, index, control) : Nil
    LibUI.tab_insert_at(tab, name, index, to_control(control))
  end

  def self.tab_delete(*args) : Nil
    LibUI.tab_delete(*args)
  end

  def self.tab_num_pages(*args)
    LibUI.tab_num_pages(*args)
  end

  def self.tab_margined(*args)
    LibUI.tab_margined(*args)
  end

  def self.tab_set_margined(*args) : Nil
    LibUI.tab_set_margined(*args)
  end

  def self.new_tab
    LibUI.new_tab
  end

  def self.group_title(group) : String?
    str_ptr = LibUI.group_title(group)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.group_set_title(*args) : Nil
    LibUI.group_set_title(*args)
  end

  def self.group_set_child(group, control) : Nil
    LibUI.group_set_child(group, to_control(control))
  end

  def self.group_margined(*args)
    LibUI.group_margined(*args)
  end

  def self.group_set_margined(*args) : Nil
    LibUI.group_set_margined(*args)
  end

  def self.new_group(*args)
    LibUI.new_group(*args)
  end

  def self.spinbox_value(*args)
    LibUI.spinbox_value(*args)
  end

  def self.spinbox_set_value(*args) : Nil
    LibUI.spinbox_set_value(*args)
  end

  def self.spinbox_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.spinbox_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_spinbox(*args)
    LibUI.new_spinbox(*args)
  end

  def self.slider_value(*args)
    LibUI.slider_value(*args)
  end

  def self.slider_set_value(*args) : Nil
    LibUI.slider_set_value(*args)
  end

  def self.slider_has_tool_tip(*args)
    LibUI.slider_has_tool_tip(*args)
  end

  def self.slider_set_has_tool_tip(*args) : Nil
    LibUI.slider_set_has_tool_tip(*args)
  end

  def self.slider_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.slider_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.slider_on_released(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.slider_on_released(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.slider_set_range(*args) : Nil
    LibUI.slider_set_range(*args)
  end

  def self.new_slider(*args)
    LibUI.new_slider(*args)
  end

  def self.progress_bar_value(*args)
    LibUI.progress_bar_value(*args)
  end

  def self.progress_bar_set_value(*args) : Nil
    LibUI.progress_bar_set_value(*args)
  end

  def self.new_progress_bar
    LibUI.new_progress_bar
  end

  def self.new_horizontal_separator
    LibUI.new_horizontal_separator
  end

  def self.new_vertical_separator
    LibUI.new_vertical_separator
  end

  def self.combobox_append(*args) : Nil
    LibUI.combobox_append(*args)
  end

  def self.combobox_insert_at(*args) : Nil
    LibUI.combobox_insert_at(*args)
  end

  def self.combobox_delete(*args) : Nil
    LibUI.combobox_delete(*args)
  end

  def self.combobox_clear(*args) : Nil
    LibUI.combobox_clear(*args)
  end

  def self.combobox_num_items(*args)
    LibUI.combobox_num_items(*args)
  end

  def self.combobox_selected(*args)
    LibUI.combobox_selected(*args)
  end

  def self.combobox_set_selected(*args) : Nil
    LibUI.combobox_set_selected(*args)
  end

  def self.combobox_on_selected(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.combobox_on_selected(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_combobox
    LibUI.new_combobox
  end

  def self.editable_combobox_append(*args) : Nil
    LibUI.editable_combobox_append(*args)
  end

  def self.editable_combobox_text(editable_combobox) : String?
    str_ptr = LibUI.editable_combobox_text(editable_combobox)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.editable_combobox_set_text(*args) : Nil
    LibUI.editable_combobox_set_text(*args)
  end

  def self.editable_combobox_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.editable_combobox_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_editable_combobox
    LibUI.new_editable_combobox
  end

  def self.radio_buttons_append(*args) : Nil
    LibUI.radio_buttons_append(*args)
  end

  def self.radio_buttons_selected(*args)
    LibUI.radio_buttons_selected(*args)
  end

  def self.radio_buttons_set_selected(*args) : Nil
    LibUI.radio_buttons_set_selected(*args)
  end

  def self.radio_buttons_on_selected(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.radio_buttons_on_selected(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_radio_buttons
    LibUI.new_radio_buttons
  end

  def self.date_time_picker_time(*args) : Nil
    LibUI.date_time_picker_time(*args)
  end

  def self.date_time_picker_set_time(*args) : Nil
    LibUI.date_time_picker_set_time(*args)
  end

  def self.date_time_picker_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.date_time_picker_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_date_time_picker
    LibUI.new_date_time_picker
  end

  def self.new_date_picker
    LibUI.new_date_picker
  end

  def self.new_time_picker
    LibUI.new_time_picker
  end

  def self.multiline_entry_text(multiline_entry) : String?
    str_ptr = LibUI.multiline_entry_text(multiline_entry)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.multiline_entry_set_text(*args) : Nil
    LibUI.multiline_entry_set_text(*args)
  end

  def self.multiline_entry_append(*args) : Nil
    LibUI.multiline_entry_append(*args)
  end

  def self.multiline_entry_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.multiline_entry_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.multiline_entry_read_only(*args)
    LibUI.multiline_entry_read_only(*args)
  end

  def self.multiline_entry_set_read_only(*args) : Nil
    LibUI.multiline_entry_set_read_only(*args)
  end

  def self.new_multiline_entry
    LibUI.new_multiline_entry
  end

  def self.new_non_wrapping_multiline_entry
    LibUI.new_non_wrapping_multiline_entry
  end

  def self.menu_item_enable(*args) : Nil
    LibUI.menu_item_enable(*args)
  end

  def self.menu_item_disable(*args) : Nil
    LibUI.menu_item_disable(*args)
  end

  def self.menu_item_on_clicked(sender, &callback : Pointer(LibUI::Window) -> Void)
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.menu_item_on_clicked(sender, ->(sender, window, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(window)
    end, boxed_data)
  end

  def self.menu_item_checked(*args)
    LibUI.menu_item_checked(*args)
  end

  def self.menu_item_set_checked(*args) : Nil
    LibUI.menu_item_set_checked(*args)
  end

  def self.menu_append_item(*args)
    LibUI.menu_append_item(*args)
  end

  def self.menu_append_check_item(*args)
    LibUI.menu_append_check_item(*args)
  end

  def self.menu_append_quit_item(*args)
    LibUI.menu_append_quit_item(*args)
  end

  def self.menu_append_preferences_item(*args)
    LibUI.menu_append_preferences_item(*args)
  end

  def self.menu_append_about_item(*args)
    LibUI.menu_append_about_item(*args)
  end

  def self.menu_append_separator(*args) : Nil
    LibUI.menu_append_separator(*args)
  end

  def self.new_menu(*args)
    LibUI.new_menu(*args)
  end

  def self.open_file(window) : String?
    str_ptr = LibUI.open_file(window)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.open_folder(window) : String?
    str_ptr = LibUI.open_folder(window)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.save_file(window) : String?
    str_ptr = LibUI.save_file(window)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.msg_box(*args) : Nil
    # FIXME: Workaround for Windows
    {% unless flag?(:windows) %}
      LibUI.msg_box(*args)
    {% end %}
  end

  def self.msg_box_error(*args) : Nil
    LibUI.msg_box_error(*args)
  end

  def self.area_set_size(*args) : Nil
    LibUI.area_set_size(*args)
  end

  def self.area_queue_redraw_all(*args) : Nil
    LibUI.area_queue_redraw_all(*args)
  end

  def self.area_scroll_to(*args) : Nil
    LibUI.area_scroll_to(*args)
  end

  def self.area_begin_user_window_move(*args) : Nil
    LibUI.area_begin_user_window_move(*args)
  end

  def self.area_begin_user_window_resize(*args) : Nil
    LibUI.area_begin_user_window_resize(*args)
  end

  def self.new_area(*args)
    LibUI.new_area(*args)
  end

  def self.new_scrolling_area(*args)
    LibUI.new_scrolling_area(*args)
  end

  def self.draw_new_path(*args)
    LibUI.draw_new_path(*args)
  end

  def self.draw_free_path(*args) : Nil
    LibUI.draw_free_path(*args)
  end

  def self.draw_path_new_figure(*args) : Nil
    LibUI.draw_path_new_figure(*args)
  end

  def self.draw_path_new_figure_with_arc(*args) : Nil
    LibUI.draw_path_new_figure_with_arc(*args)
  end

  def self.draw_path_line_to(*args) : Nil
    LibUI.draw_path_line_to(*args)
  end

  def self.draw_path_arc_to(*args) : Nil
    LibUI.draw_path_arc_to(*args)
  end

  def self.draw_path_bezier_to(*args) : Nil
    LibUI.draw_path_bezier_to(*args)
  end

  def self.draw_path_close_figure(*args) : Nil
    LibUI.draw_path_close_figure(*args)
  end

  def self.draw_path_add_rectangle(*args) : Nil
    LibUI.draw_path_add_rectangle(*args)
  end

  def self.draw_path_ended(*args)
    LibUI.draw_path_ended(*args)
  end

  def self.draw_path_end(*args) : Nil
    LibUI.draw_path_end(*args)
  end

  def self.draw_stroke(*args) : Nil
    LibUI.draw_stroke(*args)
  end

  def self.draw_fill(*args) : Nil
    LibUI.draw_fill(*args)
  end

  def self.draw_matrix_set_identity(*args) : Nil
    LibUI.draw_matrix_set_identity(*args)
  end

  def self.draw_matrix_translate(*args) : Nil
    LibUI.draw_matrix_translate(*args)
  end

  def self.draw_matrix_scale(*args) : Nil
    LibUI.draw_matrix_scale(*args)
  end

  def self.draw_matrix_rotate(*args) : Nil
    LibUI.draw_matrix_rotate(*args)
  end

  def self.draw_matrix_skew(*args) : Nil
    LibUI.draw_matrix_skew(*args)
  end

  def self.draw_matrix_multiply(*args) : Nil
    LibUI.draw_matrix_multiply(*args)
  end

  def self.draw_matrix_invertible(*args)
    LibUI.draw_matrix_invertible(*args)
  end

  def self.draw_matrix_invert(*args)
    LibUI.draw_matrix_invert(*args)
  end

  def self.draw_matrix_transform_point(*args) : Nil
    LibUI.draw_matrix_transform_point(*args)
  end

  def self.draw_matrix_transform_size(*args) : Nil
    LibUI.draw_matrix_transform_size(*args)
  end

  def self.draw_transform(*args) : Nil
    LibUI.draw_transform(*args)
  end

  def self.draw_clip(*args) : Nil
    LibUI.draw_clip(*args)
  end

  def self.draw_save(*args) : Nil
    LibUI.draw_save(*args)
  end

  def self.draw_restore(*args) : Nil
    LibUI.draw_restore(*args)
  end

  def self.free_attribute(*args) : Nil
    LibUI.free_attribute(*args)
  end

  def self.attribute_get_type(*args)
    LibUI.attribute_get_type(*args)
  end

  def self.new_family_attribute(*args)
    LibUI.new_family_attribute(*args)
  end

  def self.attribute_family(attribute) : String?
    str_ptr = LibUI.attribute_family(attribute)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.new_size_attribute(*args)
    LibUI.new_size_attribute(*args)
  end

  def self.attribute_size(*args)
    LibUI.attribute_size(*args)
  end

  def self.new_weight_attribute(*args)
    LibUI.new_weight_attribute(*args)
  end

  def self.attribute_weight(*args)
    LibUI.attribute_weight(*args)
  end

  def self.new_italic_attribute(*args)
    LibUI.new_italic_attribute(*args)
  end

  def self.attribute_italic(*args)
    LibUI.attribute_italic(*args)
  end

  def self.new_stretch_attribute(*args)
    LibUI.new_stretch_attribute(*args)
  end

  def self.attribute_stretch(*args)
    LibUI.attribute_stretch(*args)
  end

  def self.new_color_attribute(*args)
    LibUI.new_color_attribute(*args)
  end

  def self.attribute_color(*args) : Nil
    LibUI.attribute_color(*args)
  end

  def self.new_background_attribute(*args)
    LibUI.new_background_attribute(*args)
  end

  def self.new_underline_attribute(*args)
    LibUI.new_underline_attribute(*args)
  end

  def self.attribute_underline(*args)
    LibUI.attribute_underline(*args)
  end

  def self.new_underline_color_attribute(*args)
    LibUI.new_underline_color_attribute(*args)
  end

  def self.attribute_underline_color(*args) : Nil
    LibUI.attribute_underline_color(*args)
  end

  def self.new_open_type_features
    LibUI.new_open_type_features
  end

  def self.free_open_type_features(*args) : Nil
    LibUI.free_open_type_features(*args)
  end

  def self.open_type_features_clone(*args)
    LibUI.open_type_features_clone(*args)
  end

  def self.open_type_features_add(*args) : Nil
    LibUI.open_type_features_add(*args)
  end

  def self.open_type_features_remove(*args) : Nil
    LibUI.open_type_features_remove(*args)
  end

  def self.open_type_features_get(*args)
    LibUI.open_type_features_get(*args)
  end

  def self.open_type_features_for_each(sender, &callback : (Pointer(Void), LibC::Char, LibC::Char, LibC::Char, LibC::Char, Int32) -> Void)
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.open_type_features_for_each(sender, ->(otf, a, b, c, d, value, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(otf)
    end, boxed_data)
  end

  def self.new_features_attribute(*args)
    LibUI.new_features_attribute(*args)
  end

  def self.attribute_features(*args)
    LibUI.attribute_features(*args)
  end

  def self.new_attributed_string(*args)
    LibUI.new_attributed_string(*args)
  end

  def self.free_attributed_string(*args) : Nil
    LibUI.free_attributed_string(*args)
  end

  def self.attributed_string_string(attributed_string) : String?
    str_ptr = LibUI.attributed_string_string(attributed_string)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.attributed_string_len(*args)
    LibUI.attributed_string_len(*args)
  end

  def self.attributed_string_append_unattributed(*args) : Nil
    LibUI.attributed_string_append_unattributed(*args)
  end

  def self.attributed_string_insert_at_unattributed(*args) : Nil
    LibUI.attributed_string_insert_at_unattributed(*args)
  end

  def self.attributed_string_delete(*args) : Nil
    LibUI.attributed_string_delete(*args)
  end

  def self.attributed_string_set_attribute(*args) : Nil
    LibUI.attributed_string_set_attribute(*args)
  end

  def self.attributed_string_for_each_attribute(sender, &callback : (Pointer(Void), Pointer(LibUI::Attribute), SizeT, SizeT, Pointer(Void)) -> Void)
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.attributed_string_for_each_attribute(sender, ->(sender, attr, start, end_, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(attr, start, end_)
    end, boxed_data)
  end

  def self.attributed_string_num_graphemes(*args)
    LibUI.attributed_string_num_graphemes(*args)
  end

  def self.attributed_string_byte_index_to_grapheme(*args)
    LibUI.attributed_string_byte_index_to_grapheme(*args)
  end

  def self.attributed_string_grapheme_to_byte_index(*args)
    LibUI.attributed_string_grapheme_to_byte_index(*args)
  end

  def self.load_control_font(*args) : Nil
    LibUI.load_control_font(*args)
  end

  def self.free_font_descriptor(*args) : Nil
    LibUI.free_font_descriptor(*args)
  end

  def self.draw_new_text_layout(*args)
    LibUI.draw_new_text_layout(*args)
  end

  def self.draw_free_text_layout(*args) : Nil
    LibUI.draw_free_text_layout(*args)
  end

  def self.draw_text(*args) : Nil
    LibUI.draw_text(*args)
  end

  def self.draw_text_layout_extents(*args) : Nil
    LibUI.draw_text_layout_extents(*args)
  end

  def self.font_button_font(*args) : Nil
    LibUI.font_button_font(*args)
  end

  def self.font_button_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.font_button_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_font_button
    LibUI.new_font_button
  end

  def self.free_font_button_font(*args) : Nil
    LibUI.free_font_button_font(*args)
  end

  def self.color_button_color(*args) : Nil
    LibUI.color_button_color(*args)
  end

  def self.color_button_set_color(*args) : Nil
    LibUI.color_button_set_color(*args)
  end

  def self.color_button_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.color_button_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_color_button
    LibUI.new_color_button
  end

  def self.form_append(form, label, control, stretchy) : Nil
    LibUI.form_append(form, label, to_control(control), stretchy)
  end

  def self.form_num_children(*args)
    LibUI.form_num_children(*args)
  end

  def self.form_delete(*args) : Nil
    LibUI.form_delete(*args)
  end

  def self.form_padded(*args)
    LibUI.form_padded(*args)
  end

  def self.form_set_padded(*args) : Nil
    LibUI.form_set_padded(*args)
  end

  def self.new_form
    LibUI.new_form
  end

  def self.grid_append(grid, control, left, top, xspan, yspan, hexpand, halign, vexpand, valign) : Nil
    LibUI.grid_append(grid, to_control(control), left, top, xspan, yspan, hexpand, halign, vexpand, valign)
  end

  def self.grid_insert_at(grid, control, existing, at, xspan, yspan, hexpand, halign, vexpand, valign) : Nil
    LibUI.grid_insert_at(grid, to_control(control), to_control(existing), at, xspan, yspan, hexpand, halign, vexpand, valign)
  end

  def self.grid_padded(*args)
    LibUI.grid_padded(*args)
  end

  def self.grid_set_padded(*args) : Nil
    LibUI.grid_set_padded(*args)
  end

  def self.new_grid
    LibUI.new_grid
  end

  def self.new_image(*args)
    LibUI.new_image(*args)
  end

  def self.free_image(*args) : Nil
    LibUI.free_image(*args)
  end

  def self.image_append(*args) : Nil
    LibUI.image_append(*args)
  end

  def self.free_table_value(*args) : Nil
    LibUI.free_table_value(*args)
  end

  def self.table_value_get_type(*args)
    LibUI.table_value_get_type(*args)
  end

  def self.new_table_value_string(*args)
    LibUI.new_table_value_string(*args)
  end

  def self.table_value_string(table_value) : String?
    str_ptr = LibUI.table_value_string(table_value)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.new_table_value_image(*args)
    LibUI.new_table_value_image(*args)
  end

  def self.table_value_image(*args)
    LibUI.table_value_image(*args)
  end

  def self.new_table_value_int(*args)
    LibUI.new_table_value_int(*args)
  end

  def self.table_value_int(*args)
    LibUI.table_value_int(*args)
  end

  def self.new_table_value_color(*args)
    LibUI.new_table_value_color(*args)
  end

  def self.table_value_color(*args) : Nil
    LibUI.table_value_color(*args)
  end

  def self.new_table_model(*args)
    LibUI.new_table_model(*args)
  end

  def self.free_table_model(*args) : Nil
    LibUI.free_table_model(*args)
  end

  def self.table_model_row_inserted(*args) : Nil
    LibUI.table_model_row_inserted(*args)
  end

  def self.table_model_row_changed(*args) : Nil
    LibUI.table_model_row_changed(*args)
  end

  def self.table_model_row_deleted(*args) : Nil
    LibUI.table_model_row_deleted(*args)
  end

  def self.table_append_text_column(*args) : Nil
    LibUI.table_append_text_column(*args)
  end

  def self.table_append_image_column(*args) : Nil
    LibUI.table_append_image_column(*args)
  end

  def self.table_append_image_text_column(*args) : Nil
    LibUI.table_append_image_text_column(*args)
  end

  def self.table_append_checkbox_column(*args) : Nil
    LibUI.table_append_checkbox_column(*args)
  end

  def self.table_append_checkbox_text_column(*args) : Nil
    LibUI.table_append_checkbox_text_column(*args)
  end

  def self.table_append_progress_bar_column(*args) : Nil
    LibUI.table_append_progress_bar_column(*args)
  end

  def self.table_append_button_column(*args) : Nil
    LibUI.table_append_button_column(*args)
  end

  def self.table_header_visible(*args)
    LibUI.table_header_visible(*args)
  end

  def self.table_header_set_visible(*args) : Nil
    LibUI.table_header_set_visible(*args)
  end

  def self.new_table(*args)
    LibUI.new_table(*args)
  end

  def self.table_on_row_clicked(sender, &callback : LibC::Int -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.table_on_row_clicked(sender, ->(sender, row, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(row)
    end, boxed_data)
  end

  def self.table_on_row_double_clicked(sender, &callback : LibC::Int -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.table_on_row_double_clicked(sender, ->(sender, row, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(row)
    end, boxed_data)
  end

  def self.table_header_set_sort_indicator(*args) : Nil
    LibUI.table_header_set_sort_indicator(*args)
  end

  def self.table_header_sort_indicator(*args)
    LibUI.table_header_sort_indicator(*args)
  end

  def self.table_header_on_clicked(sender, &callback : LibC::Int -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.table_header_on_clicked(sender, ->(sender, column, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(column)
    end, boxed_data)
  end

  def self.table_column_width(*args)
    LibUI.table_column_width(*args)
  end

  def self.table_column_set_width(*args) : Nil
    LibUI.table_column_set_width(*args)
  end

  def self.table_get_selection_mode(*args)
    LibUI.table_get_selection_mode(*args)
  end

  def self.table_set_selection_mode(*args) : Nil
    LibUI.table_set_selection_mode(*args)
  end

  def self.table_on_selection_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.table_on_selection_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.table_get_selection(*args)
    LibUI.table_get_selection(*args)
  end

  def self.table_set_selection(*args) : Nil
    LibUI.table_set_selection(*args)
  end

  def self.free_table_selection(*args) : Nil
    LibUI.free_table_selection(*args)
  end
end
