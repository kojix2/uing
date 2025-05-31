require "./control"

module UIng
  class Form
    include Control; block_constructor

    def initialize(@ref_ptr : Pointer(LibUI::Form))
    end

    def initialize
      @ref_ptr = LibUI.new_form
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
