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
    LibUI.main_step(wait)
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

  def self.user_bug_cannot_set_parent_on_toplevel(type) : Nil
    LibUI.user_bug_cannot_set_parent_on_toplevel(type)
  end

  def self.window_title(window) : String?
    str_ptr = LibUI.window_title(window)
    str_ptr.null? ? nil : String.new(str_ptr)
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

  def self.window_on_position_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
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
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.button_set_text(button, text) : Nil
    LibUI.button_set_text(button, text)
  end

  def self.button_on_clicked(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
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
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.checkbox_set_text(checkbox, text) : Nil
    LibUI.checkbox_set_text(checkbox, text)
  end

  def self.checkbox_on_toggled(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.checkbox_on_toggled(sender, ->(sender, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call
    end, boxed_data)
  end

  def self.checkbox_checked(checkbox) : LibC::Int
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
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.entry_set_text(entry, text) : Nil
    LibUI.entry_set_text(entry, text)
  end

  def self.entry_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
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
    str_ptr.null? ? nil : String.new(str_ptr)
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
    str_ptr.null? ? nil : String.new(str_ptr)
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

  def self.spinbox_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
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

  def self.combobox_on_selected(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
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
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.editable_combobox_set_text(editable_combobox, text) : Nil
    LibUI.editable_combobox_set_text(editable_combobox, text)
  end

  def self.editable_combobox_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
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

  def self.radio_buttons_on_selected(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
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

  def self.date_time_picker_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
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
    str_ptr.null? ? nil : String.new(str_ptr)
  end

  def self.multiline_entry_set_text(multiline_entry, text) : Nil
    LibUI.multiline_entry_set_text(multiline_entry, text)
  end

  def self.multiline_entry_append(multiline_entry, text) : Nil
    LibUI.multiline_entry_append(multiline_entry, text)
  end

  def self.multiline_entry_on_changed(sender, &callback : -> Void) : Nil
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
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

  def self.menu_item_on_clicked(sender, &callback : Pointer(LibUI::Window) -> Void)
    boxed_data = ::Box.box(callback)
    @@box = boxed_data
    LibUI.menu_item_on_clicked(sender, ->(sender, window, data) do
      data_as_callback = ::Box(typeof(callback)).unbox(data)
      data_as_callback.call(window)
    end, boxed_data)
  end

  def self.menu_item_checked(menu_item) : LibC::Int
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

  def self.attribute_get_type(attribute) : LibUI::AttributeType
    LibUI.attribute_get_type(attribute)
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
