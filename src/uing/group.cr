module UIng
  class Group
    def initialize(@ref_ptr : Pointer(LibUI::Group))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_group
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
