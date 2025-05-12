module UIng
  class TableModel
    def initialize(@ref_ptr : Pointer(LibUI::TableModel))
    end

    def initialize(model_handler : (TableModelHandler | LibUI::TableModelHandler))
      @ref_ptr = LibUI.new_table_model(model_handler)
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
