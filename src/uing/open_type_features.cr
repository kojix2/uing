module UIng
  class OpenTypeFeatures
    def initialize(@ref_ptr : Pointer(LibUI::OpenTypeFeatures))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_open_type_features
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
