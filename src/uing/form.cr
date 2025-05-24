require "./control"

module UIng
  class Form
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Form))
    end

    def initialize
      @ref_ptr = LibUI.new_form
    end

    def to_unsafe
      @ref_ptr
    end

    def padded=(value : Bool)
      set_padded(value ? 1 : 0)
    end
  end
end
