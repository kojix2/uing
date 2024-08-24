module UIng
  class FontDescriptor
    def initialize
      @cstruct = LibUI::FontDescriptor.new
    end

    # Auto convert to and from String
    def family
      String.new(@cstruct.family)
    end

    def family=(value : String)
      @family = value
      @cstruct.family = @family.to_unsafe
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
