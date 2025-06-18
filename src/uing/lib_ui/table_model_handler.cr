module UIng
  lib LibUI
    struct TableModelHandler
      num_columns : (Pointer(TableModelHandler), Pointer(TableModel) -> LibC::Int)
      column_type : (Pointer(TableModelHandler), Pointer(TableModel), LibC::Int -> UIng::Table::Value::Type)
      num_rows : (Pointer(TableModelHandler), Pointer(TableModel) -> LibC::Int)
      cell_value : (Pointer(TableModelHandler), Pointer(TableModel), LibC::Int, LibC::Int -> Pointer(TableValue))
      set_cell_value : (Pointer(TableModelHandler), Pointer(TableModel), LibC::Int, LibC::Int, Pointer(TableValue) -> Void)
    end

    # Extended handler structure that contains the base TableModelHandler
    # and individual boxes for each callback
    @[Packed]
    struct TableModelHandlerExtended
      base_handler : TableModelHandler
      num_columns_box : Pointer(Void)
      column_type_box : Pointer(Void)
      num_rows_box : Pointer(Void)
      cell_value_box : Pointer(Void)
      set_cell_value_box : Pointer(Void)
    end
  end
end
