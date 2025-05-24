require "./control"

module UIng
  class Label
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Label))
    end

    def initialize(text : String)
      @ref_ptr = LibUI.new_label(text)
    end

    def to_unsafe
      @ref_ptr
    end

    def text=(value : String)
      set_text(value)
    end
  end
end
