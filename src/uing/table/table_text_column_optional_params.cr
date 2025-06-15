module UIng
  class TableTextColumnOptionalParams
    def initialize(color_model_column : LibC::Int)
      @cstruct = LibUI::TableTextColumnOptionalParams.new
      @cstruct.color_model_column = color_model_column
    end

    def color_model_column
      @cstruct.color_model_column
    end

    def color_model_column=(value : LibC::Int)
      @cstruct.color_model_column = value
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
