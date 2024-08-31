module UIng
  class Attribute
    def initialize(@ref_ptr : Pointer(LibUI::Attribute))
    end

    def initialize
      @ref_ptr = LibUI.new_attribute
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
