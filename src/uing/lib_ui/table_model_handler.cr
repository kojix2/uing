module UIng
  lib LibUI
    struct TableModelHandler
      num_columns : (Pointer(TableModelHandler), Pointer(TableModel) -> LibC::Int)
      column_type : (Pointer(TableModelHandler), Pointer(TableModel), LibC::Int -> Void)
      num_rows : (Pointer(TableModelHandler), Pointer(TableModel) -> LibC::Int)
      cell_value : (Pointer(TableModelHandler), Pointer(TableModel), LibC::Int, LibC::Int -> Pointer(TableValue))
      set_cell_value : (Pointer(TableModelHandler), Pointer(TableModel), LibC::Int, LibC::Int, Pointer(TableValue) -> Void)
    end
  end
end
