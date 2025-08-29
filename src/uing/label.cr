require "./control"

module UIng
  class Label < Control
    block_constructor

    def initialize(text : String)
      @ref_ptr = LibUI.new_label(text)
    end

    def destroy
      super
    end

    def text : String?
      str_ptr = LibUI.label_text(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def text=(text : String) : Nil
      LibUI.label_set_text(@ref_ptr, text)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
