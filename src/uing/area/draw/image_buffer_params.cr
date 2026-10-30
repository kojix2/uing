module UIng
  class Area < Control
    module Draw
      # Wraps uiDrawImageBufferParams. Source geometry is in integer pixels;
      # destination geometry is in user coordinates. The native Size is managed
      # automatically. Reuse this object when drawing the same region repeatedly.
      class ImageBufferParams
        include BlockConstructor; block_constructor

        @cstruct = LibUI::DrawImageBufferParams.new

        def initialize(*, source_x : Int32, source_y : Int32,
                       source_width : Int32, source_height : Int32,
                       x : Number, y : Number, width : Number, height : Number,
                       interpolation : ImageBuffer::Interpolation = ImageBuffer::Interpolation::Smooth)
          self.source_x = source_x
          self.source_y = source_y
          self.source_width = source_width
          self.source_height = source_height
          self.x = x
          self.y = y
          self.width = width
          self.height = height
          self.interpolation = interpolation
          validate_destination
        end

        {% for field in [:source_x, :source_y] %}
          def {{ field.id }} : Int32
            @cstruct.{{ field.id }}
          end

          def {{ field.id }}=(value : Int32)
            raise ArgumentError.new("image buffer {{ field.id }} must be nonnegative") unless value >= 0
            @cstruct.{{ field.id }} = value
          end
        {% end %}

        {% for field in [:source_width, :source_height] %}
          def {{ field.id }} : Int32
            @cstruct.{{ field.id }}
          end

          def {{ field.id }}=(value : Int32)
            raise ArgumentError.new("image buffer {{ field.id }} must be positive") unless value > 0
            @cstruct.{{ field.id }} = value
          end
        {% end %}

        {% for field in [:x, :y] %}
          def {{ field.id }} : Float64
            @cstruct.{{ field.id }}
          end

          def {{ field.id }}=(value : Number)
            @cstruct.{{ field.id }} = NumericValue.finite(value, "image buffer draw {{ field.id }}")
          end
        {% end %}

        {% for field in [:width, :height] %}
          def {{ field.id }} : Float64
            @cstruct.{{ field.id }}
          end

          def {{ field.id }}=(value : Number)
            @cstruct.{{ field.id }} = NumericValue.positive(value, "image buffer draw {{ field.id }}")
          end
        {% end %}

        def interpolation : ImageBuffer::Interpolation
          @cstruct.interpolation
        end

        def interpolation=(value : ImageBuffer::Interpolation)
          unless value == ImageBuffer::Interpolation::Smooth || value == ImageBuffer::Interpolation::Nearest
            raise ArgumentError.new("unsupported image buffer interpolation")
          end
          @cstruct.interpolation = value
        end

        def to_unsafe : Pointer(LibUI::DrawImageBufferParams)
          validate_destination
          @cstruct.size = LibC::SizeT.new(sizeof(LibUI::DrawImageBufferParams))
          pointerof(@cstruct)
        end

        private def validate_destination : Nil
          right = x + width
          bottom = y + height
          unless right.finite? && bottom.finite? && right > x && bottom > y
            raise ArgumentError.new("image buffer destination edges must be finite and represent a positive extent")
          end
        end
      end
    end
  end
end
