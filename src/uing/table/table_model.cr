module UIng
  class TableModel
    property? released : Bool = false
    property? managed_by_libui : Bool = false

    def initialize(@ref_ptr : Pointer(LibUI::TableModel))
      @managed_by_libui = true # TableModel managed by LibUI
    end

    def initialize(model_handler : (TableModelHandler | LibUI::TableModelHandler))
      @ref_ptr = LibUI.new_table_model(model_handler)
      @managed_by_libui = false # TableModel created by ourselves
    end

    def free : Nil
      return if @released
      return if @managed_by_libui # Don't free TableModel managed by LibUI
      LibUI.free_table_model(@ref_ptr)
      @released = true
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
