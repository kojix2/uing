module UIng
  class Area < Control
    module Draw
      class Brush
        enum Type
          Solid
          LinearGradient
          RadialGradient
          Image
        end
      end
    end
  end
end
