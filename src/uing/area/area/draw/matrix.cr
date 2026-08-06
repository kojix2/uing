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

        def translate(x : Float64, y : Float64) : self
          LibUI.draw_matrix_translate(to_unsafe, x, y)
          self
        end

        def scale(x_center : Float64, y_center : Float64, x : Float64, y : Float64) : self
          LibUI.draw_matrix_scale(to_unsafe, x_center, y_center, x, y)
          self
        end

        def rotate(x : Float64, y : Float64, amount : Float64) : self
          LibUI.draw_matrix_rotate(to_unsafe, x, y, amount)
          self
        end

        def skew(x : Float64, y : Float64, x_amount : Float64, y_amount : Float64) : self
          LibUI.draw_matrix_skew(to_unsafe, x, y, x_amount, y_amount)
          self
        end

        def multiply(src : Matrix) : self
          LibUI.draw_matrix_multiply(to_unsafe, src.to_unsafe)
          self
        end

        def invertible? : Bool
          LibUI.draw_matrix_invertible(to_unsafe)
        end

        def invert : Bool
          LibUI.draw_matrix_invert(to_unsafe)
        end

        def transform_point(x : Float64, y : Float64) : {Float64, Float64}
          x2 = x
          y2 = y
          LibUI.draw_matrix_transform_point(to_unsafe, pointerof(x2), pointerof(y2))
          {x2, y2}
        end

        def transform_size(x : Float64, y : Float64) : {Float64, Float64}
          x2 = x
          y2 = y
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
