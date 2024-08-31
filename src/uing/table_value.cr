module UIng
  class TableValue
    def initialize(@ref_ptr : Pointer(LibUI::TableValue))
    end

    def initialize
      @ref_ptr = LibUI.new_table_value
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
