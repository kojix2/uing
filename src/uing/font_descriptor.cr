module UIng
  class FontDescriptor
    private enum FamilyOwnership
      None
      ControlFont
      FontButton
    end

    # Store reference to family string to prevent garbage collection
    @family_string : String = ""
    @family_ownership = FamilyOwnership::None
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
      release_family
      @family_string = value
      @family_ownership = FamilyOwnership::None
      @released = false
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
      release_family
      @cstruct.family = Pointer(UInt8).null
      @released = true
    end

    def load_control_font : Nil
      release_family
      LibUI.load_control_font(to_unsafe)
      @family_string = ""
      @family_ownership = FamilyOwnership::ControlFont
      @released = false
    end

    def prepare_for_font_button_font : Nil
      release_family
      @released = false
    end

    def font_button_font_loaded : Nil
      @family_string = ""
      @family_ownership = FamilyOwnership::FontButton
      @released = false
    end

    def free_font_button_font : Nil
      return if @released
      if @family_ownership == FamilyOwnership::FontButton
        LibUI.free_font_button_font(to_unsafe)
        @cstruct.family = Pointer(UInt8).null
        @family_ownership = FamilyOwnership::None
      end
      @released = true
    end

    def to_unsafe
      pointerof(@cstruct)
    end

    def finalize
      free
    end

    private def release_family : Nil
      return if @released

      case @family_ownership
      in FamilyOwnership::None
        return
      in FamilyOwnership::ControlFont
        LibUI.free_font_descriptor(to_unsafe)
      in FamilyOwnership::FontButton
        LibUI.free_font_button_font(to_unsafe)
      end

      @cstruct.family = Pointer(UInt8).null
      @family_ownership = FamilyOwnership::None
    end
  end
end
