module UIng
  class Area < Control
    module Draw
      class TextLayout
        class Params
          include BlockConstructor; block_constructor

          # Store references to prevent garbage collection
          @attributed_string : AttributedString
          @font_descriptor : FontDescriptor

          def initialize(string : AttributedString, default_font : FontDescriptor, width : Float64, align : UIng::Area::Draw::TextAlign)
            @cstruct = LibUI::DrawTextLayoutParams.new
            @attributed_string = string
            @font_descriptor = default_font
            @cstruct.string = string.to_unsafe
            @cstruct.default_font = default_font.to_unsafe
            @cstruct.width = width
            @cstruct.align = align
          end

          # Explicit property accessors for better type safety and documentation
          def string : AttributedString
            @attributed_string
          end

          def string=(value : AttributedString)
            @attributed_string = value
            @cstruct.string = value.to_unsafe
          end

          def default_font : FontDescriptor
            @font_descriptor
          end

          def default_font=(value : FontDescriptor)
            @font_descriptor = value
            @cstruct.default_font = value.to_unsafe
          end

          def width : Float64
            @cstruct.width
          end

          def width=(value : Float64)
            @cstruct.width = value
          end

          def align : UIng::Area::Draw::TextAlign
            @cstruct.align
          end

          def align=(value : UIng::Area::Draw::TextAlign)
            @cstruct.align = value
          end

          def to_unsafe
            pointerof(@cstruct)
          end
        end
      end
    end
  end
end
