require "./control"

module UIng
  class Window < Control
    block_constructor

    # Mutex
    @@mutex = Mutex.new

    # Store references to Window to prevent GC collection
    @@windows : Array(Window) = [] of Window

    @borrowed : Bool = false # Flag to track if the window is borrowed

    # Store callback boxes to prevent GC collection
    @on_position_changed_box : Pointer(Void)?
    @on_content_size_changed_box : Pointer(Void)?
    @on_closing_box : Pointer(Void)?
    @on_focus_changed_box : Pointer(Void)?

    @child_ref : Control?   # Reference to the child control
    @toolbar_ref : Toolbar? # The native window borrows this toolbar

    def initialize(@ref_ptr : Pointer(LibUI::Window), borrowed : Bool = true)
      @borrowed = borrowed
      register_control
    end

    def initialize(title, width, height, menubar = false, margined : Bool = false)
      @ref_ptr = LibUI.new_window(title, width, height, menubar)
      @@mutex.synchronize do
        @@windows << self
      end
      self.margined = true if margined
      register_control
    end

    def destroy : Nil
      return if @borrowed
      super
    end

    protected def after_destroy : Nil
      @toolbar_ref.try &.__detached_by__(self)
      @toolbar_ref = nil
      @@mutex.synchronize do
        @@windows.delete(self)
      end
      @on_position_changed_box = nil
      @on_content_size_changed_box = nil
      @on_closing_box = nil
      @on_focus_changed_box = nil
      @child_ref = nil
    end

    def delete(child : Control)
      unless @child_ref.same?(child)
        raise "Window does not contain child"
      end
      self.child = nil
    end

    def title : String?
      str_ptr = LibUI.window_title(ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def title=(title : String) : Nil
      LibUI.window_set_title(ref_ptr, title)
    end

    def position : {Int32, Int32}
      LibUI.window_position(ref_ptr, out x, out y)
      {x, y}
    end

    def set_position(x : Int32, y : Int32) : Nil
      LibUI.window_set_position(ref_ptr, x, y)
    end

    def content_size : {Int32, Int32}
      LibUI.window_content_size(ref_ptr, out width, out height)
      {width, height}
    end

    def set_content_size(width : Int32, height : Int32) : Nil
      LibUI.window_set_content_size(ref_ptr, width, height)
    end

    def fullscreen? : Bool
      LibUI.window_fullscreen(ref_ptr)
    end

    def fullscreen=(fullscreen : Bool) : Nil
      LibUI.window_set_fullscreen(ref_ptr, fullscreen)
    end

    def focused? : Bool
      LibUI.window_focused(ref_ptr)
    end

    def borderless? : Bool
      LibUI.window_borderless(ref_ptr)
    end

    def borderless=(borderless : Bool) : Nil
      LibUI.window_set_borderless(ref_ptr, borderless)
    end

    def child=(control : Control) : Nil
      check_available
      control.check_can_move
      previous_child = @child_ref
      # uiWindowSetChild detaches the existing child; it does not destroy it.
      # Update the Crystal ownership graph only after the native operation
      # succeeds, so an exception cannot leave the two trees inconsistent.
      set_native_child(UIng.to_control(control))
      previous_child.try &.release_ownership
      @child_ref = control
      control.take_ownership(self)
    end

    def child=(control : Nil) : Nil
      check_available
      set_native_child(Pointer(LibUI::Control).null)
      @child_ref.try &.release_ownership
      @child_ref = nil
    end

    def child : Control?
      @child_ref
    end

    protected def set_native_child(child : Pointer(LibUI::Control)) : Nil
      LibUI.window_set_child(ref_ptr, child)
    end

    # alias for `child=`
    def set_child(control : Control) : Nil
      self.child = control
    end

    # For DSL style
    def set_child(&block : -> Control)
      control = block.call
      self.child = control
    end

    def toolbar : Toolbar?
      check_available
      @toolbar_ref
    end

    def toolbar=(toolbar : Toolbar) : Nil
      check_available
      return if @toolbar_ref.same?(toolbar)
      toolbar.__ensure_attachable__(self)
      previous_toolbar = @toolbar_ref
      LibUI.window_set_toolbar(ref_ptr, toolbar.to_unsafe)
      previous_toolbar.try &.__detached_by__(self)
      @toolbar_ref = toolbar
      toolbar.__attached_by__(self)
    end

    def toolbar=(toolbar : Nil) : Nil
      check_available
      return unless previous_toolbar = @toolbar_ref
      LibUI.window_set_toolbar(ref_ptr, Pointer(LibUI::Toolbar).null)
      @toolbar_ref = nil
      previous_toolbar.__detached_by__(self)
    end

    def margined? : Bool
      LibUI.window_margined(ref_ptr)
    end

    def margined=(margined : Bool) : Nil
      LibUI.window_set_margined(ref_ptr, margined)
    end

    def resizeable? : Bool
      LibUI.window_resizeable(ref_ptr)
    end

    def resizeable=(resizeable : Bool) : Nil
      LibUI.window_set_resizeable(ref_ptr, resizeable)
    end

    # libui spells this "resizeable"; provide the standard spelling as an alias.
    def resizable? : Bool
      resizeable?
    end

    def resizable=(resizable : Bool) : Nil
      self.resizeable = resizable
    end

    def on_position_changed(&block : (Int32, Int32) -> Nil)
      wrapper = -> : Nil {
        x, y = position
        block.call(x, y)
      }
      if boxed_data = (@on_position_changed_box = ::Box.box(wrapper))
        LibUI.window_on_position_changed(
          ref_ptr,
          ->(_sender, data) : Nil {
            begin
              data_as_callback = ::Box(typeof(wrapper)).unbox(data)
              data_as_callback.call
            rescue e
              UIng.handle_callback_error(e, "Window on_position_changed")
            end
          },
          boxed_data
        )
      end
    end

    def on_content_size_changed(&block : (Int32, Int32) -> Nil)
      wrapper = -> : Nil {
        x, y = content_size
        block.call(x, y)
      }
      if boxed_data = (@on_content_size_changed_box = ::Box.box(wrapper))
        LibUI.window_on_content_size_changed(
          ref_ptr,
          ->(_sender, data) : Nil {
            begin
              data_as_callback = ::Box(typeof(wrapper)).unbox(data)
              data_as_callback.call
            rescue e
              UIng.handle_callback_error(e, "Window on_content_size_changed")
            end
          },
          boxed_data
        )
      end
    end

    def on_closing(&block : -> Bool)
      wrapper = -> : Bool {
        handle_closing(block)
      }
      if boxed_data = (@on_closing_box = ::Box.box(wrapper))
        LibUI.window_on_closing(
          ref_ptr,
          ->(_sender, data) : Bool {
            begin
              data_as_callback = ::Box(typeof(wrapper)).unbox(data)
              data_as_callback.call
            rescue e
              UIng.handle_callback_error(e, "Window on_closing")
              false # Default to not closing on error
            end
          },
          boxed_data
        )
      end
    end

    protected def handle_closing(block : -> Bool) : Bool
      return false unless block.call
      # libui-ng calls uiControlDestroy() after this callback returns. Reflect
      # that commitment immediately, while retaining callback boxes until the
      # uiControlOnDestroyed notification transitions us to Destroyed.
      mark_destroy_pending
    end

    def on_focus_changed(&block : Bool -> Nil)
      wrapper = -> : Nil { block.call(focused?) }
      if boxed_data = (@on_focus_changed_box = ::Box.box(wrapper))
        LibUI.window_on_focus_changed(
          ref_ptr,
          ->(_sender, data) : Nil {
            begin
              data_as_callback = ::Box(typeof(wrapper)).unbox(data)
              data_as_callback.call
            rescue e
              UIng.handle_callback_error(e, "Window on_focus_changed")
            end
          },
          boxed_data
        )
      end
    end

    def open_file : String?
      str_ptr = LibUI.open_file(ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def open_folder : String?
      str_ptr = LibUI.open_folder(ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def save_file : String?
      str_ptr = LibUI.save_file(ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def msg_box(title : String, description : String) : Nil
      LibUI.msg_box(ref_ptr, title, description)
    end

    def msg_box_error(title : String, description : String) : Nil
      LibUI.msg_box_error(ref_ptr, title, description)
    end

    def to_unsafe
      ref_ptr
    end
  end
end
