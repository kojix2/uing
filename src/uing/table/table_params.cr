module UIng
  class TableParams
    include BlockConstructor; block_constructor

    def initialize(model : TableModel, row_background_color_model_column : LibC::Int = -1)
      @cstruct = LibUI::TableParams.new
      @cstruct.model = model.to_unsafe
      @cstruct.row_background_color_model_column = row_background_color_model_column
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
