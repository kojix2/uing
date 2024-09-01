module UIng
  class TableModelHandler
    def initialize(@cstruct : LibUI::TableModelHandler = LibUI::TableModelHandler.new)
    end

    forward_missing_to(@cstruct)

    def num_columns(&block : (LibUI::TableModelHandler*, LibUI::TableModel*) -> LibC::Int)
      @cstruct.num_columns = block
    end

    def column_type(&block : (LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int) -> LibUI::TableValueType)
      @cstruct.column_type = block
    end

    def num_rows(&block : (LibUI::TableModelHandler*, LibUI::TableModel*) -> LibC::Int)
      @cstruct.num_rows = block
    end

    def cell_value(&block : (LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int, LibC::Int) -> LibUI::TableValue*)
      @cstruct.cell_value = block
    end

    def set_cell_value(&block : (LibUI::TableModelHandler*, LibUI::TableModel*, LibC::Int, LibC::Int, LibUI::TableValue*) -> Void)
      @cstruct.set_cell_value = block
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
