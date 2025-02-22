require "./control"

module UIng
  class Window
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Window))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_window
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
