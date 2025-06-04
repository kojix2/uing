module UIng
  class TableModel
    def initialize(@ref_ptr : Pointer(LibUI::TableModel))
    end

    def initialize(model_handler : (TableModelHandler | LibUI::TableModelHandler))
      @ref_ptr = LibUI.new_table_model(model_handler)
    end

    def free : Nil
      LibUI.free_table_model(@ref_ptr)
    end

    def row_inserted(new_index : Int32) : Nil
      LibUI.table_model_row_inserted(@ref_ptr, new_index)
    end

    def row_changed(index : Int32) : Nil
      LibUI.table_model_row_changed(@ref_ptr, index)
    end

    def row_deleted(old_index : Int32) : Nil
      LibUI.table_model_row_deleted(@ref_ptr, old_index)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
