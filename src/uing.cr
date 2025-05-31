require "./uing/version"
require "./uing/lib_ui/lib_ui"
require "./uing/tm"

require "./uing/*"
require "./uing/area/*"
require "./uing/attribute/*"
require "./uing/grid/*"
require "./uing/table/*"

module UIng
  # uiInitOptions is not used (but it is required)
  # See https://github.com/libui-ng/libui-ng/issues/208
  @@init_options = Pointer(LibUI::InitOptions).malloc

  # Global storage for special API callback boxes to prevent GC collection
  # This is a workaround for low-level APIs that don't have instance-level management
  # WARNING: This may cause memory leaks if callbacks are not properly cleaned up
  @@special_callback_boxes = [] of Pointer(Void)

  # Convert control to Pointer(LibUI::Control)
  private def self.to_control(control)
    if control.is_a?(Pointer)
      control.as(Pointer(LibUI::Control))
    else
      control.to_unsafe.as(Pointer(LibUI::Control))
    end
  end

  # Convert string pointer to Crystal string
  # and free the pointer
  private def self.string_from_pointer(str_ptr) : String?
    return nil if str_ptr.null?
    str = String.new(str_ptr)
    LibUI.free_text(str_ptr)
    str
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

  def self.main_step(wait) : Bool
    LibUI.main_step(wait)
  end

  def self.quit : Nil
    LibUI.quit
  end

  def self.queue_main(&callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    @@special_callback_boxes << boxed_data
    LibUI.queue_main(->(data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.timer(sender, &callback : -> LibC::Int) : Nil
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    @@special_callback_boxes << boxed_data
    LibUI.timer(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.on_should_quit(&callback : -> LibC::Int) : Nil
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    @@special_callback_boxes << boxed_data
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

  def self.control_visible(control) : Bool
    LibUI.control_visible(to_control(control))
  end

  def self.control_show(control) : Nil
    LibUI.control_show(to_control(control))
  end

  def self.control_hide(control) : Nil
    LibUI.control_hide(to_control(control))
  end

  def self.control_enabled(control) : Bool
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

  def self.control_enabled_to_user(control) : Bool
    LibUI.control_enabled_to_user(to_control(control))
  end

  def self.user_bug_cannot_set_parent_on_toplevel(type) : Nil
    LibUI.user_bug_cannot_set_parent_on_toplevel(type)
  end

  def self.window_title(window) : String?
    str_ptr = LibUI.window_title(window)
    string_from_pointer(str_ptr)
  end

  def self.window_set_title(window, title) : Nil
    LibUI.window_set_title(window, title)
  end

  def self.window_position(window, x, y) : Nil
    LibUI.window_position(window, x, y)
  end

  def self.window_set_position(window, x, y) : Nil
    LibUI.window_set_position(window, x, y)
  end

  def self.window_on_position_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.window_on_position_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.window_content_size(window, width, height) : Nil
    LibUI.window_content_size(window, width, height)
  end

  def self.window_set_content_size(window, width, height) : Nil
    LibUI.window_set_content_size(window, width, height)
  end

  def self.window_fullscreen(window) : LibC::Int
    LibUI.window_fullscreen(window)
  end

  def self.window_set_fullscreen(window, fullscreen) : Nil
    LibUI.window_set_fullscreen(window, fullscreen)
  end

  def self.window_on_content_size_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.window_on_content_size_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.window_on_closing(sender, boxed_data : Pointer(Void), &callback : -> Bool) : Nil
    LibUI.window_on_closing(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.window_on_focus_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.window_on_focus_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.window_focused(window) : LibC::Int
    LibUI.window_focused(window)
  end

  def self.window_borderless(window) : LibC::Int
    LibUI.window_borderless(window)
  end

  def self.window_set_borderless(window, borderless) : Nil
    LibUI.window_set_borderless(window, borderless)
  end

  def self.window_set_child(window, control) : Nil
    LibUI.window_set_child(window, to_control(control))
  end

  def self.window_margined(window) : LibC::Int
    LibUI.window_margined(window)
  end

  def self.window_set_margined(window, margined) : Nil
    LibUI.window_set_margined(window, margined)
  end

  def self.window_resizeable(window) : LibC::Int
    LibUI.window_resizeable(window)
  end

  def self.window_set_resizeable(window, resizeable) : Nil
    LibUI.window_set_resizeable(window, resizeable)
  end

  def self.new_window(title, width, height, has_menu)
    ref_ptr = LibUI.new_window(title, width, height, has_menu)
    Window.new(ref_ptr)
  end

  def self.button_text(button) : String?
    str_ptr = LibUI.button_text(button)
    string_from_pointer(str_ptr)
  end

  def self.button_set_text(button, text) : Nil
    LibUI.button_set_text(button, text)
  end

  def self.button_on_clicked(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.button_on_clicked(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_button(text) : Button
    ref_ptr = LibUI.new_button(text)
    Button.new(ref_ptr)
  end

  def self.box_append(box, control, stretchy) : Nil
    LibUI.box_append(box, to_control(control), stretchy)
  end

  def self.box_num_children(button) : LibC::Int
    LibUI.box_num_children(button)
  end

  def self.box_delete(box, index) : Nil
    LibUI.box_delete(box, index)
  end

  def self.box_padded(button) : LibC::Int
    LibUI.box_padded(button)
  end

  def self.box_set_padded(box, padded) : Nil
    LibUI.box_set_padded(box, padded)
  end

  def self.new_horizontal_box : UIng::Box
    ref_ptr = LibUI.new_horizontal_box
    UIng::Box.new(ref_ptr)
  end

  def self.new_vertical_box : UIng::Box
    ref_ptr = LibUI.new_vertical_box
    UIng::Box.new(ref_ptr)
  end

  def self.checkbox_text(checkbox) : String?
    str_ptr = LibUI.checkbox_text(checkbox)
    string_from_pointer(str_ptr)
  end

  def self.checkbox_set_text(checkbox, text) : Nil
    LibUI.checkbox_set_text(checkbox, text)
  end

  def self.checkbox_on_toggled(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.checkbox_on_toggled(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.checkbox_checked(checkbox) : Bool
    LibUI.checkbox_checked(checkbox)
  end

  def self.checkbox_set_checked(checkbox, checked) : Nil
    LibUI.checkbox_set_checked(checkbox, checked)
  end

  def self.new_checkbox(text) : Checkbox
    ref_ptr = LibUI.new_checkbox(text)
    Checkbox.new(ref_ptr)
  end

  def self.entry_text(entry) : String?
    str_ptr = LibUI.entry_text(entry)
    string_from_pointer(str_ptr)
  end

  def self.entry_set_text(entry, text) : Nil
    LibUI.entry_set_text(entry, text)
  end

  def self.entry_on_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.entry_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.entry_read_only(entry) : LibC::Int
    LibUI.entry_read_only(entry)
  end

  def self.entry_set_read_only(entry, readonly) : Nil
    LibUI.entry_set_read_only(entry, readonly)
  end

  def self.new_entry : Entry
    ref_ptr = LibUI.new_entry
    Entry.new(ref_ptr)
  end

  def self.new_password_entry : Entry
    ref_ptr = LibUI.new_password_entry
    Entry.new(ref_ptr)
  end

  def self.new_search_entry : Entry
    ref_ptr LibUI.new_search_entry
    Entry.new(ref_ptr)
  end

  def self.label_text(label) : String?
    str_ptr = LibUI.label_text(label)
    string_from_pointer(str_ptr)
  end

  def self.label_set_text(label, text) : Nil
    LibUI.label_set_text(label, text)
  end

  def self.new_label(text) : Label
    ref_ptr = LibUI.new_label(text)
    Label.new(ref_ptr)
  end

  def self.tab_append(tab, name, control) : Nil
    LibUI.tab_append(tab, name, to_control(control))
  end

  def self.tab_insert_at(tab, name, index, control) : Nil
    LibUI.tab_insert_at(tab, name, index, to_control(control))
  end

  def self.tab_delete(tab, index) : Nil
    LibUI.tab_delete(tab, index)
  end

  def self.tab_num_pages(tab) : LibC::Int
    LibUI.tab_num_pages(tab)
  end

  def self.tab_margined(tab, index) : LibC::Int
    LibUI.tab_margined(tab, index)
  end

  def self.tab_set_margined(tab, index, margined) : Nil
    LibUI.tab_set_margined(tab, index, margined)
  end

  def self.new_tab : Tab
    ref_ptr = LibUI.new_tab
    Tab.new(ref_ptr)
  end

  def self.group_title(group) : String?
    str_ptr = LibUI.group_title(group)
    string_from_pointer(str_ptr)
  end

  def self.group_set_title(group, title) : Nil
    LibUI.group_set_title(group, title)
  end

  def self.group_set_child(group, control) : Nil
    LibUI.group_set_child(group, to_control(control))
  end

  def self.group_margined(group) : LibC::Int
    LibUI.group_margined(group)
  end

  def self.group_set_margined(group, margined) : Nil
    LibUI.group_set_margined(group, margined)
  end

  def self.new_group(title) : Group
    ref_ptr = LibUI.new_group(title)
    Group.new(ref_ptr)
  end

  def self.spinbox_value(spinbox) : LibC::Int
    LibUI.spinbox_value(spinbox)
  end

  def self.spinbox_set_value(spinbox, value) : Nil
    LibUI.spinbox_set_value(spinbox, value)
  end

  def self.spinbox_on_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.spinbox_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_spinbox(min, max) : Spinbox
    ref_ptr = LibUI.new_spinbox(min, max)
    Spinbox.new(ref_ptr)
  end

  def self.slider_value(slider) : LibC::Int
    LibUI.slider_value(slider)
  end

  def self.slider_set_value(slider, value) : Nil
    LibUI.slider_set_value(slider, value)
  end

  def self.slider_has_tool_tip(slider) : LibC::Int
    LibUI.slider_has_tool_tip(slider)
  end

  def self.slider_set_has_tool_tip(slider, has_tool_tip) : Nil
    LibUI.slider_set_has_tool_tip(slider, has_tool_tip)
  end

  def self.slider_on_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.slider_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.slider_on_released(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.slider_on_released(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.slider_set_range(slider, min, max) : Nil
    LibUI.slider_set_range(slider, min, max)
  end

  def self.new_slider(min, max) : Slider
    ref_ptr = LibUI.new_slider(min, max)
    Slider.new(ref_ptr)
  end

  def self.progress_bar_value(progress_bar) : LibC::Int
    LibUI.progress_bar_value(progress_bar)
  end

  def self.progress_bar_set_value(progress_bar, n) : Nil
    LibUI.progress_bar_set_value(progress_bar, n)
  end

  def self.new_progress_bar : ProgressBar
    ref_ptr = LibUI.new_progress_bar
    ProgressBar.new(ref_ptr)
  end

  def self.new_horizontal_separator : Separator
    ref_ptr = LibUI.new_horizontal_separator
    Separator.new(ref_ptr)
  end

  def self.new_vertical_separator : Separator
    ref_ptr = LibUI.new_vertical_separator
    Separator.new(ref_ptr)
  end

  def self.combobox_append(combobox, text) : Nil
    LibUI.combobox_append(combobox, text)
  end

  def self.combobox_insert_at(combobox, index, text) : Nil
    LibUI.combobox_insert_at(combobox, index, text)
  end

  def self.combobox_delete(combobox, index) : Nil
    LibUI.combobox_delete(combobox, index)
  end

  def self.combobox_clear(combobox) : Nil
    LibUI.combobox_clear(combobox)
  end

  def self.combobox_num_items(combobox) : LibC::Int
    LibUI.combobox_num_items(combobox)
  end

  def self.combobox_selected(combobox) : LibC::Int
    LibUI.combobox_selected(combobox)
  end

  def self.combobox_set_selected(combobox) : Nil
    LibUI.combobox_set_selected(combobox)
  end

  def self.combobox_on_selected(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.combobox_on_selected(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_combobox : Combobox
    ref_ptr = LibUI.new_combobox
    Combobox.new(ref_ptr)
  end

  def self.editable_combobox_append(editable_combobox, text) : Nil
    LibUI.editable_combobox_append(editable_combobox, text)
  end

  def self.editable_combobox_text(editable_combobox) : String?
    str_ptr = LibUI.editable_combobox_text(editable_combobox)
    string_from_pointer(str_ptr)
  end

  def self.editable_combobox_set_text(editable_combobox, text) : Nil
    LibUI.editable_combobox_set_text(editable_combobox, text)
  end

  def self.editable_combobox_on_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.editable_combobox_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_editable_combobox : EditableCombobox
    ref_ptr = LibUI.new_editable_combobox
    EditableCombobox.new(ref_ptr)
  end

  def self.radio_buttons_append(radio_buttons, text) : Nil
    LibUI.radio_buttons_append(radio_buttons, text)
  end

  def self.radio_buttons_selected(radio_buttons) : LibC::Int
    LibUI.radio_buttons_selected(radio_buttons)
  end

  def self.radio_buttons_set_selected(radio_buttons, index) : Nil
    LibUI.radio_buttons_set_selected(radio_buttons, index)
  end

  def self.radio_buttons_on_selected(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.radio_buttons_on_selected(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_radio_buttons : RadioButtons
    ref_ptr = LibUI.new_radio_buttons
    RadioButtons.new(ref_ptr)
  end

  def self.date_time_picker_time(date_time_picker, time) : Nil
    LibUI.date_time_picker_time(date_time_picker, time)
  end

  def self.date_time_picker_set_time(date_time_picker, time) : Nil
    LibUI.date_time_picker_set_time(date_time_picker, time)
  end

  def self.date_time_picker_on_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.date_time_picker_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_date_time_picker : DateTimePicker
    ref_ptr = LibUI.new_date_time_picker
    DateTimePicker.new(ref_ptr)
  end

  def self.new_date_picker : DateTimePicker
    ref_ptr = LibUI.new_date_picker
    DateTimePicker.new(ref_ptr)
  end

  def self.new_time_picker : DateTimePicker
    ref_ptr = LibUI.new_time_picker
    DateTimePicker.new(ref_ptr)
  end

  def self.multiline_entry_text(multiline_entry) : String?
    str_ptr = LibUI.multiline_entry_text(multiline_entry)
    string_from_pointer(str_ptr)
  end

  def self.multiline_entry_set_text(multiline_entry, text) : Nil
    LibUI.multiline_entry_set_text(multiline_entry, text)
  end

  def self.multiline_entry_append(multiline_entry, text) : Nil
    LibUI.multiline_entry_append(multiline_entry, text)
  end

  def self.multiline_entry_on_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.multiline_entry_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.multiline_entry_read_only(multiline_entry) : LibC::Int
    LibUI.multiline_entry_read_only(multiline_entry)
  end

  def self.multiline_entry_set_read_only(multiline_entry, readonly) : Nil
    LibUI.multiline_entry_set_read_only(multiline_entry, readonly)
  end

  def self.new_multiline_entry : MultilineEntry
    ref_ptr = LibUI.new_multiline_entry
    MultilineEntry.new(ref_ptr)
  end

  def self.new_non_wrapping_multiline_entry : MultilineEntry
    ref_ptr = LibUI.new_non_wrapping_multiline_entry
    MultilineEntry.new(ref_ptr)
  end

  def self.menu_item_enable(menu_item) : Nil
    LibUI.menu_item_enable(menu_item)
  end

  def self.menu_item_disable(menu_item) : Nil
    LibUI.menu_item_disable(menu_item)
  end

  def self.menu_item_on_clicked(sender, boxed_data : Pointer(Void), &callback : UIng::Window -> Void)
    callback2 = ->(w : Pointer(LibUI::Window)) {
      callback.call(UIng::Window.new(w))
    }
    LibUI.menu_item_on_clicked(sender, ->(sender, window, data) do
      data_as_callback = ::Box(typeof(callback2)).unbox(data)
      data_as_callback.call(window)
    end, boxed_data)
  end

  def self.menu_item_checked(menu_item) : Bool
    LibUI.menu_item_checked(menu_item)
  end

  def self.menu_item_set_checked(menu_item, checked) : Nil
    LibUI.menu_item_set_checked(menu_item, checked)
  end

  def self.menu_append_item(menu, name) : MenuItem
    ref_ptr = LibUI.menu_append_item(menu, name)
    MenuItem.new(ref_ptr)
  end

  def self.menu_append_check_item(menu, name) : MenuItem
    ref_ptr = LibUI.menu_append_check_item(menu, name)
    MenuItem.new(ref_ptr)
  end

  def self.menu_append_quit_item(menu) : MenuItem
    ref_ptr = LibUI.menu_append_quit_item(menu)
    MenuItem.new(ref_ptr)
  end

  def self.menu_append_preferences_item(menu) : MenuItem
    ref_ptr = LibUI.menu_append_preferences_item(menu)
    MenuItem.new(ref_ptr)
  end

  def self.menu_append_about_item(menu) : MenuItem
    ref_ptr = LibUI.menu_append_about_item(menu)
    MenuItem.new(ref_ptr)
  end

  def self.menu_append_separator(menu) : Nil
    LibUI.menu_append_separator(menu)
  end

  def self.new_menu(name) : Menu
    ref_ptr = LibUI.new_menu(name)
    Menu.new(ref_ptr)
  end

  def self.open_file(window) : String?
    str_ptr = LibUI.open_file(window)
    string_from_pointer(str_ptr)
  end

  def self.open_folder(window) : String?
    str_ptr = LibUI.open_folder(window)
    string_from_pointer(str_ptr)
  end

  def self.save_file(window) : String?
    str_ptr = LibUI.save_file(window)
    string_from_pointer(str_ptr)
  end

  def self.msg_box(parent, title, description) : Nil
    LibUI.msg_box(parent, title, description)
  end

  def self.msg_box_error(parent, title, description) : Nil
    LibUI.msg_box_error(parent, title, description)
  end

  def self.area_set_size(area, width, height) : Nil
    LibUI.area_set_size(area, width, height)
  end

  def self.area_queue_redraw_all(area) : Nil
    LibUI.area_queue_redraw_all(area)
  end

  def self.area_scroll_to(area, x, y, width, height) : Nil
    LibUI.area_scroll_to(area, x, y, width, height)
  end

  def self.area_begin_user_window_move(area) : Nil
    LibUI.area_begin_user_window_move(area)
  end

  def self.area_begin_user_window_resize(area, edge) : Nil
    LibUI.area_begin_user_window_resize(area, edge)
  end

  def self.new_area(area_handler) : Area
    ref_ptr = LibUI.new_area(area_handler)
    Area.new(ref_ptr)
  end

  def self.new_scrolling_area(area_handler, width, height) : Area
    ref_ptr = LibUI.new_scrolling_area(area_handler, width, height)
    Area.new(ref_ptr)
  end

  def self.draw_new_path(fill_mode) : DrawPath
    ref_ptr = LibUI.draw_new_path(fill_mode)
    DrawPath.new(ref_ptr)
  end

  def self.draw_free_path(draw_path) : Nil
    LibUI.draw_free_path(draw_path)
  end

  def self.draw_path_new_figure(draw_path, x, y) : Nil
    LibUI.draw_path_new_figure(draw_path, x, y)
  end

  def self.draw_path_new_figure_with_arc(draw_path, x_center, y_center, radius, start_angle, sweep, negative) : Nil
    LibUI.draw_path_new_figure_with_arc(draw_path, x_center, y_center, radius, start_angle, sweep, negative)
  end

  def self.draw_path_line_to(draw_path, x, y) : Nil
    LibUI.draw_path_line_to(draw_path, x, y)
  end

  def self.draw_path_arc_to(draw_path, x_center, y_center, radius, start_angle, sweep, negative) : Nil
    LibUI.draw_path_arc_to(draw_path, x_center, y_center, radius, start_angle, sweep, negative)
  end

  def self.draw_path_bezier_to(draw_path, c1x, c1y, c2x, c2y, end_x, end_y) : Nil
    LibUI.draw_path_bezier_to(draw_path, c1x, c1y, c2x, c2y, end_x, end_y)
  end

  def self.draw_path_close_figure(draw_path) : Nil
    LibUI.draw_path_close_figure(draw_path)
  end

  def self.draw_path_add_rectangle(draw_path, x, y, width, height) : Nil
    LibUI.draw_path_add_rectangle(draw_path, x, y, width, height)
  end

  def self.draw_path_ended(draw_path) : LibC::Int
    LibUI.draw_path_ended(draw_path)
  end

  def self.draw_path_end(draw_path) : Nil
    LibUI.draw_path_end(draw_path)
  end

  def self.draw_stroke(draw_context, draw_path, dra_brush, draw_stroke_params) : Nil
    LibUI.draw_stroke(draw_context, draw_path, dra_brush, draw_stroke_params)
  end

  def self.draw_fill(draw_context, draw_path, draw_brush) : Nil
    LibUI.draw_fill(draw_context, draw_path, draw_brush)
  end

  def self.draw_matrix_set_identity(draw_matrix) : Nil
    LibUI.draw_matrix_set_identity(draw_matrix)
  end

  def self.draw_matrix_translate(draw_matrix, x, y) : Nil
    LibUI.draw_matrix_translate(draw_matrix, x, y)
  end

  def self.draw_matrix_scale(draw_matrix, x_center, y_center, x, y) : Nil
    LibUI.draw_matrix_scale(draw_matrix, x_center, y_center, x, y)
  end

  def self.draw_matrix_rotate(draw_matrix, x, y, amount) : Nil
    LibUI.draw_matrix_rotate(draw_matrix, x, y, amount)
  end

  def self.draw_matrix_skew(draw_matrix, x, y, x_amount, y_amount) : Nil
    LibUI.draw_matrix_skew(draw_matrix, x, y, x_amount, y_amount)
  end

  def self.draw_matrix_multiply(dest, src) : Nil
    LibUI.draw_matrix_multiply(dest, src)
  end

  def self.draw_matrix_invertible(draw_matrix) : LibC::Int
    LibUI.draw_matrix_invertible(draw_matrix)
  end

  def self.draw_matrix_invert(draw_matrix) : LibC::Int
    LibUI.draw_matrix_invert(draw_matrix)
  end

  def self.draw_matrix_transform_point(draw_matrix, x, y) : Nil
    LibUI.draw_matrix_transform_point(draw_matrix, x, y)
  end

  def self.draw_matrix_transform_size(draw_matrix, x, y) : Nil
    LibUI.draw_matrix_transform_size(draw_matrix, x, y)
  end

  def self.draw_transform(draw_context, draw_matrix) : Nil
    LibUI.draw_transform(draw_context, draw_matrix)
  end

  def self.draw_clip(draw_context, draw_path) : Nil
    LibUI.draw_clip(draw_context, draw_path)
  end

  def self.draw_save(draw_context) : Nil
    LibUI.draw_save(draw_context)
  end

  def self.draw_restore(draw_context) : Nil
    LibUI.draw_restore(draw_context)
  end

  def self.free_attribute(attribute) : Nil
    LibUI.free_attribute(attribute)
  end

  def self.attribute_get_type(attribute) : AttributeType
    LibUI.attribute_get_type(attribute)
  end

  def self.new_family_attribute(family) : Attribute
    ref_ptr = LibUI.new_family_attribute(family)
    Attribute.new(ref_ptr)
  end

  def self.attribute_family(attribute) : String?
    str_ptr = LibUI.attribute_family(attribute)
    # The returned string is owned by the attribute
    # and should not be freed (probably)
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.new_size_attribute(size) : Attribute
    str_ptr = LibUI.new_size_attribute(size)
    Attribute.new(ref_ptr)
  end

  def self.attribute_size(attribute) : LibC::Double
    LibUI.attribute_size(attribute)
  end

  def self.new_weight_attribute(weight) : Attribute
    ref_ptr = LibUI.new_weight_attribute(weight)
    Attribute.new(ref_ptr)
  end

  def self.attribute_weight(attribute) : TextWeight
    LibUI.attribute_weight(attribute)
  end

  def self.new_italic_attribute(test_italic) : Attribute
    LibUI.new_italic_attribute(test_italic)
  end

  def self.attribute_italic(attribute) : TextItalic
    LibUI.attribute_italic(attribute)
  end

  def self.new_stretch_attribute(text_search) : Attribute
    LibUI.new_stretch_attribute(text_search)
  end

  def self.attribute_stretch(attribute) : TextStretch
    LibUI.attribute_stretch(attribute)
  end

  def self.new_color_attribute(r, g, b, a) : Attribute
    ref_ptr = LibUI.new_color_attribute(r, g, b, a)
    Attribute.new(ref_ptr)
  end

  def self.attribute_color(attribute, r, g, b, a) : Nil
    LibUI.attribute_color(attribute, r, g, b, a)
  end

  def self.new_background_attribute(r, g, b, a) : Attribute
    LibUI.new_background_attribute(r, g, b, a)
  end

  def self.new_underline_attribute(underline) : Attribute
    LibUI.new_underline_attribute(underline)
  end

  def self.attribute_underline(attribute) : Underline
    LibUI.attribute_underline(attribute)
  end

  def self.new_underline_color_attribute(underline_color, r, g, b, a) : Attribute
    LibUI.new_underline_color_attribute(underline_color, r, g, b, a)
  end

  def self.attribute_underline_color(attribute, underline_color, r, g, b, a) : Nil
    LibUI.attribute_underline_color(attribute, underline_color, r, g, b, a)
  end

  def self.new_open_type_features : OpenTypeFeatures
    ref_ptr = LibUI.new_open_type_features
    OpenTypeFeatures.new(ref_ptr)
  end

  def self.free_open_type_features(open_type_features) : Nil
    LibUI.free_open_type_features(open_type_features)
  end

  def self.open_type_features_clone(open_type_features) : OpenTypeFeatures
    ref_ptr = LibUI.open_type_features_clone(open_type_features)
    OpenTypeFeatures.new(ref_ptr)
  end

  def self.open_type_features_add(open_type_features, a, b, c, d, value) : Nil
    LibUI.open_type_features_add(open_type_features, a, b, c, d, value)
  end

  def self.open_type_features_remove(open_type_features, a, b, c, d) : Nil
    LibUI.open_type_features_remove(open_type_features, a, b, c, d)
  end

  def self.open_type_features_get(open_type_features, a, b, c, d, value) : LibC::Int
    LibUI.open_type_features_get(open_type_features, a, b, c, d, value)
  end

  def self.open_type_features_for_each(sender, &callback : (Pointer(Void), LibC::Char, LibC::Char, LibC::Char, LibC::Char, Int32) -> Void)
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    # NOTE: This may cause memory leaks for long-running applications
    @@special_callback_boxes << boxed_data
    LibUI.open_type_features_for_each(sender, ->(otf, a, b, c, d, value, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(otf)
    end, boxed_data)
  end

  def self.new_features_attribute(open_type_features) : Attribute
    ref_ptr = LibUI.new_features_attribute(open_type_features)
    Attribute.new(ref_ptr)
  end

  def self.attribute_features(attribute) : OpenTypeFeatures
    ref_ptr = LibUI.attribute_features(attribute)
    OpenTypeFeatures.new(ref_ptr)
  end

  def self.new_attributed_string(text) : AttributedString
    ref_ptr = LibUI.new_attributed_string(text)
    AttributedString.new(ref_ptr)
  end

  def self.free_attributed_string(attributed_string) : Nil
    LibUI.free_attributed_string(attributed_string)
    attributed_string.released = true
  end

  def self.attributed_string_string(attributed_string) : String?
    str_ptr = LibUI.attributed_string_string(attributed_string)
    # The returned string is owned by the attributed string?
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.attributed_string_len(attributed_string) : LibC::SizeT
    LibUI.attributed_string_len(attributed_string)
  end

  def self.attributed_string_append_unattributed(attributed_string, text) : Nil
    LibUI.attributed_string_append_unattributed(attributed_string, text)
  end

  def self.attributed_string_insert_at_unattributed(attributed_string, text, at) : Nil
    LibUI.attributed_string_insert_at_unattributed(attributed_string, text, at)
  end

  def self.attributed_string_delete(attributed_string, start, end_) : Nil
    LibUI.attributed_string_delete(attributed_string, start, end_)
  end

  def self.attributed_string_set_attribute(attributed_string, attribute, start, end_) : Nil
    LibUI.attributed_string_set_attribute(attributed_string, attribute, start, end_)
  end

  def self.attributed_string_for_each_attribute(sender, &callback : (Pointer(Void), Pointer(LibUI::Attribute), SizeT, SizeT, Pointer(Void)) -> Void)
    boxed_data = ::Box.box(callback)
    # Store in global array to prevent GC collection during callback execution
    # NOTE: This may cause memory leaks for long-running applications
    @@special_callback_boxes << boxed_data
    LibUI.attributed_string_for_each_attribute(sender, ->(sender, attr, start, end_, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(attr, start, end_)
    end, boxed_data)
  end

  def self.attributed_string_num_graphemes(attributed_string) : LibC::SizeT
    LibUI.attributed_string_num_graphemes(attributed_string)
  end

  def self.attributed_string_byte_index_to_grapheme(attributed_string, pos) : LibC::SizeT
    LibUI.attributed_string_byte_index_to_grapheme(attributed_string, pos)
  end

  def self.attributed_string_grapheme_to_byte_index(attributed_string, pos) : LibC::SizeT
    LibUI.attributed_string_grapheme_to_byte_index(attributed_string, pos)
  end

  def self.load_control_font(font_descriptor) : Nil
    LibUI.load_control_font(font_descriptor)
  end

  def self.free_font_descriptor(font_descriptor) : Nil
    LibUI.free_font_descriptor(font_descriptor)
  end

  def self.draw_new_text_layout(draw_text_layout_params) : DrawTextLayout
    ref_ptr = LibUI.draw_new_text_layout(draw_text_layout_params)
    DrawTextLayout.new(ref_ptr)
  end

  def self.draw_free_text_layout(draw_text_layout) : Nil
    LibUI.draw_free_text_layout(draw_text_layout)
  end

  def self.draw_text(draw_context, draw_text_layout, x, y) : Nil
    LibUI.draw_text(draw_context, draw_text_layout, x, y)
  end

  def self.draw_text_layout_extents(draw_text_layout, width, height) : Nil
    LibUI.draw_text_layout_extents(draw_text_layout, width, height)
  end

  def self.font_button_font(font_button, font_descriptor) : Nil
    LibUI.font_button_font(font_button, font_descriptor)
  end

  def self.font_button_on_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.font_button_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_font_button : FontButton
    ref_ptr = LibUI.new_font_button
    FontButton.new(ref_ptr)
  end

  def self.free_font_button_font(font_descriptor) : Nil
    LibUI.free_font_button_font(font_descriptor)
  end

  def self.color_button_color(color_button, r, g, b, a) : Nil
    LibUI.color_button_color(color_button, r, g, b, a)
  end

  def self.color_button_set_color(color_button, r, g, b, a) : Nil
    LibUI.color_button_set_color(color_button, r, g, b, a)
  end

  def self.color_button_on_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.color_button_on_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.new_color_button : ColorButton
    ref_ptr = LibUI.new_color_button
    ColorButton.new(ref_ptr)
  end

  def self.form_append(form, label, control, stretchy) : Nil
    LibUI.form_append(form, label, to_control(control), stretchy)
  end

  def self.form_num_children(form) : LibC::Int
    LibUI.form_num_children(form)
  end

  def self.form_delete(form, index) : Nil
    LibUI.form_delete(form, index)
  end

  def self.form_padded(form) : LibC::Int
    LibUI.form_padded(form)
  end

  def self.form_set_padded(form, padded) : Nil
    LibUI.form_set_padded(form, padded)
  end

  def self.new_form : Form
    ref_ptr = LibUI.new_form
    Form.new(ref_ptr)
  end

  def self.grid_append(grid, control, left, top, xspan, yspan, hexpand, halign, vexpand, valign) : Nil
    LibUI.grid_append(grid, to_control(control), left, top, xspan, yspan, hexpand, halign, vexpand, valign)
  end

  def self.grid_insert_at(grid, control, existing, at, xspan, yspan, hexpand, halign, vexpand, valign) : Nil
    LibUI.grid_insert_at(grid, to_control(control), to_control(existing), at, xspan, yspan, hexpand, halign, vexpand, valign)
  end

  def self.grid_padded(grid) : LibC::Int
    LibUI.grid_padded(grid)
  end

  def self.grid_set_padded(grid, padded) : Nil
    LibUI.grid_set_padded(grid, padded)
  end

  def self.new_grid : Grid
    ref_ptr = LibUI.new_grid
    Grid.new(ref_ptr)
  end

  def self.new_image(width, height) : Image
    ref_ptr = LibUI.new_image(width, height)
    Image.new(ref_ptr)
  end

  def self.free_image(image) : Nil
    LibUI.free_image(image)
  end

  def self.image_append(image, pixels, piexl_width, pixel_height, byte_stride) : Nil
    LibUI.image_append(image, pixels, piexl_width, pixel_height, byte_stride)
  end

  def self.free_table_value(table_value) : Nil
    LibUI.free_table_value(table_value)
  end

  def self.table_value_get_type(table_value) : TableValueType
    LibUI.table_value_get_type(table_value)
  end

  def self.new_table_value_string(str) : TableValue
    ref_ptr = LibUI.new_table_value_string(str)
    TableValue.new(ref_ptr)
  end

  def self.table_value_string(table_value) : String?
    str_ptr = LibUI.table_value_string(table_value)
    string_from_pointer(str_ptr)
  end

  def self.new_table_value_image(image) : TableValue
    ref_ptr = LibUI.new_table_value_image(image)
    TableValue.new(ref_ptr)
  end

  def self.table_value_image(table_value) : Image
    ref_ptr = LibUI.table_value_image(table_value)
    Image.new(ref_ptr)
  end

  def self.new_table_value_int(i) : TableValue
    ref_ptr = LibUI.new_table_value_int(i)
    TableValue.new(ref_ptr)
  end

  def self.table_value_int(table_value) : LibC::Int
    LibUI.table_value_int(table_value)
  end

  def self.new_table_value_color(r, g, b, a) : TableValue
    ref_ptr = LibUI.new_table_value_color(r, g, b, a)
    TableValue.new(ref_ptr)
  end

  def self.table_value_color(table_value, r, g, b, a) : Nil
    LibUI.table_value_color(table_value, r, g, b, a)
  end

  def self.new_table_model(model_handler) : TableModel
    ref_ptr = LibUI.new_table_model(model_handler)
    TableModel.new(ref_ptr)
  end

  def self.free_table_model(table_model) : Nil
    LibUI.free_table_model(table_model)
  end

  def self.table_model_row_inserted(table_model, new_index) : Nil
    LibUI.table_model_row_inserted(table_model, new_index)
  end

  def self.table_model_row_changed(table_model, index) : Nil
    LibUI.table_model_row_changed(table_model, index)
  end

  def self.table_model_row_deleted(table_model, old_index) : Nil
    LibUI.table_model_row_deleted(table_model, old_index)
  end

  def self.table_append_text_column(table_model, name, text_model_column, text_editable_model_column, table_text_column_optional_params) : Nil
    LibUI.table_append_text_column(table_model, name, text_model_column, text_editable_model_column, table_text_column_optional_params)
  end

  def self.table_append_image_column(table, name, image_model_colum) : Nil
    LibUI.table_append_image_column(table, name, image_model_colum)
  end

  def self.table_append_image_text_column(table, name, image_model_column, text_model_column, text_editable_model_column, table_text_column_optional_params) : Nil
    LibUI.table_append_image_text_column(table, name, image_model_column, text_model_column, text_editable_model_column, table_text_column_optional_params)
  end

  def self.table_append_checkbox_column(table, name, checkbox_model_column, checkbox_editable_model_column) : Nil
    LibUI.table_append_checkbox_column(table, name, checkbox_model_column, checkbox_editable_model_column)
  end

  def self.table_append_checkbox_text_column(table, name, checkbox_model_column, checkbox_editable_model_column, text_model_column, text_editable_model_column, table_text_column_optional_params) : Nil
    LibUI.table_append_checkbox_text_column(table, name, checkbox_model_column, checkbox_editable_model_column, text_model_column, text_editable_model_column, table_text_column_optional_params)
  end

  def self.table_append_progress_bar_column(table, name, progress_model_column) : Nil
    LibUI.table_append_progress_bar_column(table, name, progress_model_column)
  end

  def self.table_append_button_column(table, name, button_model_column, button_clickable_model_column) : Nil
    LibUI.table_append_button_column(table, name, button_model_column, button_clickable_model_column)
  end

  def self.table_header_visible(table) : LibC::Int
    LibUI.table_header_visible(table)
  end

  def self.table_header_set_visible(table, visible) : Nil
    LibUI.table_header_set_visible(table, visible)
  end

  def self.new_table(table_params) : Table
    ref_ptr = LibUI.new_table(table_params)
    Table.new(ref_ptr)
  end

  def self.table_on_row_clicked(sender, boxed_data : Pointer(Void), &callback : LibC::Int -> Void) : Nil
    LibUI.table_on_row_clicked(sender, ->(sender, row, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(row)
    end, boxed_data)
  end

  def self.table_on_row_double_clicked(sender, boxed_data : Pointer(Void), &callback : LibC::Int -> Void) : Nil
    LibUI.table_on_row_double_clicked(sender, ->(sender, row, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(row)
    end, boxed_data)
  end

  def self.table_header_set_sort_indicator(table, column, sort_indicator) : Nil
    LibUI.table_header_set_sort_indicator(table, column, sort_indicator)
  end

  def self.table_header_sort_indicator(table, column) : SortIndicator
    LibUI.table_header_sort_indicator(table, column)
  end

  def self.table_header_on_clicked(sender, boxed_data : Pointer(Void), &callback : LibC::Int -> Void) : Nil
    LibUI.table_header_on_clicked(sender, ->(sender, column, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(column)
    end, boxed_data)
  end

  def self.table_column_width(table, column) : LibC::Int
    LibUI.table_column_width(table, column)
  end

  def self.table_column_set_width(table, column, width) : Nil
    LibUI.table_column_set_width(table, column, width)
  end

  def self.table_get_selection_mode(table) : TableSelectionMode
    LibUI.table_get_selection_mode(table)
  end

  def self.table_set_selection_mode(table, mode) : Nil
    LibUI.table_set_selection_mode(table, mode)
  end

  def self.table_on_selection_changed(sender, boxed_data : Pointer(Void), &callback : -> Void) : Nil
    LibUI.table_on_selection_changed(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.table_get_selection(table) : TableSelection
    ref_ptr = LibUI.table_get_selection(table)
    TableSelection.new(ref_ptr)
  end

  def self.table_set_selection(table, selection) : Nil
    LibUI.table_set_selection(table, selection)
  end

  def self.free_table_selection(table_selection) : Nil
    LibUI.free_table_selection(table_selection)
  end
end
