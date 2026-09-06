module UIng
  class Area < Control
    # This class provides read-only access to key event properties.
    class KeyEvent
      def initialize(ref_ptr : LibUI::AreaKeyEvent*)
        @cstruct = ref_ptr.value
      end

      def key : Char?
        value = @cstruct.key
        value == 0 ? nil : value.chr
      end

      def ext_key : ExtKey?
        value = @cstruct.ext_key
        value.value == 0 ? nil : value
      end

      def modifier : Modifiers
        @cstruct.modifier
      end

      def modifiers : Modifiers
        @cstruct.modifiers
      end

      def up? : Bool
        @cstruct.up != 0
      end

      def to_unsafe
        pointerof(@cstruct)
      end
    end
  end
end
