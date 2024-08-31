module UIng
  class Entry
    def initialize(@ref_ptr : Pointer(LibUI::Entry))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_entry
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
