module UIng
  class FontDescriptor
    def initialize(@cstruct : LibUI::FontDescriptor = LibUI::FontDescriptor.new)
      @family = ""
    end

    # Auto convert to and from String
    def family
      String.new(@cstruct.family)
    end

    def family=(value : String)
      @family = value
      @cstruct.family = @family.to_unsafe
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
