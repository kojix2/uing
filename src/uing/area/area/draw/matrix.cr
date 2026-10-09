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
          LibUI.draw_matrix_translate(to_unsafe, x.to_f64, y.to_f64)
          self
        end

        def scale(x_center : Number, y_center : Number, x : Number, y : Number) : self
          LibUI.draw_matrix_scale(to_unsafe, x_center.to_f64, y_center.to_f64, x.to_f64, y.to_f64)
          self
        end

        def rotate(x : Number, y : Number, amount : Number) : self
          LibUI.draw_matrix_rotate(to_unsafe, x.to_f64, y.to_f64, amount.to_f64)
          self
        end

        def skew(x : Number, y : Number, x_amount : Number, y_amount : Number) : self
          LibUI.draw_matrix_skew(to_unsafe, x.to_f64, y.to_f64, x_amount.to_f64, y_amount.to_f64)
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
          x2 = x.to_f64
          y2 = y.to_f64
          LibUI.draw_matrix_transform_point(to_unsafe, pointerof(x2), pointerof(y2))
          {x2, y2}
        end

        def transform_size(x : Number, y : Number) : {Float64, Float64}
          x2 = x.to_f64
          y2 = y.to_f64
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
