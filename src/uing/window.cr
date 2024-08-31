module UIng
  class Window
    def initialize(@ref_ptr : Pointer(LibUI::Window))
    end

    def initialize
      @ref_ptr = LibUI.new_window
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
