module UIng
  class Table
    def initialize(@ref_ptr : Pointer(LibUI::Table))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_table
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
