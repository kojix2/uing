require "./control"

module UIng
  class Window
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Window))
    end

    def initialize(title, width, height, has_menubar : Bool = false)
      menubar_flag = has_menubar ? 1 : 0
      @ref_ptr = LibUI.new_window(title, width, height, menubar_flag)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
