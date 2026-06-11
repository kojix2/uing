module UIng
  class Area < Control
    # This class provides read-only access to key event properties.
    class KeyEvent
      def initialize(ref_ptr : LibUI::AreaKeyEvent*)
        @cstruct = ref_ptr.value
      end

      def key : Char
        @cstruct.key.chr
      end

      def ext_key : ExtKey
        @cstruct.ext_key
      end

      def modifier : Modifiers
        @cstruct.modifier
      end

      def modifiers : Modifiers
        @cstruct.modifiers
      end

      def up : Int32
        @cstruct.up
      end

      def to_unsafe
        pointerof(@cstruct)
      end
    end
  end
end
