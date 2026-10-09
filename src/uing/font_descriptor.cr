module UIng
  # Describes a font and owns its family name until #free is called.
  #
  # Descriptors yielded by FontButton callbacks and block methods are valid
  # only for the duration of the block. Use #snapshot to retain their values.
  class FontDescriptor
    # Store reference to family string to prevent garbage collection
    @family_string : String = ""
    @native_family = false
    getter? released = false

    def initialize(
      family : String? = nil, size : Number? = nil, weight : TextWeight? = nil,
      italic : TextItalic? = nil, stretch : TextStretch? = nil,
    )
      @cstruct = LibUI::FontDescriptor.new
      load_control_font unless family && size && weight && italic && stretch
      self.family = family if family
      self.size = size.to_f64 if size
      self.weight = weight if weight
      self.italic = italic if italic
      self.stretch = stretch if stretch
    end

    # Auto convert to and from String
    def family
      check_available
      if @cstruct.family.null?
        ""
      else
        # This copies the string from the C struct to a Crystal String
        String.new(@cstruct.family)
      end
    end

    def family=(value : String)
      check_available
      release_family
      @family_string = value
      @cstruct.family = @family_string.to_unsafe
    end

    def size
      check_available
      @cstruct.size
    end

    def size=(value : Number)
      check_available
      @cstruct.size = value.to_f64
    end

    def weight
      check_available
      @cstruct.weight
    end

    def weight=(value)
      check_available
      @cstruct.weight = value
    end

    def italic
      check_available
      @cstruct.italic
    end

    def italic=(value)
      check_available
      @cstruct.italic = value
    end

    def stretch
      check_available
      @cstruct.stretch
    end

    def stretch=(value)
      check_available
      @cstruct.stretch = value
    end

    # Returns an independently owned copy that remains valid after a borrowed
    # FontButton callback or block descriptor expires.
    def snapshot : FontDescriptor
      check_available
      FontDescriptor.new(
        family: family,
        size: size,
        weight: weight,
        italic: italic,
        stretch: stretch
      )
    end

    def free : Nil
      return if @released
      release_family
      @released = true
    end

    def load_control_font : Nil
      release_family
      @released = false
      LibUI.load_control_font(cstruct_pointer)
      @family_string = ""
      @native_family = true
    end

    def prepare_for_font_button_font : Nil
      release_family
      @released = false
    end

    def font_button_font_loaded : Nil
      @family_string = ""
      @native_family = true
      @released = false
    end

    # Compatibility alias for #free.
    def free_font_button_font : Nil
      free
    end

    def to_unsafe
      check_available
      cstruct_pointer
    end

    def finalize
      free
    end

    private def release_family : Nil
      return if @released

      LibUI.free_font_descriptor(cstruct_pointer) if @native_family

      @cstruct.family = Pointer(UInt8).null
      @family_string = ""
      @native_family = false
    end

    private def check_available : Nil
      raise "FontDescriptor has already been released" if @released
    end

    private def cstruct_pointer
      pointerof(@cstruct)
    end
  end
end
