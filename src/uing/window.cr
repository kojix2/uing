require "./control"

module UIng
  class Window
    include Control; block_constructor

    # Store callback boxes to prevent GC collection
    @on_position_changed_box : Pointer(Void)?
    @on_content_size_changed_box : Pointer(Void)?
    @on_closing_box : Pointer(Void)?
    @on_focus_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Window))
    end

    def initialize(title, width, height, has_menubar = false, margined : Bool = false)
      @ref_ptr = LibUI.new_window(title, width, height, has_menubar)
      set_margined(true) if margined
    end

    def on_position_changed(&block : (LibC::Int, LibC::Int) -> Void)
      wrapper = -> { block.call(*self.position) }
      @on_position_changed_box = ::Box.box(wrapper)
      UIng.window_on_position_changed(@ref_ptr, @on_position_changed_box.not_nil!, &wrapper)
    end

    def on_content_size_changed(&block : (LibC::Int, LibC::Int) -> Void)
      wrapper = -> { block.call(*self.content_size) }
      @on_content_size_changed_box = ::Box.box(wrapper)
      UIng.window_on_content_size_changed(@ref_ptr, @on_content_size_changed_box.not_nil!, &wrapper)
    end

    def on_closing(&block : -> U) forall U
      wrapper = -> { block.call ? true : false }
      @on_closing_box = ::Box.box(wrapper)
      UIng.window_on_closing(@ref_ptr, @on_closing_box.not_nil!, &wrapper)
    end

    def on_focus_changed(&block : Bool -> Void)
      wrapper = -> { block.call(self.focused) }
      @on_focus_changed_box = ::Box.box(wrapper)
      UIng.window_on_focus_changed(@ref_ptr, @on_focus_changed_box.not_nil!, &wrapper)
    end

    def fullscreen?
      fullscreen
    end

    def focused?
      focused
    end

    def borderless?
      borderless
    end

    def margined?
      margined
    end

    def resizeable?
      resizeable
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
