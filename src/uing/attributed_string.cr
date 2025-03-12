module UIng
  class AttributedString
    property? released : Bool = false

    def initialize(@ref_ptr : Pointer(LibUI::AttributedString))
    end

    def initialize(string : String)
      @ref_ptr = LibUI.new_attributed_string(string)
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end

    def finalize
      unless @released
        LibUI.free_attributed_string(@ref_ptr)
        @released = true
      end
    end
  end
end
