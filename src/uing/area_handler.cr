module UIng
  class AreaHandler
    def initialize
      @cstruct = LibUI::AreaHandler.new
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
