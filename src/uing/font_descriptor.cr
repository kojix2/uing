module UIng
  class FontDescriptor
    # Store reference to family string to prevent garbage collection
    @family_string : String = ""
    @family_borrowed = false # Getting a FontDescriptor from FontButton.

    @released = false

    def initialize(@cstruct : LibUI::FontDescriptor = LibUI::FontDescriptor.new)
    end

    def initialize(
      family : String? = nil, size : Int32? = nil, weight : TextWeight? = nil,
      italic : TextItalic? = nil, stretch : TextStretch? = nil,
    )
      @cstruct = LibUI::FontDescriptor.new
      load_control_font unless family && size && weight && italic && stretch
      self.family = family if family
      self.size = size if size
      self.weight = weight if weight
      self.italic = italic if italic
      self.stretch = stretch if stretch
    end

    # Auto convert to and from String
    def family
      if @cstruct.family.null?
        ""
      else
        # This copies the string from the C struct to a Crystal String
        String.new(@cstruct.family)
      end
    end

    def family=(value : String)
      @family_string = value
      @family_borrowed = false # manage memory on crystal side.
      @cstruct.family = @family_string.to_unsafe
    end

    def size
      @cstruct.size
    end

    def size=(value)
      @cstruct.size = value
    end

    def weight
      @cstruct.weight
    end

    def weight=(value)
      @cstruct.weight = value
    end

    def italic
      @cstruct.italic
    end

    def italic=(value)
      @cstruct.italic = value
    end

    def stretch
      @cstruct.stretch
    end

    def stretch=(value)
      @cstruct.stretch = value
    end

    def free : Nil
      return if @released
      @cstruct.family = Pointer(UInt8).null unless @family_borrowed
      LibUI.free_font_descriptor(to_unsafe)
      @released = true
    end

    def load_control_font : Nil
      LibUI.load_control_font(to_unsafe)
      @family_string = String.new(@cstruct.family)
      @family_borrowed = true # The family string is borrowed from the control font.
    end

    def to_unsafe
      pointerof(@cstruct)
    end

    def finalize
      free
    end
  end
end
