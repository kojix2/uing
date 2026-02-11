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

      def self.open(string : String, &block : AttributedString -> Nil) : Nil
        attr_str = new(string)
        begin
          block.call(attr_str)
        ensure
          attr_str.free
        end
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

      # Applies an attribute to a range of text.
      #
      # IMPORTANT: Ownership transfer
      # - libui takes ownership of the attribute after this call.
      # - The attribute MUST NOT be reused or freed manually.
      # - Each call requires a NEW Attribute instance.
      #
      # Example:
      #   attr_str.set_attribute(Attribute.new_color(1.0, 0.0, 0.0, 1.0), 0, 5)
      def set_attribute(attribute : Attribute, start : LibC::SizeT, end_ : LibC::SizeT) : Nil
        LibUI.attributed_string_set_attribute(@ref_ptr, attribute, start, end_)
        # AttributedString takes ownership of the attribute
        attribute.released = true
      end

      # Return value: 0 = Continue, 1 = Stop (follows LibUI's uiForEach convention)
      def for_each_attribute(&block : (Attribute, LibC::SizeT, LibC::SizeT) -> LibC::Int) : Nil
        @for_each_attribute_box = ::Box.box(block)

        LibUI.attributed_string_for_each_attribute(@ref_ptr,
          ->(sender, attr, start, end_, data) do
            callback = ::Box(typeof(block)).unbox(data)
            # Wrap as borrowed - libui owns this attribute, we must not free it
            attribute = Area::Attribute.borrowed(attr)
            # Return block's result directly to LibUI (0 or 1)
            callback.call(attribute, start, end_)
          end,
          @for_each_attribute_box.not_nil!
        )

        # Clear reference after enumeration
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
