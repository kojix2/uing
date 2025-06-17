module UIng
  # This class provides read-only access to key event properties.
  class AreaKeyEvent
    def initialize(ref_ptr : LibUI::AreaKeyEvent*)
      @cstruct = ref_ptr.value
    end

    def key
      @cstruct.key
    end

    def ext_key
      @cstruct.ext_key
    end

    def modifier
      @cstruct.modifier
    end

    def modifiers
      @cstruct.modifiers
    end

    def up
      @cstruct.up
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
