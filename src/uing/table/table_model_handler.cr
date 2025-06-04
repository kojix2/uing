module UIng
  class TableModelHandler
    include BlockConstructor; block_constructor

    # Store callback blocks to prevent GC collection
    @num_columns_block : Proc(LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int)?
    @column_type_block : Proc(LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int, UIng::TableValueType)?
    @num_rows_block : Proc(LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int)?
    @cell_value_block : Proc(LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int, LibC::Int, LibUI::TableValue*)?
    @set_cell_value_block : Proc(LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int, LibC::Int, LibUI::TableValue*, Void)?

    def initialize(@cstruct : LibUI::TableModelHandler = LibUI::TableModelHandler.new)
    end

    def num_columns(&block : (LibUI::TableModelHandler*, LibUI::TableModel*) -> LibC::Int)
      @num_columns_block = block   # Store reference to prevent GC
      @cstruct.num_columns = block # Crystal automatically checks safety
    end

    def column_type(&block : (LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int) -> UIng::TableValueType)
      @column_type_block = block   # Store reference to prevent GC
      @cstruct.column_type = block # Crystal automatically checks safety
    end

    def num_rows(&block : (LibUI::TableModelHandler*, LibUI::TableModel*) -> LibC::Int)
      @num_rows_block = block   # Store reference to prevent GC
      @cstruct.num_rows = block # Crystal automatically checks safety
    end

    def cell_value(&block : (LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int, LibC::Int) -> LibUI::TableValue*)
      @cell_value_block = block   # Store reference to prevent GC
      @cstruct.cell_value = block # Crystal automatically checks safety
    end

    def set_cell_value(&block : (LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int, LibC::Int, LibUI::TableValue*) -> Void)
      @set_cell_value_block = block   # Store reference to prevent GC
      @cstruct.set_cell_value = block # Crystal automatically checks safety
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
