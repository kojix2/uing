require "./control"

module UIng
  class Button
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Button))
    end

    def initialize(text : String)
      @ref_ptr = LibUI.new_button(text)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
