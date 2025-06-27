require "./attribute/*"

module UIng
  class Area < Control
    class AttributedString
      include BlockConstructor; block_constructor

      @released : Bool = false
      @for_each_attribute_box : Pointer(Void)?

      def initialize(@ref_ptr : Pointer(LibUI::AttributedString))
      end

      def initialize(string : String)
        @ref_ptr = LibUI.new_attributed_string(string)
      end

      def free : Nil
        return if @released
        LibUI.free_attributed_string(@ref_ptr)
        @released = true
      end

      def string : String?
        str_ptr = LibUI.attributed_string_string(@ref_ptr)
        # The returned string is owned by the attributed string?
        str_ptr.null? ? nil : String.new(str_ptr)
      end

      def len : LibC::SizeT
        LibUI.attributed_string_len(@ref_ptr)
      end

      def append_unattributed(text : String) : Nil
        LibUI.attributed_string_append_unattributed(@ref_ptr, text)
      end

      def insert_at_unattributed(text : String, at : LibC::SizeT) : Nil
        LibUI.attributed_string_insert_at_unattributed(@ref_ptr, text, at)
      end

      def delete(start : LibC::SizeT, end_ : LibC::SizeT) : Nil
        LibUI.attributed_string_delete(@ref_ptr, start, end_)
      end

      def set_attribute(attribute, start : LibC::SizeT, end_ : LibC::SizeT) : Nil
        LibUI.attributed_string_set_attribute(@ref_ptr, attribute, start, end_)
        # AttributedString takes ownership of the attribute
        if attribute.responds_to?(:released=)
          attribute.released = true
        end
      end

      def for_each_attribute(&callback : (Pointer(LibUI::Attribute), LibC::SizeT, LibC::SizeT) -> Void) : Nil
        @for_each_attribute_box = ::Box.box(callback)
        LibUI.attributed_string_for_each_attribute(@ref_ptr, ->(sender, attr, start, end_, data) do
          data_as_callback = ::Box(typeof(callback)).unbox(data)
          data_as_callback.call(attr, start, end_)
          # Note: Cannot safely delete box here as LibUI may call multiple times
          0 # uiForEachContinue
        end, @for_each_attribute_box.not_nil!)

        # Clear the box reference after enumeration completes
        @for_each_attribute_box = nil
      end

      def num_graphemes : LibC::SizeT
        LibUI.attributed_string_num_graphemes(@ref_ptr)
      end

      def byte_index_to_grapheme(pos : LibC::SizeT) : LibC::SizeT
        LibUI.attributed_string_byte_index_to_grapheme(@ref_ptr, pos)
      end

      def grapheme_to_byte_index(pos : LibC::SizeT) : LibC::SizeT
        LibUI.attributed_string_grapheme_to_byte_index(@ref_ptr, pos)
      end

      def to_unsafe
        @ref_ptr
      end

      def finalize
        free
      end
    end
  end
end
