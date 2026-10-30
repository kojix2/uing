module UIng
  class Area < Control
    # Wheel and trackpad movement in an Area's drawing coordinates.
    class ScrollEvent
      protected def initialize(ref_ptr : LibUI::AreaScrollEvent*)
        @cstruct = ref_ptr.value
      end

      def x : Float64
        @cstruct.x
      end

      def y : Float64
        @cstruct.y
      end

      # Signed device scroll amount. Positive values mean right.
      def delta_x : Float64
        @cstruct.delta_x
      end

      # Signed device scroll amount. Positive values mean down.
      def delta_y : Float64
        @cstruct.delta_y
      end

      def modifiers : Modifiers
        @cstruct.modifiers
      end
    end
  end
end
