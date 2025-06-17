module UIng
  class AreaDrawParams
    def initialize(ptr_ref : LibUI::AreaDrawParams*)
      @cstruct = ptr_ref.value
    end

    # This class is read-only

    def context : DrawContext
      DrawContext.new(@cstruct.context)
    end

    def area_width : Float64
      @cstruct.area_width
    end

    def area_height : Float64
      @cstruct.area_height
    end

    def clip_x : Float64
      @cstruct.clip_x
    end

    def clip_y : Float64
      @cstruct.clip_y
    end

    def clip_width : Float64
      @cstruct.clip_width
    end

    def clip_height : Float64
      @cstruct.clip_height
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
