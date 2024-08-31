module UIng
  class AreaDrawParams
    def initialize(ptr_ref : LibUI::AreaDrawParams*)
      @cstruct = ptr_ref.value
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
