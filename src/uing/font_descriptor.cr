module UIng
  class FontDescriptor
    # Store reference to family string to prevent garbage collection
    @family_string : String?

    def initialize(@cstruct : LibUI::FontDescriptor = LibUI::FontDescriptor.new)
    end

    def initialize(family : String, size : Int32, weight : TextWeight, italic : TextItalic, stretch : TextStretch)
      @cstruct = LibUI::FontDescriptor.new
      self.family = family
      self.size = size
      self.weight = weight
      self.italic = italic
      self.stretch = stretch
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
      @cstruct.family = @family_string.not_nil!.to_unsafe
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
      LibUI.free_font_descriptor(to_unsafe)
    end

    def load_control_font : Nil
      LibUI.load_control_font(to_unsafe)
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
