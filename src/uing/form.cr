require "./control"

module UIng
  class Form
    include Control; block_constructor

    def initialize(@ref_ptr : Pointer(LibUI::Form))
    end

    def initialize(padded : Bool = false)
      @ref_ptr = LibUI.new_form
      set_padded(true) if padded
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
