module LibUI
  @[Link("#{__DIR__}/../../libui")]
  lib LibUI
    PI                    = 3.14159265358979323846264338327950288419716939937510582097494459
    DRAWDEFAULTMITERLIMIT =                                                             10.0

    struct InitOptions
      size : LibC::SizeT
    end

    fun init = uiInit(options : Pointer(Void)) : Pointer(LibC::Char)
    fun uninit = uiUninit
    fun free_init_error = uiFreeInitError(err : Pointer(LibC::Char))
    fun main = uiMain
    fun main_steps = uiMainSteps
    fun main_step = uiMainStep(wait : LibC::Int) : LibC::Int
    fun quit = uiQuit
    fun queue_main = uiQueueMain(f : (Pointer(Void) -> Void), data : Pointer(Void))
    fun timer = uiTimer(milliseconds : LibC::Int, f : (Pointer(Void) -> LibC::Int), data : Pointer(Void))
    fun on_should_quit = uiOnShouldQuit(f : (Pointer(Void) -> LibC::Int), data : Pointer(Void))
    fun free_text = uiFreeText(text : Pointer(LibC::Char))

    # struct Control
    #   signature : Void
    #   os_signature : Void
    #   type_signature : Void
    #   destroy : (Pointer(Void) -> Void)
    #   handle : (Pointer(Void) -> Void)
    #   parent : (Pointer(Void) -> Pointer(Void))
    #   set_parent : (Pointer(Void), Pointer(Void) -> Void)
    #   toplevel : (Pointer(Void) -> LibC::Int)
    #   visible : (Pointer(Void) -> LibC::Int)
    #   show : (Pointer(Void) -> Void)
    #   hide : (Pointer(Void) -> Void)
    #   enabled : (Pointer(Void) -> LibC::Int)
    #   enable : (Pointer(Void) -> Void)
    #   disable : (Pointer(Void) -> Void)
    # end

    fun control_destroy = uiControlDestroy(c : Pointer(Void))
    fun control_handle = uiControlHandle(c : Pointer(Void))
    fun control_parent = uiControlParent(c : Pointer(Void)) : Pointer(Void)
    fun control_set_parent = uiControlSetParent(c : Pointer(Void), parent : Pointer(Void))
    fun control_toplevel = uiControlToplevel(c : Pointer(Void)) : LibC::Int
    fun control_visible = uiControlVisible(c : Pointer(Void)) : LibC::Int
    fun control_show = uiControlShow(c : Pointer(Void))
    fun control_hide = uiControlHide(c : Pointer(Void))
    fun control_enabled = uiControlEnabled(c : Pointer(Void)) : LibC::Int
    fun control_enable = uiControlEnable(c : Pointer(Void))
    fun control_disable = uiControlDisable(c : Pointer(Void))
    fun alloc_control = uiAllocControl(n : LibC::SizeT, o_ssig : LibC::Int, typesig : LibC::Int, typenamestr : Pointer(LibC::Char)) : Pointer(Void)
    fun free_control = uiFreeControl(c : Pointer(Void))
    fun control_verify_set_parent = uiControlVerifySetParent(c : Pointer(Void), parent : Pointer(Void))
    fun control_enabled_to_user = uiControlEnabledToUser(c : Pointer(Void)) : LibC::Int
    fun user_bug_cannot_set_parent_on_toplevel = uiUserBugCannotSetParentOnToplevel(type : Pointer(LibC::Char))
    alias Window = Void
    fun window_title = uiWindowTitle(w : Pointer(Void)) : Pointer(LibC::Char)
    fun window_set_title = uiWindowSetTitle(w : Pointer(Void), title : Pointer(LibC::Char))
    fun window_position = uiWindowPosition(w : Pointer(Void), x : Pointer(LibC::Int), y : Pointer(LibC::Int))
    fun window_set_position = uiWindowSetPosition(w : Pointer(Void), x : LibC::Int, y : LibC::Int)
    fun window_on_position_changed = uiWindowOnPositionChanged(w : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun window_content_size = uiWindowContentSize(w : Pointer(Void), width : Pointer(LibC::Int), height : Pointer(LibC::Int))
    fun window_set_content_size = uiWindowSetContentSize(w : Pointer(Void), width : LibC::Int, height : LibC::Int)
    fun window_fullscreen = uiWindowFullscreen(w : Pointer(Void)) : LibC::Int
    fun window_set_fullscreen = uiWindowSetFullscreen(w : Pointer(Void), fullscreen : LibC::Int)
    fun window_on_content_size_changed = uiWindowOnContentSizeChanged(w : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun window_on_closing = uiWindowOnClosing(w : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> LibC::Int), data : Pointer(Void))
    fun window_on_focus_changed = uiWindowOnFocusChanged(w : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun window_focused = uiWindowFocused(w : Pointer(Void)) : LibC::Int
    fun window_borderless = uiWindowBorderless(w : Pointer(Void)) : LibC::Int
    fun window_set_borderless = uiWindowSetBorderless(w : Pointer(Void), borderless : LibC::Int)
    fun window_set_child = uiWindowSetChild(w : Pointer(Void), child : Pointer(Void))
    fun window_margined = uiWindowMargined(w : Pointer(Void)) : LibC::Int
    fun window_set_margined = uiWindowSetMargined(w : Pointer(Void), margined : LibC::Int)
    fun window_resizeable = uiWindowResizeable(w : Pointer(Void)) : LibC::Int
    fun window_set_resizeable = uiWindowSetResizeable(w : Pointer(Void), resizeable : LibC::Int)
    fun new_window = uiNewWindow(title : Pointer(LibC::Char), width : LibC::Int, height : LibC::Int, has_menubar : LibC::Int) : Pointer(Void)
    alias Button = Void
    fun button_text = uiButtonText(b : Pointer(Void)) : Pointer(LibC::Char)
    fun button_set_text = uiButtonSetText(b : Pointer(Void), text : Pointer(LibC::Char))
    fun button_on_clicked = uiButtonOnClicked(b : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_button = uiNewButton(text : Pointer(LibC::Char)) : Pointer(Void)
    alias Box = Void
    fun box_append = uiBoxAppend(b : Pointer(Void), child : Pointer(Void), stretchy : LibC::Int)
    fun box_num_children = uiBoxNumChildren(b : Pointer(Void)) : LibC::Int
    fun box_delete = uiBoxDelete(b : Pointer(Void), index : LibC::Int)
    fun box_padded = uiBoxPadded(b : Pointer(Void)) : LibC::Int
    fun box_set_padded = uiBoxSetPadded(b : Pointer(Void), padded : LibC::Int)
    fun new_horizontal_box = uiNewHorizontalBox : Pointer(Void)
    fun new_vertical_box = uiNewVerticalBox : Pointer(Void)
    alias Checkbox = Void
    fun checkbox_text = uiCheckboxText(c : Pointer(Void)) : Pointer(LibC::Char)
    fun checkbox_set_text = uiCheckboxSetText(c : Pointer(Void), text : Pointer(LibC::Char))
    fun checkbox_on_toggled = uiCheckboxOnToggled(c : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun checkbox_checked = uiCheckboxChecked(c : Pointer(Void)) : LibC::Int
    fun checkbox_set_checked = uiCheckboxSetChecked(c : Pointer(Void), checked : LibC::Int)
    fun new_checkbox = uiNewCheckbox(text : Pointer(LibC::Char)) : Pointer(Void)
    alias Entry = Void
    fun entry_text = uiEntryText(e : Pointer(Void)) : Pointer(LibC::Char)
    fun entry_set_text = uiEntrySetText(e : Pointer(Void), text : Pointer(LibC::Char))
    fun entry_on_changed = uiEntryOnChanged(e : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun entry_read_only = uiEntryReadOnly(e : Pointer(Void)) : LibC::Int
    fun entry_set_read_only = uiEntrySetReadOnly(e : Pointer(Void), readonly : LibC::Int)
    fun new_entry = uiNewEntry : Pointer(Void)
    fun new_password_entry = uiNewPasswordEntry : Pointer(Void)
    fun new_search_entry = uiNewSearchEntry : Pointer(Void)
    alias Label = Void
    fun label_text = uiLabelText(l : Pointer(Void)) : Pointer(LibC::Char)
    fun label_set_text = uiLabelSetText(l : Pointer(Void), text : Pointer(LibC::Char))
    fun new_label = uiNewLabel(text : Pointer(LibC::Char)) : Pointer(Void)
    alias Tab = Void
    fun tab_append = uiTabAppend(t : Pointer(Void), name : Pointer(LibC::Char), c : Pointer(Void))
    fun tab_insert_at = uiTabInsertAt(t : Pointer(Void), name : Pointer(LibC::Char), index : LibC::Int, c : Pointer(Void))
    fun tab_delete = uiTabDelete(t : Pointer(Void), index : LibC::Int)
    fun tab_num_pages = uiTabNumPages(t : Pointer(Void)) : LibC::Int
    fun tab_margined = uiTabMargined(t : Pointer(Void), index : LibC::Int) : LibC::Int
    fun tab_set_margined = uiTabSetMargined(t : Pointer(Void), index : LibC::Int, margined : LibC::Int)
    fun new_tab = uiNewTab : Pointer(Void)
    alias Group = Void
    fun group_title = uiGroupTitle(g : Pointer(Void)) : Pointer(LibC::Char)
    fun group_set_title = uiGroupSetTitle(g : Pointer(Void), title : Pointer(LibC::Char))
    fun group_set_child = uiGroupSetChild(g : Pointer(Void), c : Pointer(Void))
    fun group_margined = uiGroupMargined(g : Pointer(Void)) : LibC::Int
    fun group_set_margined = uiGroupSetMargined(g : Pointer(Void), margined : LibC::Int)
    fun new_group = uiNewGroup(title : Pointer(LibC::Char)) : Pointer(Void)
    alias Spinbox = Void
    fun spinbox_value = uiSpinboxValue(s : Pointer(Void)) : LibC::Int
    fun spinbox_set_value = uiSpinboxSetValue(s : Pointer(Void), value : LibC::Int)
    fun spinbox_on_changed = uiSpinboxOnChanged(s : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_spinbox = uiNewSpinbox(min : LibC::Int, max : LibC::Int) : Pointer(Void)
    alias Slider = Void
    fun slider_value = uiSliderValue(s : Pointer(Void)) : LibC::Int
    fun slider_set_value = uiSliderSetValue(s : Pointer(Void), value : LibC::Int)
    fun slider_has_tool_tip = uiSliderHasToolTip(s : Pointer(Void)) : LibC::Int
    fun slider_set_has_tool_tip = uiSliderSetHasToolTip(s : Pointer(Void), has_tool_tip : LibC::Int)
    fun slider_on_changed = uiSliderOnChanged(s : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun slider_on_released = uiSliderOnReleased(s : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun slider_set_range = uiSliderSetRange(s : Pointer(Void), min : LibC::Int, max : LibC::Int)
    fun new_slider = uiNewSlider(min : LibC::Int, max : LibC::Int) : Pointer(Void)
    alias ProgressBar = Void
    fun progress_bar_value = uiProgressBarValue(p : Pointer(Void)) : LibC::Int
    fun progress_bar_set_value = uiProgressBarSetValue(p : Pointer(Void), n : LibC::Int)
    fun new_progress_bar = uiNewProgressBar : Pointer(Void)
    alias Separator = Void
    fun new_horizontal_separator = uiNewHorizontalSeparator : Pointer(Void)
    fun new_vertical_separator = uiNewVerticalSeparator : Pointer(Void)
    alias Combobox = Void
    fun combobox_append = uiComboboxAppend(c : Pointer(Void), text : Pointer(LibC::Char))
    fun combobox_insert_at = uiComboboxInsertAt(c : Pointer(Void), index : LibC::Int, text : Pointer(LibC::Char))
    fun combobox_delete = uiComboboxDelete(c : Pointer(Void), index : LibC::Int)
    fun combobox_clear = uiComboboxClear(c : Pointer(Void))
    fun combobox_num_items = uiComboboxNumItems(c : Pointer(Void)) : LibC::Int
    fun combobox_selected = uiComboboxSelected(c : Pointer(Void)) : LibC::Int
    fun combobox_set_selected = uiComboboxSetSelected(c : Pointer(Void), index : LibC::Int)
    fun combobox_on_selected = uiComboboxOnSelected(c : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_combobox = uiNewCombobox : Pointer(Void)
    alias EditableCombobox = Void
    fun editable_combobox_append = uiEditableComboboxAppend(c : Pointer(Void), text : Pointer(LibC::Char))
    fun editable_combobox_text = uiEditableComboboxText(c : Pointer(Void)) : Pointer(LibC::Char)
    fun editable_combobox_set_text = uiEditableComboboxSetText(c : Pointer(Void), text : Pointer(LibC::Char))
    fun editable_combobox_on_changed = uiEditableComboboxOnChanged(c : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_editable_combobox = uiNewEditableCombobox : Pointer(Void)
    alias RadioButtons = Void
    fun radio_buttons_append = uiRadioButtonsAppend(r : Pointer(Void), text : Pointer(LibC::Char))
    fun radio_buttons_selected = uiRadioButtonsSelected(r : Pointer(Void)) : LibC::Int
    fun radio_buttons_set_selected = uiRadioButtonsSetSelected(r : Pointer(Void), index : LibC::Int)
    fun radio_buttons_on_selected = uiRadioButtonsOnSelected(r : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_radio_buttons = uiNewRadioButtons : Pointer(Void)
    alias DateTimePicker = Void
    fun date_time_picker_time = uiDateTimePickerTime(d : Pointer(Void), time : Pointer(Tm))
    alias Tm = Void
    fun date_time_picker_set_time = uiDateTimePickerSetTime(d : Pointer(Void), time : Pointer(Tm))
    fun date_time_picker_on_changed = uiDateTimePickerOnChanged(d : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_date_time_picker = uiNewDateTimePicker : Pointer(Void)
    fun new_date_picker = uiNewDatePicker : Pointer(Void)
    fun new_time_picker = uiNewTimePicker : Pointer(Void)
    alias MultilineEntry = Void
    fun multiline_entry_text = uiMultilineEntryText(e : Pointer(Void)) : Pointer(LibC::Char)
    fun multiline_entry_set_text = uiMultilineEntrySetText(e : Pointer(Void), text : Pointer(LibC::Char))
    fun multiline_entry_append = uiMultilineEntryAppend(e : Pointer(Void), text : Pointer(LibC::Char))
    fun multiline_entry_on_changed = uiMultilineEntryOnChanged(e : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun multiline_entry_read_only = uiMultilineEntryReadOnly(e : Pointer(Void)) : LibC::Int
    fun multiline_entry_set_read_only = uiMultilineEntrySetReadOnly(e : Pointer(Void), readonly : LibC::Int)
    fun new_multiline_entry = uiNewMultilineEntry : Pointer(Void)
    fun new_non_wrapping_multiline_entry = uiNewNonWrappingMultilineEntry : Pointer(Void)
    alias MenuItem = Void
    fun menu_item_enable = uiMenuItemEnable(m : Pointer(Void))
    fun menu_item_disable = uiMenuItemDisable(m : Pointer(Void))
    fun menu_item_on_clicked = uiMenuItemOnClicked(m : Pointer(Void), f : (Pointer(Void), Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun menu_item_checked = uiMenuItemChecked(m : Pointer(Void)) : LibC::Int
    fun menu_item_set_checked = uiMenuItemSetChecked(m : Pointer(Void), checked : LibC::Int)
    alias Menu = Void
    fun menu_append_item = uiMenuAppendItem(m : Pointer(Void), name : Pointer(LibC::Char)) : Pointer(Void)
    fun menu_append_check_item = uiMenuAppendCheckItem(m : Pointer(Void), name : Pointer(LibC::Char)) : Pointer(Void)
    fun menu_append_quit_item = uiMenuAppendQuitItem(m : Pointer(Void)) : Pointer(Void)
    fun menu_append_preferences_item = uiMenuAppendPreferencesItem(m : Pointer(Void)) : Pointer(Void)
    fun menu_append_about_item = uiMenuAppendAboutItem(m : Pointer(Void)) : Pointer(Void)
    fun menu_append_separator = uiMenuAppendSeparator(m : Pointer(Void))
    fun new_menu = uiNewMenu(name : Pointer(LibC::Char)) : Pointer(Void)
    fun open_file = uiOpenFile(parent : Pointer(Void)) : Pointer(LibC::Char)
    fun open_folder = uiOpenFolder(parent : Pointer(Void)) : Pointer(LibC::Char)
    fun save_file = uiSaveFile(parent : Pointer(Void)) : Pointer(LibC::Char)
    fun msg_box = uiMsgBox(parent : Pointer(Void), title : Pointer(LibC::Char), description : Pointer(LibC::Char))
    fun msg_box_error = uiMsgBoxError(parent : Pointer(Void), title : Pointer(LibC::Char), description : Pointer(LibC::Char))
    alias Area = Void

    struct AreaHandler
      draw : (Pointer(Void), Pointer(Void), Pointer(Void) -> Void)
      mouse_event : (Pointer(Void), Pointer(Void), Pointer(Void) -> Void)
      mouse_crossed : (Pointer(Void), Pointer(Void), LibC::Int -> Void)
      drag_broken : (Pointer(Void), Pointer(Void) -> Void)
      key_event : (Pointer(Void), Pointer(Void), Pointer(Void) -> LibC::Int)
    end

    enum WindowResizeEdge
      Left
      Top
      Right
      Bottom
      TopLeft
      TopRight
      BottomLeft
      BottomRight
    end

    struct AreaDrawParams
      context : Pointer(Void)
      area_width : LibC::Double
      area_height : LibC::Double
      clip_x : LibC::Double
      clip_y : LibC::Double
      clip_width : LibC::Double
      clip_height : LibC::Double
    end

    enum Modifiers
      Ctrl  = 1 << 0
      Alt   = 1 << 1
      Shift = 1 << 2
      Super = 1 << 3
    end

    struct AreaMouseEvent
      x : LibC::Double
      y : LibC::Double
      area_width : LibC::Double
      area_height : LibC::Double
      down : LibC::Int
      up : LibC::Int
      count : LibC::Int
      modifiers : Modifiers
      held1_to64 : UInt64
    end

    enum ExtKey
      Escape    = 1
      Insert # equivalent to "Help" on Apple keyboards
      Delete
      Home
      End
      PageUp
      PageDown
      Up
      Down
      Left
      Right
      F1 # F1..F12 are guaranteed to be consecutive
      F2
      F3
      F4
      F5
      F6
      F7
      F8
      F9
      F10
      F11
      F12
      N0 # numpad keys; independent of Num Lock state
      N1 # N0..N9 are guaranteed to be consecutive
      N2
      N3
      N4
      N5
      N6
      N7
      N8
      N9
      NDot
      NEnter
      NAdd
      NSubtract
      NMultiply
      NDivide
    end

    struct AreaKeyEvent
      key : LibC::Char
      ext_key : ExtKey
      modifier : Modifiers
      modifiers : Modifiers
      up : LibC::Int
    end

    alias DrawContext = Void
    fun area_set_size = uiAreaSetSize(a : Pointer(Void), width : LibC::Int, height : LibC::Int)
    fun area_queue_redraw_all = uiAreaQueueRedrawAll(a : Pointer(Void))
    fun area_scroll_to = uiAreaScrollTo(a : Pointer(Void), x : LibC::Double, y : LibC::Double, width : LibC::Double, height : LibC::Double)
    fun area_begin_user_window_move = uiAreaBeginUserWindowMove(a : Pointer(Void))
    fun area_begin_user_window_resize = uiAreaBeginUserWindowResize(a : Pointer(Void), edge : WindowResizeEdge)
    fun new_area = uiNewArea(ah : Pointer(Void)) : Pointer(Void)
    fun new_scrolling_area = uiNewScrollingArea(ah : Pointer(Void), width : LibC::Int, height : LibC::Int) : Pointer(Void)
    alias DrawPath = Void

    enum DrawBrushType
      Solid
      LinearGradient
      RadialGradient
      Image
    end

    enum DrawLineCap
      Flat
      Round
      Square
    end

    enum DrawLineJoin
      Miter
      Round
      Bevel
    end

    struct DrawBrush
      type : DrawBrushType
      r : LibC::Double
      g : LibC::Double
      b : LibC::Double
      a : LibC::Double
      x0 : LibC::Double
      y0 : LibC::Double
      x1 : LibC::Double
      y1 : LibC::Double
      outer_radius : LibC::Double
      stops : Pointer(Void)
      num_stops : LibC::SizeT
    end

    struct DrawStrokeParams
      cap : DrawLineCap
      join : DrawLineJoin
      thickness : LibC::Double
      miter_limit : LibC::Double
      dashes : Pointer(LibC::Double)
      num_dashes : LibC::SizeT
      dash_phase : LibC::Double
    end

    enum DrawFillMode
      Winding
      Alternate
    end

    struct DrawMatrix
      m11 : LibC::Double
      m12 : LibC::Double
      m21 : LibC::Double
      m22 : LibC::Double
      m31 : LibC::Double
      m32 : LibC::Double
    end

    struct DrawBrushGradientStop
      pos : LibC::Double
      r : LibC::Double
      g : LibC::Double
      b : LibC::Double
      a : LibC::Double
    end

    fun draw_new_path = uiDrawNewPath(fill_mode : DrawFillMode) : Pointer(Void)
    fun draw_free_path = uiDrawFreePath(p : Pointer(Void))
    fun draw_path_new_figure = uiDrawPathNewFigure(p : Pointer(Void), x : LibC::Double, y : LibC::Double)
    fun draw_path_new_figure_with_arc = uiDrawPathNewFigureWithArc(p : Pointer(Void), x_center : LibC::Double, y_center : LibC::Double, radius : LibC::Double, start_angle : LibC::Double, sweep : LibC::Double, negative : LibC::Int)
    fun draw_path_line_to = uiDrawPathLineTo(p : Pointer(Void), x : LibC::Double, y : LibC::Double)
    fun draw_path_arc_to = uiDrawPathArcTo(p : Pointer(Void), x_center : LibC::Double, y_center : LibC::Double, radius : LibC::Double, start_angle : LibC::Double, sweep : LibC::Double, negative : LibC::Int)
    fun draw_path_bezier_to = uiDrawPathBezierTo(p : Pointer(Void), c1x : LibC::Double, c1y : LibC::Double, c2x : LibC::Double, c2y : LibC::Double, end_x : LibC::Double, end_y : LibC::Double)
    fun draw_path_close_figure = uiDrawPathCloseFigure(p : Pointer(Void))
    fun draw_path_add_rectangle = uiDrawPathAddRectangle(p : Pointer(Void), x : LibC::Double, y : LibC::Double, width : LibC::Double, height : LibC::Double)
    fun draw_path_ended = uiDrawPathEnded(p : Pointer(Void)) : LibC::Int
    fun draw_path_end = uiDrawPathEnd(p : Pointer(Void))
    fun draw_stroke = uiDrawStroke(c : Pointer(Void), path : Pointer(Void), b : Pointer(Void), p : Pointer(Void))
    fun draw_fill = uiDrawFill(c : Pointer(Void), path : Pointer(Void), b : Pointer(Void))
    fun draw_matrix_set_identity = uiDrawMatrixSetIdentity(m : Pointer(Void))
    fun draw_matrix_translate = uiDrawMatrixTranslate(m : Pointer(Void), x : LibC::Double, y : LibC::Double)
    fun draw_matrix_scale = uiDrawMatrixScale(m : Pointer(Void), x_center : LibC::Double, y_center : LibC::Double, x : LibC::Double, y : LibC::Double)
    fun draw_matrix_rotate = uiDrawMatrixRotate(m : Pointer(Void), x : LibC::Double, y : LibC::Double, amount : LibC::Double)
    fun draw_matrix_skew = uiDrawMatrixSkew(m : Pointer(Void), x : LibC::Double, y : LibC::Double, xamount : LibC::Double, yamount : LibC::Double)
    fun draw_matrix_multiply = uiDrawMatrixMultiply(dest : Pointer(Void), src : Pointer(Void))
    fun draw_matrix_invertible = uiDrawMatrixInvertible(m : Pointer(Void)) : LibC::Int
    fun draw_matrix_invert = uiDrawMatrixInvert(m : Pointer(Void)) : LibC::Int
    fun draw_matrix_transform_point = uiDrawMatrixTransformPoint(m : Pointer(Void), x : Pointer(LibC::Double), y : Pointer(LibC::Double))
    fun draw_matrix_transform_size = uiDrawMatrixTransformSize(m : Pointer(Void), x : Pointer(LibC::Double), y : Pointer(LibC::Double))
    fun draw_transform = uiDrawTransform(c : Pointer(Void), m : Pointer(Void))
    fun draw_clip = uiDrawClip(c : Pointer(Void), path : Pointer(Void))
    fun draw_save = uiDrawSave(c : Pointer(Void))
    fun draw_restore = uiDrawRestore(c : Pointer(Void))
    alias Attribute = Void
    fun free_attribute = uiFreeAttribute(a : Pointer(Void))
    fun attribute_get_type = uiAttributeGetType(a : Pointer(Void))
    fun new_family_attribute = uiNewFamilyAttribute(family : Pointer(LibC::Char)) : Pointer(Void)
    fun attribute_family = uiAttributeFamily(a : Pointer(Void)) : Pointer(LibC::Char)
    fun new_size_attribute = uiNewSizeAttribute(size : LibC::Double) : Pointer(Void)
    fun attribute_size = uiAttributeSize(a : Pointer(Void)) : LibC::Double

    enum TextWeight
      Minimum    =    0
      Thin       =  100
      UltraLight =  200
      Light      =  300
      Book       =  350
      Normal     =  400
      Medium     =  500
      SemiBold   =  600
      Bold       =  700
      UltraBold  =  800
      Heavy      =  900
      UltraHeavy =  950
      Maximum    = 1000
    end

    fun new_weight_attribute = uiNewWeightAttribute(weight : TextWeight) : Pointer(Void)
    fun attribute_weight = uiAttributeWeight(a : Pointer(Void))

    enum TextItalic
      Normal
      Oblique
      Italic
    end

    fun new_italic_attribute = uiNewItalicAttribute(italic : TextItalic) : Pointer(Void)
    fun attribute_italic = uiAttributeItalic(a : Pointer(Void))

    enum TextStretch
      UltraCondensed
      ExtraCondensed
      Condensed
      SemiCondensed
      Normal
      SemiExpanded
      Expanded
      ExtraExpanded
      UltraExpanded
    end

    fun new_stretch_attribute = uiNewStretchAttribute(stretch : TextStretch) : Pointer(Void)
    fun attribute_stretch = uiAttributeStretch(a : Pointer(Void))
    fun new_color_attribute = uiNewColorAttribute(r : LibC::Double, g : LibC::Double, b : LibC::Double, a : LibC::Double) : Pointer(Void)
    fun attribute_color = uiAttributeColor(a : Pointer(Void), r : Pointer(LibC::Double), g : Pointer(LibC::Double), b : Pointer(LibC::Double), alpha : Pointer(LibC::Double))
    fun new_background_attribute = uiNewBackgroundAttribute(r : LibC::Double, g : LibC::Double, b : LibC::Double, a : LibC::Double) : Pointer(Void)

    enum Underline
      None
      Single
      Double
      Suggestion
    end

    fun new_underline_attribute = uiNewUnderlineAttribute(u : Underline) : Pointer(Void)
    fun attribute_underline = uiAttributeUnderline(a : Pointer(Void))

    enum UnderlineColor
      Custom
      Spelling
      Grammar
      Auxiliary
    end

    fun new_underline_color_attribute = uiNewUnderlineColorAttribute(u : UnderlineColor, r : LibC::Double, g : LibC::Double, b : LibC::Double, a : LibC::Double) : Pointer(Void)
    fun attribute_underline_color = uiAttributeUnderlineColor(a : Pointer(Void), u : Pointer(Void), r : Pointer(LibC::Double), g : Pointer(LibC::Double), b : Pointer(LibC::Double), alpha : Pointer(LibC::Double))
    alias OpenTypeFeatures = Void
    fun new_open_type_features = uiNewOpenTypeFeatures : Pointer(Void)
    fun free_open_type_features = uiFreeOpenTypeFeatures(otf : Pointer(Void))
    fun open_type_features_clone = uiOpenTypeFeaturesClone(otf : Pointer(Void)) : Pointer(Void)
    fun open_type_features_add = uiOpenTypeFeaturesAdd(otf : Pointer(Void), a : LibC::Char, b : LibC::Char, c : LibC::Char, d : LibC::Char, value : UInt32)
    fun open_type_features_remove = uiOpenTypeFeaturesRemove(otf : Pointer(Void), a : LibC::Char, b : LibC::Char, c : LibC::Char, d : LibC::Char)
    fun open_type_features_get = uiOpenTypeFeaturesGet(otf : Pointer(Void), a : LibC::Char, b : LibC::Char, c : LibC::Char, d : LibC::Char, value : Pointer(Void)) : LibC::Int
    fun open_type_features_for_each = uiOpenTypeFeaturesForEach(otf : Pointer(Void), f : Pointer(Void), data : Pointer(Void))
    fun new_features_attribute = uiNewFeaturesAttribute(otf : Pointer(Void)) : Pointer(Void)
    fun attribute_features = uiAttributeFeatures(a : Pointer(Void)) : Pointer(Void)
    alias AttributedString = Void
    fun new_attributed_string = uiNewAttributedString(initial_string : Pointer(LibC::Char)) : Pointer(Void)
    fun free_attributed_string = uiFreeAttributedString(s : Pointer(Void))
    fun attributed_string_string = uiAttributedStringString(s : Pointer(Void)) : Pointer(LibC::Char)
    fun attributed_string_len = uiAttributedStringLen(s : Pointer(Void))
    fun attributed_string_append_unattributed = uiAttributedStringAppendUnattributed(s : Pointer(Void), str : Pointer(LibC::Char))
    fun attributed_string_insert_at_unattributed = uiAttributedStringInsertAtUnattributed(s : Pointer(Void), str : Pointer(LibC::Char), at : LibC::SizeT)
    fun attributed_string_delete = uiAttributedStringDelete(s : Pointer(Void), start : LibC::SizeT, _end : LibC::SizeT)
    fun attributed_string_set_attribute = uiAttributedStringSetAttribute(s : Pointer(Void), a : Pointer(Void), start : LibC::SizeT, _end : LibC::SizeT)
    fun attributed_string_for_each_attribute = uiAttributedStringForEachAttribute(s : Pointer(Void), f : Pointer(Void), data : Pointer(Void))
    fun attributed_string_num_graphemes = uiAttributedStringNumGraphemes(s : Pointer(Void))
    fun attributed_string_byte_index_to_grapheme = uiAttributedStringByteIndexToGrapheme(s : Pointer(Void), pos : LibC::SizeT)
    fun attributed_string_grapheme_to_byte_index = uiAttributedStringGraphemeToByteIndex(s : Pointer(Void), pos : LibC::SizeT)

    struct FontDescriptor
      family : Pointer(LibC::Char)
      size : LibC::Double
      weight : TextWeight
      italic : TextItalic
      stretch : TextStretch
    end

    fun load_control_font = uiLoadControlFont(f : Pointer(Void))
    fun free_font_descriptor = uiFreeFontDescriptor(desc : Pointer(Void))
    alias DrawTextLayout = Void

    enum DrawTextAlign
      Left
      Center
      Right
    end

    struct DrawTextLayoutParams
      string : Pointer(Void)
      default_font : Pointer(Void)
      width : LibC::Double
      align : DrawTextAlign
    end

    fun draw_new_text_layout = uiDrawNewTextLayout(params : Pointer(Void)) : Pointer(Void)
    fun draw_free_text_layout = uiDrawFreeTextLayout(tl : Pointer(Void))
    fun draw_text = uiDrawText(c : Pointer(Void), tl : Pointer(Void), x : LibC::Double, y : LibC::Double)
    fun draw_text_layout_extents = uiDrawTextLayoutExtents(tl : Pointer(Void), width : Pointer(LibC::Double), height : Pointer(LibC::Double))
    alias FontButton = Void
    fun font_button_font = uiFontButtonFont(b : Pointer(Void), desc : Pointer(Void))
    fun font_button_on_changed = uiFontButtonOnChanged(b : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_font_button = uiNewFontButton : Pointer(Void)
    fun free_font_button_font = uiFreeFontButtonFont(desc : Pointer(Void))
    alias ColorButton = Void
    fun color_button_color = uiColorButtonColor(b : Pointer(Void), r : Pointer(LibC::Double), g : Pointer(LibC::Double), bl : Pointer(LibC::Double), a : Pointer(LibC::Double))
    fun color_button_set_color = uiColorButtonSetColor(b : Pointer(Void), r : LibC::Double, g : LibC::Double, bl : LibC::Double, a : LibC::Double)
    fun color_button_on_changed = uiColorButtonOnChanged(b : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))
    fun new_color_button = uiNewColorButton : Pointer(Void)
    alias Form = Void
    fun form_append = uiFormAppend(f : Pointer(Void), label : Pointer(LibC::Char), c : Pointer(Void), stretchy : LibC::Int)
    fun form_num_children = uiFormNumChildren(f : Pointer(Void)) : LibC::Int
    fun form_delete = uiFormDelete(f : Pointer(Void), index : LibC::Int)
    fun form_padded = uiFormPadded(f : Pointer(Void)) : LibC::Int
    fun form_set_padded = uiFormSetPadded(f : Pointer(Void), padded : LibC::Int)
    fun new_form = uiNewForm : Pointer(Void)

    enum Align
      Fill
      Start
      Center
      End
    end

    enum At
      Leading
      Top
      Trailing
      Bottom
    end

    alias Grid = Void
    fun grid_append = uiGridAppend(g : Pointer(Void), c : Pointer(Void), left : LibC::Int, top : LibC::Int, xspan : LibC::Int, yspan : LibC::Int, hexpand : LibC::Int, halign : Align, vexpand : LibC::Int, valign : Align)
    fun grid_insert_at = uiGridInsertAt(g : Pointer(Void), c : Pointer(Void), existing : Pointer(Void), at : At, xspan : LibC::Int, yspan : LibC::Int, hexpand : LibC::Int, halign : Align, vexpand : LibC::Int, valign : Align)
    fun grid_padded = uiGridPadded(g : Pointer(Void)) : LibC::Int
    fun grid_set_padded = uiGridSetPadded(g : Pointer(Void), padded : LibC::Int)
    fun new_grid = uiNewGrid : Pointer(Void)
    alias Image = Void
    fun new_image = uiNewImage(width : LibC::Double, height : LibC::Double) : Pointer(Void)
    fun free_image = uiFreeImage(i : Pointer(Void))
    fun image_append = uiImageAppend(i : Pointer(Void), pixels : Pointer(Void), pixel_width : LibC::Int, pixel_height : LibC::Int, byte_stride : LibC::Int)
    alias TableValue = Void
    fun free_table_value = uiFreeTableValue(v : Pointer(Void))
    fun table_value_get_type = uiTableValueGetType(v : Pointer(Void))
    fun new_table_value_string = uiNewTableValueString(str : Pointer(LibC::Char)) : Pointer(Void)
    fun table_value_string = uiTableValueString(v : Pointer(Void)) : Pointer(LibC::Char)
    fun new_table_value_image = uiNewTableValueImage(img : Pointer(Void)) : Pointer(Void)
    fun table_value_image = uiTableValueImage(v : Pointer(Void)) : Pointer(Void)
    fun new_table_value_int = uiNewTableValueInt(i : LibC::Int) : Pointer(Void)
    fun table_value_int = uiTableValueInt(v : Pointer(Void)) : LibC::Int
    fun new_table_value_color = uiNewTableValueColor(r : LibC::Double, g : LibC::Double, b : LibC::Double, a : LibC::Double) : Pointer(Void)
    fun table_value_color = uiTableValueColor(v : Pointer(Void), r : Pointer(LibC::Double), g : Pointer(LibC::Double), b : Pointer(LibC::Double), a : Pointer(LibC::Double))
    alias TableModel = Void

    enum SortIndicator
      None
      Ascending
      Descending
    end

    struct TableModelHandler
      num_columns : (Pointer(Void), Pointer(Void) -> LibC::Int)
      column_type : (Pointer(Void), Pointer(Void), LibC::Int -> Void)
      num_rows : (Pointer(Void), Pointer(Void) -> LibC::Int)
      cell_value : (Pointer(Void), Pointer(Void), LibC::Int, LibC::Int -> Pointer(Void))
      set_cell_value : (Pointer(Void), Pointer(Void), LibC::Int, LibC::Int, Pointer(Void) -> Void)
    end

    fun new_table_model = uiNewTableModel(mh : Pointer(Void)) : Pointer(Void)
    fun free_table_model = uiFreeTableModel(m : Pointer(Void))
    fun table_model_row_inserted = uiTableModelRowInserted(m : Pointer(Void), new_index : LibC::Int)
    fun table_model_row_changed = uiTableModelRowChanged(m : Pointer(Void), index : LibC::Int)
    fun table_model_row_deleted = uiTableModelRowDeleted(m : Pointer(Void), old_index : LibC::Int)

    struct TableTextColumnOptionalParams
      color_model_column : LibC::Int
    end

    struct TableParams
      model : Pointer(Void)
      row_background_color_model_column : LibC::Int
    end

    alias Table = Void
    fun table_append_text_column = uiTableAppendTextColumn(t : Pointer(Void), name : Pointer(LibC::Char), text_model_column : LibC::Int, text_editable_model_column : LibC::Int, text_params : Pointer(Void))
    fun table_append_image_column = uiTableAppendImageColumn(t : Pointer(Void), name : Pointer(LibC::Char), image_model_column : LibC::Int)
    fun table_append_image_text_column = uiTableAppendImageTextColumn(t : Pointer(Void), name : Pointer(LibC::Char), image_model_column : LibC::Int, text_model_column : LibC::Int, text_editable_model_column : LibC::Int, text_params : Pointer(Void))
    fun table_append_checkbox_column = uiTableAppendCheckboxColumn(t : Pointer(Void), name : Pointer(LibC::Char), checkbox_model_column : LibC::Int, checkbox_editable_model_column : LibC::Int)
    fun table_append_checkbox_text_column = uiTableAppendCheckboxTextColumn(t : Pointer(Void), name : Pointer(LibC::Char), checkbox_model_column : LibC::Int, checkbox_editable_model_column : LibC::Int, text_model_column : LibC::Int, text_editable_model_column : LibC::Int, text_params : Pointer(Void))
    fun table_append_progress_bar_column = uiTableAppendProgressBarColumn(t : Pointer(Void), name : Pointer(LibC::Char), progress_model_column : LibC::Int)
    fun table_append_button_column = uiTableAppendButtonColumn(t : Pointer(Void), name : Pointer(LibC::Char), button_model_column : LibC::Int, button_clickable_model_column : LibC::Int)
    fun table_header_visible = uiTableHeaderVisible(t : Pointer(Void)) : LibC::Int
    fun table_header_set_visible = uiTableHeaderSetVisible(t : Pointer(Void), visible : LibC::Int)
    fun new_table = uiNewTable(params : Pointer(Void)) : Pointer(Void)
    fun table_on_row_clicked = uiTableOnRowClicked(t : Pointer(Void), f : (Pointer(Void), LibC::Int, Pointer(Void) -> Void), data : Pointer(Void))
    fun table_on_row_double_clicked = uiTableOnRowDoubleClicked(t : Pointer(Void), f : (Pointer(Void), LibC::Int, Pointer(Void) -> Void), data : Pointer(Void))
    fun table_header_set_sort_indicator = uiTableHeaderSetSortIndicator(t : Pointer(Void), column : LibC::Int, indicator : SortIndicator)
    fun table_header_sort_indicator = uiTableHeaderSortIndicator(t : Pointer(Void), column : LibC::Int)
    fun table_header_on_clicked = uiTableHeaderOnClicked(t : Pointer(Void), f : (Pointer(Void), LibC::Int, Pointer(Void) -> Void), data : Pointer(Void))
    fun table_column_width = uiTableColumnWidth(t : Pointer(Void), column : LibC::Int) : LibC::Int
    fun table_column_set_width = uiTableColumnSetWidth(t : Pointer(Void), column : LibC::Int, width : LibC::Int)

    enum TableSelectionMode
      None
      ZeroOrOne
      One
      ZeroOrMany
    end

    fun table_get_selection_mode = uiTableGetSelectionMode(t : Pointer(Void))
    fun table_set_selection_mode = uiTableSetSelectionMode(t : Pointer(Void), mode : TableSelectionMode)
    fun table_on_selection_changed = uiTableOnSelectionChanged(t : Pointer(Void), f : (Pointer(Void), Pointer(Void) -> Void), data : Pointer(Void))

    struct TableSelection
      num_rows : LibC::Int
      rows : Pointer(LibC::Int)
    end

    fun table_get_selection = uiTableGetSelection(t : Pointer(Void)) : Pointer(Void)
    fun table_set_selection = uiTableSetSelection(t : Pointer(Void), sel : Pointer(Void))
    fun free_table_selection = uiFreeTableSelection(s : Pointer(Void))
  end
end
