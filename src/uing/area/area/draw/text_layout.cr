require "./text_layout/*"

module UIng
  class Area < Control
    module Draw
      class TextLayout
        include BlockConstructor; block_constructor

        @released = false
        # NOTE: Strong references to AttributedString/FontDescriptor are NOT needed.
        # libui-ng uses "copy on creation" pattern - TextLayout internally copies
        # all content from source objects, making it safe to free them immediately.

        def initialize(string : AttributedString,
                       default_font : FontDescriptor,
                       width : Float64,
                       align : UIng::Area::Draw::TextAlign = UIng::Area::Draw::TextAlign::Left)
          draw_text_layout_params = Draw::TextLayout::Params.new(
            string: string,
            default_font: default_font,
            width: width,
            align: align
          )
          @ref_ptr = LibUI.draw_new_text_layout(draw_text_layout_params)
        end

        def self.open(string : AttributedString,
                      default_font : FontDescriptor,
                      width : Float64,
                      align : UIng::Area::Draw::TextAlign = UIng::Area::Draw::TextAlign::Left,
                      &block : TextLayout -> Nil) : Nil
          text_layout = TextLayout.new(string, default_font, width, align)
          begin
            block.call(text_layout)
          ensure
            text_layout.free
          end
        end

        def free : Nil
          return if @released
          LibUI.draw_free_text_layout(@ref_ptr)
          @released = true
        end

        def extents : {LibC::Double, LibC::Double}
          LibUI.draw_text_layout_extents(@ref_ptr, out width, out height)
          {width, height}
        end

        def to_unsafe
          @ref_ptr
        end
      end
    end
  end
end
