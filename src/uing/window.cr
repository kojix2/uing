require "./control"

module UIng
  class Window
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Window))
    end

    def initialize(title, width, height, has_menubar)
      @ref_ptr = LibUI.new_window(title, width, height, has_menubar)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
