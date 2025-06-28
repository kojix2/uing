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

    @child_ref : Control? # Reference to the child control

    def initialize(@ref_ptr : Pointer(LibUI::Window), borrowed : Bool = true)
    end

    def initialize(title, width, height, menubar = false, margined : Bool = false)
      @ref_ptr = LibUI.new_window(title, width, height, menubar)
      @@mutex.synchronize do
        @@windows << self
      end
      self.margined = true if margined
    end

    def destroy
      return if @borrowed
      @@mutex.synchronize do
        @@windows.delete(self)
      end
      @on_position_changed_box = nil
      @on_content_size_changed_box = nil
      @on_closing_box = nil
      @on_focus_changed_box = nil
      super
    end

    # Raises: Not supported for this container.
    def delete(child : Control)
      raise "Window does not support delete(child : Control)"
    end

    def title : String?
      str_ptr = LibUI.window_title(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def title=(title : String) : Nil
      LibUI.window_set_title(@ref_ptr, title)
    end

    def position : {Int32, Int32}
      LibUI.window_position(@ref_ptr, out x, out y)
      {x, y}
    end

    def set_position(x : Int32, y : Int32) : Nil
      LibUI.window_set_position(@ref_ptr, x, y)
    end

    def content_size : {Int32, Int32}
      LibUI.window_content_size(@ref_ptr, out width, out height)
      {width, height}
    end

    def set_content_size(width : Int32, height : Int32) : Nil
      LibUI.window_set_content_size(@ref_ptr, width, height)
    end

    def fullscreen? : Bool
      LibUI.window_fullscreen(@ref_ptr)
    end

    def fullscreen=(fullscreen : Bool) : Nil
      LibUI.window_set_fullscreen(@ref_ptr, fullscreen)
    end

    def focused? : Bool
      LibUI.window_focused(@ref_ptr)
    end

    def borderless? : Bool
      LibUI.window_borderless(@ref_ptr)
    end

    def borderless=(borderless : Bool) : Nil
      LibUI.window_set_borderless(@ref_ptr, borderless)
    end

    def child=(control) : Nil
      control.check_can_move
      # libui-ng automatically replaces existing child, but we need to
      # release ownership on Crystal side to maintain reference consistency
      if child_ref = @child_ref
        child_ref.release_ownership
      end
      LibUI.window_set_child(@ref_ptr, UIng.to_control(control))
      @child_ref = control
      control.take_ownership(self)
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

    def margined? : Bool
      LibUI.window_margined(@ref_ptr)
    end

    def margined=(margined : Bool) : Nil
      LibUI.window_set_margined(@ref_ptr, margined)
    end

    def resizeable? : Bool
      LibUI.window_resizeable(@ref_ptr)
    end

    def resizeable=(resizeable : Bool) : Nil
      LibUI.window_set_resizeable(@ref_ptr, resizeable)
    end

    def on_position_changed(&block : (Int32, Int32) -> _)
      wrapper = -> {
        x, y = position
        block.call(x, y)
      }
      if boxed_data = (@on_position_changed_box = ::Box.box(wrapper))
        LibUI.window_on_position_changed(
          @ref_ptr,
          ->(_sender, data) {
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

    def on_content_size_changed(&block : (Int32, Int32) -> _)
      wrapper = -> {
        x, y = content_size
        block.call(x, y)
      }
      if boxed_data = (@on_content_size_changed_box = ::Box.box(wrapper))
        LibUI.window_on_content_size_changed(
          @ref_ptr,
          ->(_sender, data) {
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
      wrapper = -> { block.call }
      if boxed_data = (@on_closing_box = ::Box.box(wrapper))
        LibUI.window_on_closing(
          @ref_ptr,
          ->(_sender, data) {
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

    def on_focus_changed(&block : Bool -> _)
      wrapper = -> { block.call(focused?) }
      if boxed_data = (@on_focus_changed_box = ::Box.box(wrapper))
        LibUI.window_on_focus_changed(
          @ref_ptr,
          ->(_sender, data) {
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
      str_ptr = LibUI.open_file(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def open_folder : String?
      str_ptr = LibUI.open_folder(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def save_file : String?
      str_ptr = LibUI.save_file(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
