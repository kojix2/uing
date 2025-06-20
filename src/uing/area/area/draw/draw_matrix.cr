module UIng
  class Area < Control
    class DrawMatrix
      def initialize(@cstruct : LibUI::DrawMatrix = LibUI::DrawMatrix.new)
      end

      def set_identity : Nil
        LibUI.draw_matrix_set_identity(self.to_unsafe)
      end

      def translate(x : Float64, y : Float64) : Nil
        LibUI.draw_matrix_translate(self.to_unsafe, x, y)
      end

      def scale(x_center : Float64, y_center : Float64, x : Float64, y : Float64) : Nil
        LibUI.draw_matrix_scale(self.to_unsafe, x_center, y_center, x, y)
      end

      def rotate(x : Float64, y : Float64, amount : Float64) : Nil
        LibUI.draw_matrix_rotate(self.to_unsafe, x, y, amount)
      end

      def skew(x : Float64, y : Float64, x_amount : Float64, y_amount : Float64) : Nil
        LibUI.draw_matrix_skew(self.to_unsafe, x, y, x_amount, y_amount)
      end

      def multiply(src : DrawMatrix) : Nil
        LibUI.draw_matrix_multiply(self.to_unsafe, src.to_unsafe)
      end

      def invertible? : Bool
        LibUI.draw_matrix_invertible(self.to_unsafe)
      end

      def invert : Bool
        LibUI.draw_matrix_invert(self.to_unsafe)
      end

      def transform_point(x : Float64, y : Float64) : {Float64, Float64}
        LibUI.draw_matrix_transform_point(self.to_unsafe, out x, out y)
        {x, y}
      end

      def transform_size(x : Float64, y : Float64) : {Float64, Float64}
        LibUI.draw_matrix_transform_size(self.to_unsafe, out x, out y)
        {x, y}
      end

      def to_unsafe
        pointerof(@cstruct)
      end
    end
  end
end
