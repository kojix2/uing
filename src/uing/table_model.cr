module UIng
  class TableModel
    def initialize(@ref_ptr : Pointer(LibUI::TableModel))
    end

    def initialize
      @ref_ptr = LibUI.new_table_model
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
