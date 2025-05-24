require "./control"

module UIng
  class Window
    include Control

    # Store callback boxes to prevent GC collection
    @on_position_changed_box : Pointer(Void)?
    @on_content_size_changed_box : Pointer(Void)?
    @on_closing_box : Pointer(Void)?
    @on_focus_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Window))
    end

    def initialize(title, width, height, has_menubar)
      @ref_ptr = LibUI.new_window(title, width, height, has_menubar)
    end

    def on_position_changed(&block : -> Void)
      @on_position_changed_box = ::Box.box(block)
      UIng.window_on_position_changed(@ref_ptr, @on_position_changed_box.not_nil!, &block)
    end

    def on_content_size_changed(&block : -> Void)
      @on_content_size_changed_box = ::Box.box(block)
      UIng.window_on_content_size_changed(@ref_ptr, @on_content_size_changed_box.not_nil!, &block)
    end

    def on_closing(&block : -> U) forall U
      # FIXME: This is a workaround for the block return type
      block2 = -> {
        case r = block.call
        when Bool
          r ? 1 : 0
        else
          r
        end
      }
      @on_closing_box = ::Box.box(block2)
      UIng.window_on_closing(@ref_ptr, @on_closing_box.not_nil!, &block2)
    end

    def on_focus_changed(&block : -> Void)
      @on_focus_changed_box = ::Box.box(block)
      UIng.window_on_focus_changed(@ref_ptr, @on_focus_changed_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end

    def title=(value : String)
      set_title(value)
    end

    def margined=(value : Bool)
      set_margined(value ? 1 : 0)
    end

    def borderless=(value : Bool)
      set_borderless(value ? 1 : 0)
    end

    def resizeable=(value : Bool)
      set_resizeable(value ? 1 : 0)
    end

    def fullscreen=(value : Bool)
      set_fullscreen(value ? 1 : 0)
    end

    def child=(control)
      set_child(control)
    end
  end
end
