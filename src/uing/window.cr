require "./control"

module UIng
  class Window
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Window))
    end

    def initialize(title, width, height, has_menubar)
      @ref_ptr = LibUI.new_window(title, width, height, has_menubar)
    end

    def on_position_changed(&block : -> Void)
      UIng.window_on_position_changed(@ref_ptr, &block)
    end

    def on_content_size_changed(&block : -> Void)
      UIng.window_on_content_size_changed(@ref_ptr, &block)
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
      UIng.window_on_closing(@ref_ptr, &block2)
    end

    def window_on_focus_changed(&block : -> Void)
      UIng.window_on_focus_changed(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
