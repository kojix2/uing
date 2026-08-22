module UIng
  class Table < Control
    class Params
      include BlockConstructor; block_constructor

      def initialize(@model : Model, row_background_color_model_column : LibC::Int = -1)
        @cstruct = LibUI::TableParams.new
        @cstruct.model = @model.to_unsafe
        @cstruct.row_background_color_model_column = row_background_color_model_column
      end

      def model : Model
        @model
      end

      def model=(value : Model) : Model
        model_ptr = value.to_unsafe
        @cstruct.model = model_ptr
        @model = value
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
end
