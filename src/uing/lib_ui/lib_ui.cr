require "./*"

module UIng
  {% if flag?(:msvc) %}
    @[Link("User32")]
    @[Link("Gdi32")]
    @[Link("Comctl32")]
    @[Link("UxTheme")]
    @[Link("Dwrite")]
    @[Link("D2d1")]
    @[Link("Windowscodecs")]
    # @[Link(ldflags: "/SUBSYSTEM:WINDOWS")]
    {% if flag?(:debug) %}
      @[Link(ldflags: "/DEBUG")]
      # FIXME
      {% puts "[uing] FIXME: Currently, pdb files are not available for libui." %}
      {% puts "[uing] In MSVC, use libui release build even if debug mode is enabled." %}
      # @[Link(ldflags: "/LIBPATH:#{__DIR__}/../../../libui/debug")]
      @[Link(ldflags: "/LIBPATH:#{__DIR__}/../../../libui/release")]
    {% elsif flag?(:release) %}
      @[Link(ldflags: "/LTCG")]
      @[Link(ldflags: "/LIBPATH:#{__DIR__}/../../../libui/release")]
    {% else %}
      @[Link(ldflags: "/LIBPATH:#{__DIR__}/../../../libui/release")]
    {% end %}
    # @[Link("ui", dll: "libui.dll")]
    @[Link(ldflags: "/MANIFESTINPUT:#{__DIR__}/../../../comctl32.manifest /MANIFEST:EMBED")]
  {% elsif flag?(:win32) && flag?(:gnu) %}
    @[Link("stdc++")]
    @[Link("supc++")]
    @[Link("user32")]
    @[Link("Gdi32")]
    @[Link("Comctl32")]
    @[Link("D2d1")]
    @[Link("Dwrite")]
    @[Link("WindowsCodecs")]
    @[Link("Uuid")]
    @[Link("Winmm")]
    @[Link("Uxtheme")]
    # @[Link(ldflags: "-mwindows")]
    {% if flag?(:debug) %}
      @[Link(ldflags: "-L#{__DIR__}/../../../libui/debug")]
    {% elsif flag?(:release) %}
      @[Link(ldflags: "-L#{__DIR__}/../../../libui/release")]
    {% else %}
      @[Link(ldflags: "-L#{__DIR__}/../../../libui/release")]
    {% end %}
    @[Link(ldflags: "#{__DIR__}/../../../comctl32.res")]
  {% elsif flag?(:linux) %}
    @[Link("gtk+-3.0")]
    @[Link("m")]
    {% if flag?(:debug) %}
      @[Link(ldflags: "-L#{__DIR__}/../../../libui/debug")]
    {% elsif flag?(:release) %}
      @[Link(ldflags: "-L#{__DIR__}/../../../libui/release")]
    {% else %}
      @[Link(ldflags: "-L#{__DIR__}/../../../libui/release")]
    {% end %}
  {% elsif flag?(:darwin) %}
    @[Link(framework: "CoreGraphics")]
    @[Link(framework: "AppKit")]
    {% if flag?(:debug) %}
      @[Link(ldflags: "-L#{__DIR__}/../../../libui/debug")]
    {% elsif flag?(:release) %}
      @[Link(ldflags: "-L#{__DIR__}/../../../libui/release")]
    {% else %}
      @[Link(ldflags: "-L#{__DIR__}/../../../libui/release")]
    {% end %}
  {% end %}
  @[Link("ui")]
  lib LibUI
    PI                    = 3.14159265358979323846264338327950288419716939937510582097494459
    DRAWDEFAULTMITERLIMIT =                                                             10.0

    fun init = uiInit(options : Pointer(InitOptions)) : Pointer(LibC::Char)
    fun uninit = uiUninit
    fun free_init_error = uiFreeInitError(err : Pointer(LibC::Char))
    fun main = uiMain
    fun main_steps = uiMainSteps
    fun main_step = uiMainStep(wait : Bool) : Bool
    fun quit = uiQuit
    fun queue_main = uiQueueMain(f : (Pointer(Void) -> Void), data : Pointer(Void))
    fun timer = uiTimer(milliseconds : LibC::Int, f : (Pointer(Void) -> LibC::Int), data : Pointer(Void))
    fun on_should_quit = uiOnShouldQuit(f : (Pointer(Void) -> Bool), data : Pointer(Void))
    fun free_text = uiFreeText(text : Pointer(LibC::Char))
    # Control is a struct
    fun control_destroy = uiControlDestroy(c : Pointer(Control))
    fun control_handle = uiControlHandle(c : Pointer(Control)) : Pointer(Void)
    fun control_parent = uiControlParent(c : Pointer(Control)) : Pointer(Control)
    fun control_set_parent = uiControlSetParent(c : Pointer(Control), parent : Pointer(Control))
    fun control_toplevel = uiControlToplevel(c : Pointer(Control)) : Bool
    fun control_visible = uiControlVisible(c : Pointer(Control)) : Bool
    fun control_show = uiControlShow(c : Pointer(Control))
    fun control_hide = uiControlHide(c : Pointer(Control))
    fun control_enabled = uiControlEnabled(c : Pointer(Control)) : Bool
    fun control_enable = uiControlEnable(c : Pointer(Control))
    fun control_disable = uiControlDisable(c : Pointer(Control))
    fun alloc_control = uiAllocControl(n : LibC::SizeT, o_ssig : LibC::Int, typesig : LibC::Int, typenamestr : Pointer(LibC::Char)) : Pointer(Control)
    fun free_control = uiFreeControl(c : Pointer(Control))
    fun control_verify_set_parent = uiControlVerifySetParent(c : Pointer(Control), parent : Pointer(Control))
    fun control_enabled_to_user = uiControlEnabledToUser(c : Pointer(Control)) : Bool
    fun user_bug_cannot_set_parent_on_toplevel = uiUserBugCannotSetParentOnToplevel(type : Pointer(LibC::Char))
    alias Window = Void
    fun window_title = uiWindowTitle(w : Pointer(Window)) : Pointer(LibC::Char)
    fun window_set_title = uiWindowSetTitle(w : Pointer(Window), title : Pointer(LibC::Char))
    fun window_position = uiWindowPosition(w : Pointer(Window), x : Pointer(LibC::Int), y : Pointer(LibC::Int))
    fun window_set_position = uiWindowSetPosition(w : Pointer(Window), x : LibC::Int, y : LibC::Int)
    fun window_on_position_changed = uiWindowOnPositionChanged(w : Pointer(Window), f : (Pointer(Window), Pointer(Void) -> Void), data : Pointer(Void))
    fun window_content_size = uiWindowContentSize(w : Pointer(Window), width : Pointer(LibC::Int), height : Pointer(LibC::Int))
    fun window_set_content_size = uiWindowSetContentSize(w : Pointer(Window), width : LibC::Int, height : LibC::Int)
    fun window_fullscreen = uiWindowFullscreen(w : Pointer(Window)) : Bool
    fun window_set_fullscreen = uiWindowSetFullscreen(w : Pointer(Window), fullscreen : Bool)
    fun window_on_content_size_changed = uiWindowOnContentSizeChanged(w : Pointer(Window), f : (Pointer(Window), Pointer(Void) -> Void), data : Pointer(Void))
    fun window_on_closing = uiWindowOnClosing(w : Pointer(Window), f : (Pointer(Window), Pointer(Void) -> Bool), data : Pointer(Void))
    fun window_on_focus_changed = uiWindowOnFocusChanged(w : Pointer(Window), f : (Pointer(Window), Pointer(Void) -> Void), data : Pointer(Void))
    fun window_focused = uiWindowFocused(w : Pointer(Window)) : Bool
    fun window_borderless = uiWindowBorderless(w : Pointer(Window)) : Bool
    fun window_set_borderless = uiWindowSetBorderless(w : Pointer(Window), borderless : Bool)
    fun window_set_child = uiWindowSetChild(w : Pointer(Window), child : Pointer(Control))
    fun window_margined = uiWindowMargined(w : Pointer(Window)) : Bool
    fun window_set_margined = uiWindowSetMargined(w : Pointer(Window), margined : Bool)
    fun window_resizeable = uiWindowResizeable(w : Pointer(Window)) : Bool
    fun window_set_resizeable = uiWindowSetResizeable(w : Pointer(Window), resizeable : Bool)
    fun new_window = uiNewWindow(title : Pointer(LibC::Char), width : LibC::Int, height : LibC::Int, has_menubar : Bool) : Pointer(Window)
    alias Button = Void
    fun button_text = uiButtonText(b : Pointer(Button)) : Pointer(LibC::Char)
    fun button_set_text = uiButtonSetText(b : Pointer(Button), text : Pointer(LibC::Char))
    fun button_on_clicked = uiButtonOnClicked(b : Pointer(Button), f : (Pointer(Button), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_button = uiNewButton(text : Pointer(LibC::Char)) : Pointer(Button)
    alias Box = Void
    fun box_append = uiBoxAppend(b : Pointer(Box), child : Pointer(Control), stretchy : LibC::Int)
    fun box_num_children = uiBoxNumChildren(b : Pointer(Box)) : LibC::Int
    fun box_delete = uiBoxDelete(b : Pointer(Box), index : LibC::Int)
    fun box_padded = uiBoxPadded(b : Pointer(Box)) : Bool
    fun box_set_padded = uiBoxSetPadded(b : Pointer(Box), padded : Bool)
    fun new_horizontal_box = uiNewHorizontalBox : Pointer(Box)
    fun new_vertical_box = uiNewVerticalBox : Pointer(Box)
    alias Checkbox = Void
    fun checkbox_text = uiCheckboxText(c : Pointer(Checkbox)) : Pointer(LibC::Char)
    fun checkbox_set_text = uiCheckboxSetText(c : Pointer(Checkbox), text : Pointer(LibC::Char))
    fun checkbox_on_toggled = uiCheckboxOnToggled(c : Pointer(Checkbox), f : (Pointer(Checkbox), Pointer(Void) -> Void), data : Pointer(Void))
    fun checkbox_checked = uiCheckboxChecked(c : Pointer(Checkbox)) : Bool
    fun checkbox_set_checked = uiCheckboxSetChecked(c : Pointer(Checkbox), checked : Bool)
    fun new_checkbox = uiNewCheckbox(text : Pointer(LibC::Char)) : Pointer(Checkbox)
    alias Entry = Void
    fun entry_text = uiEntryText(e : Pointer(Entry)) : Pointer(LibC::Char)
    fun entry_set_text = uiEntrySetText(e : Pointer(Entry), text : Pointer(LibC::Char))
    fun entry_on_changed = uiEntryOnChanged(e : Pointer(Entry), f : (Pointer(Entry), Pointer(Void) -> Void), data : Pointer(Void))
    fun entry_read_only = uiEntryReadOnly(e : Pointer(Entry)) : Bool
    fun entry_set_read_only = uiEntrySetReadOnly(e : Pointer(Entry), readonly : Bool)
    fun new_entry = uiNewEntry : Pointer(Entry)
    fun new_password_entry = uiNewPasswordEntry : Pointer(Entry)
    fun new_search_entry = uiNewSearchEntry : Pointer(Entry)
    alias Label = Void
    fun label_text = uiLabelText(l : Pointer(Label)) : Pointer(LibC::Char)
    fun label_set_text = uiLabelSetText(l : Pointer(Label), text : Pointer(LibC::Char))
    fun new_label = uiNewLabel(text : Pointer(LibC::Char)) : Pointer(Label)
    alias Tab = Void
    fun tab_append = uiTabAppend(t : Pointer(Tab), name : Pointer(LibC::Char), c : Pointer(Control))
    fun tab_insert_at = uiTabInsertAt(t : Pointer(Tab), name : Pointer(LibC::Char), index : LibC::Int, c : Pointer(Control))
    fun tab_delete = uiTabDelete(t : Pointer(Tab), index : LibC::Int)
    fun tab_num_pages = uiTabNumPages(t : Pointer(Tab)) : LibC::Int
    fun tab_margined = uiTabMargined(t : Pointer(Tab), index : LibC::Int) : Bool
    fun tab_set_margined = uiTabSetMargined(t : Pointer(Tab), index : LibC::Int, margined : Bool)
    fun tab_selected = uiTabSelected(t : Pointer(Tab)) : LibC::Int
    fun tab_set_selected = uiTabSetSelected(t : Pointer(Tab), index : LibC::Int)
    fun tab_on_selected = uiTabOnSelected(t : Pointer(Tab), f : (Pointer(Tab), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_tab = uiNewTab : Pointer(Tab)
    alias Group = Void
    fun group_title = uiGroupTitle(g : Pointer(Group)) : Pointer(LibC::Char)
    fun group_set_title = uiGroupSetTitle(g : Pointer(Group), title : Pointer(LibC::Char))
    fun group_set_child = uiGroupSetChild(g : Pointer(Group), c : Pointer(Control))
    fun group_margined = uiGroupMargined(g : Pointer(Group)) : Bool
    fun group_set_margined = uiGroupSetMargined(g : Pointer(Group), margined : Bool)
    fun new_group = uiNewGroup(title : Pointer(LibC::Char)) : Pointer(Group)
    alias Spinbox = Void
    fun spinbox_value = uiSpinboxValue(s : Pointer(Spinbox)) : LibC::Int
    fun spinbox_set_value = uiSpinboxSetValue(s : Pointer(Spinbox), value : LibC::Int)
    fun spinbox_on_changed = uiSpinboxOnChanged(s : Pointer(Spinbox), f : (Pointer(Spinbox), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_spinbox = uiNewSpinbox(min : LibC::Int, max : LibC::Int) : Pointer(Spinbox)
    alias Slider = Void
    fun slider_value = uiSliderValue(s : Pointer(Slider)) : LibC::Int
    fun slider_set_value = uiSliderSetValue(s : Pointer(Slider), value : LibC::Int)
    fun slider_has_tool_tip = uiSliderHasToolTip(s : Pointer(Slider)) : Bool
    fun slider_set_has_tool_tip = uiSliderSetHasToolTip(s : Pointer(Slider), has_tool_tip : Bool)
    fun slider_on_changed = uiSliderOnChanged(s : Pointer(Slider), f : (Pointer(Slider), Pointer(Void) -> Void), data : Pointer(Void))
    fun slider_on_released = uiSliderOnReleased(s : Pointer(Slider), f : (Pointer(Slider), Pointer(Void) -> Void), data : Pointer(Void))
    fun slider_set_range = uiSliderSetRange(s : Pointer(Slider), min : LibC::Int, max : LibC::Int)
    fun new_slider = uiNewSlider(min : LibC::Int, max : LibC::Int) : Pointer(Slider)
    alias ProgressBar = Void
    fun progress_bar_value = uiProgressBarValue(p : Pointer(ProgressBar)) : LibC::Int
    fun progress_bar_set_value = uiProgressBarSetValue(p : Pointer(ProgressBar), n : LibC::Int)
    fun new_progress_bar = uiNewProgressBar : Pointer(ProgressBar)
    alias Separator = Void
    fun new_horizontal_separator = uiNewHorizontalSeparator : Pointer(Separator)
    fun new_vertical_separator = uiNewVerticalSeparator : Pointer(Separator)
    alias Combobox = Void
    fun combobox_append = uiComboboxAppend(c : Pointer(Combobox), text : Pointer(LibC::Char))
    fun combobox_insert_at = uiComboboxInsertAt(c : Pointer(Combobox), index : LibC::Int, text : Pointer(LibC::Char))
    fun combobox_delete = uiComboboxDelete(c : Pointer(Combobox), index : LibC::Int)
    fun combobox_clear = uiComboboxClear(c : Pointer(Combobox))
    fun combobox_num_items = uiComboboxNumItems(c : Pointer(Combobox)) : LibC::Int
    fun combobox_selected = uiComboboxSelected(c : Pointer(Combobox)) : LibC::Int
    fun combobox_set_selected = uiComboboxSetSelected(c : Pointer(Combobox), index : LibC::Int)
    fun combobox_on_selected = uiComboboxOnSelected(c : Pointer(Combobox), f : (Pointer(Combobox), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_combobox = uiNewCombobox : Pointer(Void)
    alias EditableCombobox = Void
    fun editable_combobox_append = uiEditableComboboxAppend(c : Pointer(EditableCombobox), text : Pointer(LibC::Char))
    fun editable_combobox_text = uiEditableComboboxText(c : Pointer(EditableCombobox)) : Pointer(LibC::Char)
    fun editable_combobox_set_text = uiEditableComboboxSetText(c : Pointer(EditableCombobox), text : Pointer(LibC::Char))
    fun editable_combobox_on_changed = uiEditableComboboxOnChanged(c : Pointer(EditableCombobox), f : (Pointer(EditableCombobox), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_editable_combobox = uiNewEditableCombobox : Pointer(EditableCombobox)
    alias RadioButtons = Void
    fun radio_buttons_append = uiRadioButtonsAppend(r : Pointer(RadioButtons), text : Pointer(LibC::Char))
    fun radio_buttons_selected = uiRadioButtonsSelected(r : Pointer(RadioButtons)) : LibC::Int
    fun radio_buttons_set_selected = uiRadioButtonsSetSelected(r : Pointer(RadioButtons), index : LibC::Int)
    fun radio_buttons_on_selected = uiRadioButtonsOnSelected(r : Pointer(RadioButtons), f : (Pointer(RadioButtons), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_radio_buttons = uiNewRadioButtons : Pointer(Void)
    alias DateTimePicker = Void
    fun date_time_picker_time = uiDateTimePickerTime(d : Pointer(DateTimePicker), time : Pointer(Tm))
    alias Tm = Void
    fun date_time_picker_set_time = uiDateTimePickerSetTime(d : Pointer(DateTimePicker), time : Pointer(Tm))
    fun date_time_picker_on_changed = uiDateTimePickerOnChanged(d : Pointer(DateTimePicker), f : (Pointer(DateTimePicker), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_date_time_picker = uiNewDateTimePicker : Pointer(DateTimePicker)
    fun new_date_picker = uiNewDatePicker : Pointer(DateTimePicker)
    fun new_time_picker = uiNewTimePicker : Pointer(DateTimePicker)
    alias MultilineEntry = Void
    fun multiline_entry_text = uiMultilineEntryText(e : Pointer(MultilineEntry)) : Pointer(LibC::Char)
    fun multiline_entry_set_text = uiMultilineEntrySetText(e : Pointer(MultilineEntry), text : Pointer(LibC::Char))
    fun multiline_entry_append = uiMultilineEntryAppend(e : Pointer(MultilineEntry), text : Pointer(LibC::Char))
    fun multiline_entry_on_changed = uiMultilineEntryOnChanged(e : Pointer(MultilineEntry), f : (Pointer(MultilineEntry), Pointer(Void) -> Void), data : Pointer(Void))
    fun multiline_entry_read_only = uiMultilineEntryReadOnly(e : Pointer(MultilineEntry)) : Bool
    fun multiline_entry_set_read_only = uiMultilineEntrySetReadOnly(e : Pointer(MultilineEntry), readonly : Bool)
    fun new_multiline_entry = uiNewMultilineEntry : Pointer(MultilineEntry)
    fun new_non_wrapping_multiline_entry = uiNewNonWrappingMultilineEntry : Pointer(MultilineEntry)
    alias MenuItem = Void
    fun menu_item_enable = uiMenuItemEnable(m : Pointer(MenuItem))
    fun menu_item_disable = uiMenuItemDisable(m : Pointer(MenuItem))
    fun menu_item_on_clicked = uiMenuItemOnClicked(m : Pointer(MenuItem), f : (Pointer(MenuItem), Pointer(Window), Pointer(Void) -> Void), data : Pointer(Void))
    fun menu_item_checked = uiMenuItemChecked(m : Pointer(MenuItem)) : Bool
    fun menu_item_set_checked = uiMenuItemSetChecked(m : Pointer(MenuItem), checked : Bool)
    alias Menu = Void
    fun menu_append_item = uiMenuAppendItem(m : Pointer(Menu), name : Pointer(LibC::Char)) : Pointer(MenuItem)
    fun menu_append_check_item = uiMenuAppendCheckItem(m : Pointer(Menu), name : Pointer(LibC::Char)) : Pointer(MenuItem)
    fun menu_append_quit_item = uiMenuAppendQuitItem(m : Pointer(Menu)) : Pointer(MenuItem)
    fun menu_append_preferences_item = uiMenuAppendPreferencesItem(m : Pointer(Menu)) : Pointer(MenuItem)
    fun menu_append_about_item = uiMenuAppendAboutItem(m : Pointer(Menu)) : Pointer(MenuItem)
    fun menu_append_separator = uiMenuAppendSeparator(m : Pointer(Menu))
    fun new_menu = uiNewMenu(name : Pointer(LibC::Char)) : Pointer(Menu)
    fun open_file = uiOpenFile(parent : Pointer(Window)) : Pointer(LibC::Char)
    fun open_folder = uiOpenFolder(parent : Pointer(Window)) : Pointer(LibC::Char)
    fun save_file = uiSaveFile(parent : Pointer(Window)) : Pointer(LibC::Char)
    fun msg_box = uiMsgBox(parent : Pointer(Window), title : Pointer(LibC::Char), description : Pointer(LibC::Char))
    fun msg_box_error = uiMsgBoxError(parent : Pointer(Window), title : Pointer(LibC::Char), description : Pointer(LibC::Char))
    alias Area = Void

    alias DrawContext = Void
    fun area_set_size = uiAreaSetSize(a : Pointer(Area), width : LibC::Int, height : LibC::Int)
    fun area_queue_redraw_all = uiAreaQueueRedrawAll(a : Pointer(Area))
    fun area_scroll_to = uiAreaScrollTo(a : Pointer(Area), x : LibC::Double, y : LibC::Double, width : LibC::Double, height : LibC::Double)
    fun area_begin_user_window_move = uiAreaBeginUserWindowMove(a : Pointer(Area))
    fun area_begin_user_window_resize = uiAreaBeginUserWindowResize(a : Pointer(Area), edge : WindowResizeEdge)
    fun new_area = uiNewArea(ah : Pointer(AreaHandler)) : Pointer(Area)
    fun new_scrolling_area = uiNewScrollingArea(ah : Pointer(AreaHandler), width : LibC::Int, height : LibC::Int) : Pointer(Area)
    alias DrawPath = Void

    fun draw_new_path = uiDrawNewPath(fill_mode : DrawFillMode) : Pointer(DrawPath)
    fun draw_free_path = uiDrawFreePath(p : Pointer(DrawPath))
    fun draw_path_new_figure = uiDrawPathNewFigure(p : Pointer(DrawPath), x : LibC::Double, y : LibC::Double)
    fun draw_path_new_figure_with_arc = uiDrawPathNewFigureWithArc(p : Pointer(DrawPath), x_center : LibC::Double, y_center : LibC::Double, radius : LibC::Double, start_angle : LibC::Double, sweep : LibC::Double, negative : Bool)
    fun draw_path_line_to = uiDrawPathLineTo(p : Pointer(DrawPath), x : LibC::Double, y : LibC::Double)
    fun draw_path_arc_to = uiDrawPathArcTo(p : Pointer(DrawPath), x_center : LibC::Double, y_center : LibC::Double, radius : LibC::Double, start_angle : LibC::Double, sweep : LibC::Double, negative : Bool)
    fun draw_path_bezier_to = uiDrawPathBezierTo(p : Pointer(DrawPath), c1x : LibC::Double, c1y : LibC::Double, c2x : LibC::Double, c2y : LibC::Double, end_x : LibC::Double, end_y : LibC::Double)
    fun draw_path_close_figure = uiDrawPathCloseFigure(p : Pointer(DrawPath))
    fun draw_path_add_rectangle = uiDrawPathAddRectangle(p : Pointer(DrawPath), x : LibC::Double, y : LibC::Double, width : LibC::Double, height : LibC::Double)
    fun draw_path_ended = uiDrawPathEnded(p : Pointer(DrawPath)) : Bool
    fun draw_path_end = uiDrawPathEnd(p : Pointer(DrawPath))
    fun draw_stroke = uiDrawStroke(c : Pointer(DrawContext), path : Pointer(DrawPath), b : Pointer(DrawBrush), p : Pointer(DrawStrokeParams))
    fun draw_fill = uiDrawFill(c : Pointer(DrawContext), path : Pointer(DrawPath), b : Pointer(DrawBrush))
    fun draw_matrix_set_identity = uiDrawMatrixSetIdentity(m : Pointer(DrawMatrix))
    fun draw_matrix_translate = uiDrawMatrixTranslate(m : Pointer(DrawMatrix), x : LibC::Double, y : LibC::Double)
    fun draw_matrix_scale = uiDrawMatrixScale(m : Pointer(DrawMatrix), x_center : LibC::Double, y_center : LibC::Double, x : LibC::Double, y : LibC::Double)
    fun draw_matrix_rotate = uiDrawMatrixRotate(m : Pointer(DrawMatrix), x : LibC::Double, y : LibC::Double, amount : LibC::Double)
    fun draw_matrix_skew = uiDrawMatrixSkew(m : Pointer(DrawMatrix), x : LibC::Double, y : LibC::Double, xamount : LibC::Double, yamount : LibC::Double)
    fun draw_matrix_multiply = uiDrawMatrixMultiply(dest : Pointer(DrawMatrix), src : Pointer(DrawMatrix))
    fun draw_matrix_invertible = uiDrawMatrixInvertible(m : Pointer(DrawMatrix)) : Bool
    fun draw_matrix_invert = uiDrawMatrixInvert(m : Pointer(DrawMatrix)) : Bool
    fun draw_matrix_transform_point = uiDrawMatrixTransformPoint(m : Pointer(DrawMatrix), x : Pointer(LibC::Double), y : Pointer(LibC::Double))
    fun draw_matrix_transform_size = uiDrawMatrixTransformSize(m : Pointer(DrawMatrix), x : Pointer(LibC::Double), y : Pointer(LibC::Double))
    fun draw_transform = uiDrawTransform(c : Pointer(DrawContext), m : Pointer(DrawMatrix))
    fun draw_clip = uiDrawClip(c : Pointer(DrawContext), path : Pointer(DrawPath))
    fun draw_save = uiDrawSave(c : Pointer(DrawContext))
    fun draw_restore = uiDrawRestore(c : Pointer(DrawContext))

    alias Attribute = Void
    fun free_attribute = uiFreeAttribute(a : Pointer(Attribute))
    fun attribute_get_type = uiAttributeGetType(a : Pointer(Attribute)) : AttributeType
    fun new_family_attribute = uiNewFamilyAttribute(family : Pointer(LibC::Char)) : Pointer(Attribute)
    fun attribute_family = uiAttributeFamily(a : Pointer(Attribute)) : Pointer(LibC::Char)
    fun new_size_attribute = uiNewSizeAttribute(size : LibC::Double) : Pointer(Attribute)
    fun attribute_size = uiAttributeSize(a : Pointer(Attribute)) : LibC::Double

    fun new_weight_attribute = uiNewWeightAttribute(weight : TextWeight) : Pointer(Attribute)
    fun attribute_weight = uiAttributeWeight(a : Pointer(Attribute))

    fun new_italic_attribute = uiNewItalicAttribute(italic : TextItalic) : Pointer(Attribute)
    fun attribute_italic = uiAttributeItalic(a : Pointer(Attribute))

    fun new_stretch_attribute = uiNewStretchAttribute(stretch : TextStretch) : Pointer(Attribute)
    fun attribute_stretch = uiAttributeStretch(a : Pointer(Attribute))
    fun new_color_attribute = uiNewColorAttribute(r : LibC::Double, g : LibC::Double, b : LibC::Double, a : LibC::Double) : Pointer(Attribute)
    fun attribute_color = uiAttributeColor(a : Pointer(Attribute), r : Pointer(LibC::Double), g : Pointer(LibC::Double), b : Pointer(LibC::Double), alpha : Pointer(LibC::Double))
    fun new_background_attribute = uiNewBackgroundAttribute(r : LibC::Double, g : LibC::Double, b : LibC::Double, a : LibC::Double) : Pointer(Attribute)

    fun new_underline_attribute = uiNewUnderlineAttribute(u : Underline) : Pointer(Attribute)
    fun attribute_underline = uiAttributeUnderline(a : Pointer(Attribute)) : Underline

    fun new_underline_color_attribute = uiNewUnderlineColorAttribute(u : UnderlineColor, r : LibC::Double, g : LibC::Double, b : LibC::Double, a : LibC::Double) : Pointer(Attribute)
    fun attribute_underline_color = uiAttributeUnderlineColor(a : Pointer(Attribute), u : Pointer(UnderlineColor), r : Pointer(LibC::Double), g : Pointer(LibC::Double), b : Pointer(LibC::Double), alpha : Pointer(LibC::Double))
    alias OpenTypeFeatures = Void
    fun new_open_type_features = uiNewOpenTypeFeatures : Pointer(OpenTypeFeatures)
    fun free_open_type_features = uiFreeOpenTypeFeatures(otf : Pointer(OpenTypeFeatures))
    fun open_type_features_clone = uiOpenTypeFeaturesClone(otf : Pointer(OpenTypeFeatures)) : Pointer(OpenTypeFeatures)
    fun open_type_features_add = uiOpenTypeFeaturesAdd(otf : Pointer(OpenTypeFeatures), a : LibC::Char, b : LibC::Char, c : LibC::Char, d : LibC::Char, value : UInt32)
    fun open_type_features_remove = uiOpenTypeFeaturesRemove(otf : Pointer(OpenTypeFeatures), a : LibC::Char, b : LibC::Char, c : LibC::Char, d : LibC::Char)
    fun open_type_features_get = uiOpenTypeFeaturesGet(otf : Pointer(OpenTypeFeatures), a : LibC::Char, b : LibC::Char, c : LibC::Char, d : LibC::Char, value : Pointer(UInt32)) : Bool
    fun open_type_features_for_each = uiOpenTypeFeaturesForEach(otf : Pointer(OpenTypeFeatures), f : Pointer(Void), data : Pointer(Void)) # FIXME: f is a function pointer
    fun new_features_attribute = uiNewFeaturesAttribute(otf : Pointer(OpenTypeFeatures)) : Pointer(Attribute)
    fun attribute_features = uiAttributeFeatures(a : Pointer(Attribute)) : Pointer(OpenTypeFeatures)
    alias AttributedString = Void
    fun new_attributed_string = uiNewAttributedString(initial_string : Pointer(LibC::Char)) : Pointer(AttributedString)
    fun free_attributed_string = uiFreeAttributedString(s : Pointer(AttributedString))
    fun attributed_string_string = uiAttributedStringString(s : Pointer(AttributedString)) : Pointer(LibC::Char)
    fun attributed_string_len = uiAttributedStringLen(s : Pointer(AttributedString)) : LibC::SizeT
    fun attributed_string_append_unattributed = uiAttributedStringAppendUnattributed(s : Pointer(AttributedString), str : Pointer(LibC::Char))
    fun attributed_string_insert_at_unattributed = uiAttributedStringInsertAtUnattributed(s : Pointer(AttributedString), str : Pointer(LibC::Char), at : LibC::SizeT)
    fun attributed_string_delete = uiAttributedStringDelete(s : Pointer(AttributedString), start : LibC::SizeT, _end : LibC::SizeT)
    fun attributed_string_set_attribute = uiAttributedStringSetAttribute(s : Pointer(AttributedString), a : Pointer(Attribute), start : LibC::SizeT, _end : LibC::SizeT)
    fun attributed_string_for_each_attribute = uiAttributedStringForEachAttribute(s : Pointer(AttributedString), f : Pointer(Void), data : Pointer(Void)) # FIXME: f is a function pointer
    fun attributed_string_num_graphemes = uiAttributedStringNumGraphemes(s : Pointer(AttributedString)) : LibC::SizeT
    fun attributed_string_byte_index_to_grapheme = uiAttributedStringByteIndexToGrapheme(s : Pointer(AttributedString), pos : LibC::SizeT) : LibC::SizeT
    fun attributed_string_grapheme_to_byte_index = uiAttributedStringGraphemeToByteIndex(s : Pointer(AttributedString), pos : LibC::SizeT) : LibC::SizeT

    fun load_control_font = uiLoadControlFont(f : Pointer(FontDescriptor))
    fun free_font_descriptor = uiFreeFontDescriptor(desc : Pointer(FontDescriptor))
    alias DrawTextLayout = Void

    fun draw_new_text_layout = uiDrawNewTextLayout(params : Pointer(DrawTextLayoutParams)) : Pointer(DrawTextLayout)
    fun draw_free_text_layout = uiDrawFreeTextLayout(tl : Pointer(DrawTextLayout))
    fun draw_text = uiDrawText(c : Pointer(DrawContext), tl : Pointer(DrawTextLayout), x : LibC::Double, y : LibC::Double)
    fun draw_text_layout_extents = uiDrawTextLayoutExtents(tl : Pointer(DrawTextLayout), width : Pointer(LibC::Double), height : Pointer(LibC::Double))
    alias FontButton = Void
    fun font_button_font = uiFontButtonFont(b : Pointer(FontButton), desc : Pointer(FontDescriptor))
    fun font_button_on_changed = uiFontButtonOnChanged(b : Pointer(FontButton), f : (Pointer(FontButton), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_font_button = uiNewFontButton : Pointer(FontButton)
    fun free_font_button_font = uiFreeFontButtonFont(desc : Pointer(FontDescriptor))
    alias ColorButton = Void
    fun color_button_color = uiColorButtonColor(b : Pointer(ColorButton), r : Pointer(LibC::Double), g : Pointer(LibC::Double), bl : Pointer(LibC::Double), a : Pointer(LibC::Double))
    fun color_button_set_color = uiColorButtonSetColor(b : Pointer(ColorButton), r : LibC::Double, g : LibC::Double, bl : LibC::Double, a : LibC::Double)
    fun color_button_on_changed = uiColorButtonOnChanged(b : Pointer(ColorButton), f : (Pointer(ColorButton), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_color_button = uiNewColorButton : Pointer(ColorButton)
    alias Form = Void
    fun form_append = uiFormAppend(f : Pointer(Form), label : Pointer(LibC::Char), c : Pointer(Control), stretchy : LibC::Int)
    fun form_num_children = uiFormNumChildren(f : Pointer(Form)) : LibC::Int
    fun form_delete = uiFormDelete(f : Pointer(Form), index : LibC::Int)
    fun form_padded = uiFormPadded(f : Pointer(Form)) : Bool
    fun form_set_padded = uiFormSetPadded(f : Pointer(Form), padded : Bool)
    fun new_form = uiNewForm : Pointer(Form)

    alias Grid = Void
    fun grid_append = uiGridAppend(g : Pointer(Grid), c : Pointer(Control), left : LibC::Int, top : LibC::Int, xspan : LibC::Int, yspan : LibC::Int, hexpand : LibC::Int, halign : Align, vexpand : LibC::Int, valign : Align)
    fun grid_insert_at = uiGridInsertAt(g : Pointer(Grid), c : Pointer(Control), existing : Pointer(Control), at : At, xspan : LibC::Int, yspan : LibC::Int, hexpand : LibC::Int, halign : Align, vexpand : LibC::Int, valign : Align)
    fun grid_padded = uiGridPadded(g : Pointer(Grid)) : Bool
    fun grid_set_padded = uiGridSetPadded(g : Pointer(Grid), padded : Bool)
    fun new_grid = uiNewGrid : Pointer(Grid)
    alias Image = Void
    fun new_image = uiNewImage(width : LibC::Double, height : LibC::Double) : Pointer(Image)
    fun free_image = uiFreeImage(i : Pointer(Image))
    fun image_append = uiImageAppend(i : Pointer(Image), pixels : Pointer(Void), pixel_width : LibC::Int, pixel_height : LibC::Int, byte_stride : LibC::Int)

    alias TableValue = Void
    fun free_table_value = uiFreeTableValue(v : Pointer(TableValue))
    fun table_value_get_type = uiTableValueGetType(v : Pointer(TableValue)) : TableValueType
    fun new_table_value_string = uiNewTableValueString(str : Pointer(LibC::Char)) : Pointer(TableValue)
    fun table_value_string = uiTableValueString(v : Pointer(TableValue)) : Pointer(LibC::Char)
    fun new_table_value_image = uiNewTableValueImage(img : Pointer(Image)) : Pointer(TableValue)
    fun table_value_image = uiTableValueImage(v : Pointer(TableValue)) : Pointer(Image)
    fun new_table_value_int = uiNewTableValueInt(i : LibC::Int) : Pointer(TableValue)
    fun table_value_int = uiTableValueInt(v : Pointer(TableValue)) : LibC::Int
    fun new_table_value_color = uiNewTableValueColor(r : LibC::Double, g : LibC::Double, b : LibC::Double, a : LibC::Double) : Pointer(TableValue)
    fun table_value_color = uiTableValueColor(v : Pointer(TableValue), r : Pointer(LibC::Double), g : Pointer(LibC::Double), b : Pointer(LibC::Double), a : Pointer(LibC::Double))
    alias TableModel = Void

    fun new_table_model = uiNewTableModel(mh : Pointer(TableModelHandler)) : Pointer(TableModel)
    fun free_table_model = uiFreeTableModel(m : Pointer(TableModel))
    fun table_model_row_inserted = uiTableModelRowInserted(m : Pointer(TableModel), new_index : LibC::Int)
    fun table_model_row_changed = uiTableModelRowChanged(m : Pointer(TableModel), index : LibC::Int)
    fun table_model_row_deleted = uiTableModelRowDeleted(m : Pointer(TableModel), old_index : LibC::Int)

    alias Table = Void
    fun table_append_text_column = uiTableAppendTextColumn(t : Pointer(Table), name : Pointer(LibC::Char), text_model_column : LibC::Int, text_editable_model_column : LibC::Int, text_params : Pointer(TableTextColumnOptionalParams))
    fun table_append_image_column = uiTableAppendImageColumn(t : Pointer(Table), name : Pointer(LibC::Char), image_model_column : LibC::Int)
    fun table_append_image_text_column = uiTableAppendImageTextColumn(t : Pointer(Table), name : Pointer(LibC::Char), image_model_column : LibC::Int, text_model_column : LibC::Int, text_editable_model_column : LibC::Int, text_params : Pointer(TableTextColumnOptionalParams))
    fun table_append_checkbox_column = uiTableAppendCheckboxColumn(t : Pointer(Table), name : Pointer(LibC::Char), checkbox_model_column : LibC::Int, checkbox_editable_model_column : LibC::Int)
    fun table_append_checkbox_text_column = uiTableAppendCheckboxTextColumn(t : Pointer(Table), name : Pointer(LibC::Char), checkbox_model_column : LibC::Int, checkbox_editable_model_column : LibC::Int, text_model_column : LibC::Int, text_editable_model_column : LibC::Int, text_params : Pointer(TableTextColumnOptionalParams))
    fun table_append_progress_bar_column = uiTableAppendProgressBarColumn(t : Pointer(Table), name : Pointer(LibC::Char), progress_model_column : LibC::Int)
    fun table_append_button_column = uiTableAppendButtonColumn(t : Pointer(Table), name : Pointer(LibC::Char), button_model_column : LibC::Int, button_clickable_model_column : LibC::Int)
    fun table_header_visible = uiTableHeaderVisible(t : Pointer(Table)) : Bool
    fun table_header_set_visible = uiTableHeaderSetVisible(t : Pointer(Table), visible : Bool)
    fun new_table = uiNewTable(params : Pointer(TableParams)) : Pointer(Table)
    fun table_on_row_clicked = uiTableOnRowClicked(t : Pointer(Table), f : (Pointer(Table), LibC::Int, Pointer(Void) -> Void), data : Pointer(Void))
    fun table_on_row_double_clicked = uiTableOnRowDoubleClicked(t : Pointer(Table), f : (Pointer(Table), LibC::Int, Pointer(Void) -> Void), data : Pointer(Void))
    fun table_header_set_sort_indicator = uiTableHeaderSetSortIndicator(t : Pointer(Table), column : LibC::Int, indicator : SortIndicator)
    fun table_header_sort_indicator = uiTableHeaderSortIndicator(t : Pointer(Table), column : LibC::Int) : SortIndicator
    fun table_header_on_clicked = uiTableHeaderOnClicked(t : Pointer(Table), f : (Pointer(Table), LibC::Int, Pointer(Void) -> Void), data : Pointer(Void))
    fun table_column_width = uiTableColumnWidth(t : Pointer(Table), column : LibC::Int) : LibC::Int
    fun table_column_set_width = uiTableColumnSetWidth(t : Pointer(Table), column : LibC::Int, width : LibC::Int)

    fun table_get_selection_mode = uiTableGetSelectionMode(t : Pointer(Table))
    fun table_set_selection_mode = uiTableSetSelectionMode(t : Pointer(Table), mode : TableSelectionMode)
    fun table_on_selection_changed = uiTableOnSelectionChanged(t : Pointer(Table), f : (Pointer(Table), Pointer(Void) -> Void), data : Pointer(Void))

    fun table_get_selection = uiTableGetSelection(t : Pointer(Table)) : Pointer(TableSelection)
    fun table_set_selection = uiTableSetSelection(t : Pointer(Table), sel : Pointer(TableSelection))
    fun free_table_selection = uiFreeTableSelection(s : Pointer(TableSelection))
  end
end
