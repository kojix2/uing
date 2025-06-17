module UIng
  # This class provides read-only access to key event properties.
  class AreaMouseEvent
    def initialize(@ref_ptr : LibUI::AreaMouseEvent*)
      @cstruct = @ref_ptr.value
    end

    def x : Float64
      @cstruct.x
    end

    def y : Float64
      @cstruct.y
    end

    def area_width : Float64
      @cstruct.area_width
    end

    def area_height : Float64
      @cstruct.area_height
    end

    def down : Int32
      @cstruct.down
    end

    def up : Int32
      @cstruct.up
    end

    def count : Int32
      @cstruct.count
    end

    def modifiers : Modifiers
      @cstruct.modifiers
    end

    def held1_to64 : UInt64
      @cstruct.held1_to64
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
