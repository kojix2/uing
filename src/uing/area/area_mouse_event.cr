module UIng
  class AreaMouseEvent
    def initialize(@cstruct : LibUI::AreaMouseEvent = LibUI::AreaMouseEvent.new)
    end

    def x
      @cstruct.x
    end

    def y
      @cstruct.y
    end

    def area_width
      @cstruct.area_width
    end

    def area_height
      @cstruct.area_height
    end

    def down
      @cstruct.down
    end

    def up
      @cstruct.up
    end

    def count
      @cstruct.count
    end

    def modifiers
      @cstruct.modifiers
    end

    def held1_to64
      @cstruct.held1_to64
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
