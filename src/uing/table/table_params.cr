module UIng
  class TableParams
    include BlockConstructor; block_constructor

    def initialize(model : TableModel, row_background_color_model_column : LibC::Int = -1)
      @cstruct = LibUI::TableParams.new
      @cstruct.model = model.to_unsafe
      @cstruct.row_background_color_model_column = row_background_color_model_column
    end

    def model
      TableModel.new(@cstruct.model)
    end

    def model=(value : TableModel)
      @cstruct.model = value.to_unsafe
    end

    def row_background_color_model_column
      @cstruct.row_background_color_model_column
    end

    def row_background_color_model_column=(value : LibC::Int)
      @cstruct.row_background_color_model_column = value
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
