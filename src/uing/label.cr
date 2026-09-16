require "./control"

module UIng
  class Label < Control
    block_constructor

    def initialize(text : String)
      @ref_ptr = LibUI.new_label(text)
      register_control
    end

    def text : String?
      str_ptr = LibUI.label_text(ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def text=(text : String) : Nil
      LibUI.label_set_text(ref_ptr, text)
    end

    # Returns the font size in typographical points.
    def font_size : Float64
      LibUI.label_font_size(ref_ptr)
    end

    # Sets the font size in typographical points without changing other font
    # properties.
    def font_size=(size : Number) : Nil
      check_available
      value = size.to_f64
      unless value.finite? && value > 0
        raise ArgumentError.new("label font size must be finite and positive")
      end
      LibUI.label_set_font_size(ref_ptr, value)
    end

    # Restores the platform-default font size that was in effect when this
    # label was created.
    def reset_font_size : Nil
      LibUI.label_reset_font_size(ref_ptr)
    end

    def to_unsafe
      ref_ptr
    end
  end
end
