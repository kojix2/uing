module UIng
  # A Crystal-managed font description. FontButton results and callback values
  # can be retained without manual freeing.
  class FontDescriptor
    include BlockConstructor; block_constructor

    @family_string : String = ""

    def initialize(
      family : String? = nil, size : Number? = nil, weight : TextWeight? = nil,
      italic : TextItalic? = nil, stretch : TextStretch? = nil,
    )
      converted_size = NumericValue.positive(size, "font descriptor size") if size
      @cstruct = LibUI::FontDescriptor.new
      load_control_font unless family && size && weight && italic && stretch
      self.family = family if family
      @cstruct.size = converted_size if converted_size
      self.weight = weight if weight
      self.italic = italic if italic
      self.stretch = stretch if stretch
    end

    def family : String
      @family_string
    end

    def family=(value : String)
      @family_string = value
      @cstruct.family = @family_string.to_unsafe
    end

    def size
      @cstruct.size
    end

    def size=(value : Number)
      @cstruct.size = NumericValue.positive(value, "font descriptor size")
    end

    def weight
      @cstruct.weight
    end

    def weight=(value : TextWeight)
      @cstruct.weight = value
    end

    def italic
      @cstruct.italic
    end

    def italic=(value : TextItalic)
      @cstruct.italic = value
    end

    def stretch
      @cstruct.stretch
    end

    def stretch=(value : TextStretch)
      @cstruct.stretch = value
    end

    # Returns an independent copy of this descriptor.
    def snapshot : FontDescriptor
      FontDescriptor.new(
        family: family,
        size: size,
        weight: weight,
        italic: italic,
        stretch: stretch
      )
    end

    private def load_control_font : Nil
      native = LibUI::FontDescriptor.new
      LibUI.load_control_font(pointerof(native))
      load_from_native(pointerof(native))
    end

    protected def self.from_font_button(button : Pointer(LibUI::FontButton)) : FontDescriptor
      native = LibUI::FontDescriptor.new
      LibUI.font_button_font(button, pointerof(native))
      from_native(pointerof(native))
    end

    private def self.from_native(native_ptr : Pointer(LibUI::FontDescriptor)) : FontDescriptor
      native = native_ptr.value
      FontDescriptor.new(
        family: native.family.null? ? "" : String.new(native.family),
        size: native.size,
        weight: native.weight,
        italic: native.italic,
        stretch: native.stretch
      )
    ensure
      LibUI.free_font_descriptor(native_ptr)
    end

    def to_unsafe
      cstruct_pointer
    end

    private def load_from_native(native_ptr : Pointer(LibUI::FontDescriptor)) : Nil
      native = native_ptr.value
      self.family = native.family.null? ? "" : String.new(native.family)
      @cstruct.size = native.size
      @cstruct.weight = native.weight
      @cstruct.italic = native.italic
      @cstruct.stretch = native.stretch
    ensure
      LibUI.free_font_descriptor(native_ptr)
    end

    private def cstruct_pointer
      pointerof(@cstruct)
    end
  end
end
