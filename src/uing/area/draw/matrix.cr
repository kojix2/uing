module UIng
  class Area < Control
    module Draw
      class Matrix
        include BlockConstructor; block_constructor

        def initialize
          @cstruct = LibUI::DrawMatrix.new
        end

        def set_identity : self
          LibUI.draw_matrix_set_identity(to_unsafe)
          self
        end

        def translate(x : Number, y : Number) : self
          translated_x = NumericValue.finite(x, "matrix translation x")
          translated_y = NumericValue.finite(y, "matrix translation y")
          LibUI.draw_matrix_translate(to_unsafe, translated_x, translated_y)
          self
        end

        def scale(x_center : Number, y_center : Number, x : Number, y : Number) : self
          center_x = NumericValue.finite(x_center, "matrix scale center x")
          center_y = NumericValue.finite(y_center, "matrix scale center y")
          scale_x = NumericValue.finite(x, "matrix scale x")
          scale_y = NumericValue.finite(y, "matrix scale y")
          LibUI.draw_matrix_scale(to_unsafe, center_x, center_y, scale_x, scale_y)
          self
        end

        def rotate(x : Number, y : Number, amount : Number) : self
          center_x = NumericValue.finite(x, "matrix rotation center x")
          center_y = NumericValue.finite(y, "matrix rotation center y")
          angle = NumericValue.finite(amount, "matrix rotation amount")
          LibUI.draw_matrix_rotate(to_unsafe, center_x, center_y, angle)
          self
        end

        def skew(x : Number, y : Number, x_amount : Number, y_amount : Number) : self
          origin_x = NumericValue.finite(x, "matrix skew origin x")
          origin_y = NumericValue.finite(y, "matrix skew origin y")
          skew_x = NumericValue.finite(x_amount, "matrix skew x amount")
          skew_y = NumericValue.finite(y_amount, "matrix skew y amount")
          LibUI.draw_matrix_skew(to_unsafe, origin_x, origin_y, skew_x, skew_y)
          self
        end

        def multiply(src : Matrix) : self
          LibUI.draw_matrix_multiply(to_unsafe, src.to_unsafe)
          self
        end

        def invertible? : Bool
          LibUI.draw_matrix_invertible(to_unsafe) != 0
        end

        def invert : Bool
          LibUI.draw_matrix_invert(to_unsafe) != 0
        end

        def transform_point(x : Number, y : Number) : {Float64, Float64}
          x2 = NumericValue.finite(x, "matrix point x")
          y2 = NumericValue.finite(y, "matrix point y")
          LibUI.draw_matrix_transform_point(to_unsafe, pointerof(x2), pointerof(y2))
          {x2, y2}
        end

        def transform_size(x : Number, y : Number) : {Float64, Float64}
          x2 = NumericValue.finite(x, "matrix size x")
          y2 = NumericValue.finite(y, "matrix size y")
          LibUI.draw_matrix_transform_size(to_unsafe, pointerof(x2), pointerof(y2))
          {x2, y2}
        end

        def to_unsafe
          pointerof(@cstruct)
        end
      end
    end
  end
end
