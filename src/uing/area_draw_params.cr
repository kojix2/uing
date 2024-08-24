module UIng
  class AreaDrawParams
    def initialize
      @cstruct = LibUI::AreaDrawParams.new
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
