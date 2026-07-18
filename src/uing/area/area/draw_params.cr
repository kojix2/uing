module UIng
  class Area < Control
    module Draw
      # This class provides read-only access to area draw parameters.
      class Params
        include BlockConstructor; block_constructor

        def initialize(ptr_ref : LibUI::AreaDrawParams*)
          @cstruct = ptr_ref.value
        end

        def context : Context
          Context.new(@cstruct.context)
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
  end
end
