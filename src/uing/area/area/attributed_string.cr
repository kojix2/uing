require "./attribute/*"

module UIng
  class Area < Control
    class AttributedString
      include BlockConstructor; block_constructor

      @released : Bool = false
      @enumeration_depth : Int32 = 0
      @each_attribute_boxes = [] of Pointer(Void)

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
        check_not_enumerating("free")
        LibUI.free_attributed_string(@ref_ptr)
        @released = true
      end

      def string : String?
        check_available
        str_ptr = native_string
        # The returned string is owned by the attributed string?
        str_ptr.null? ? nil : String.new(str_ptr)
      end

      def len : LibC::SizeT
        check_available
        native_len
      end

      def append_unattributed(text : String) : Nil
        check_available
        check_not_enumerating("append text")
        LibUI.attributed_string_append_unattributed(@ref_ptr, text)
      end

      def insert_at_unattributed(text : String, at : LibC::SizeT) : Nil
        check_available
        check_not_enumerating("insert text")
        validate_byte_position(at, "insertion position")
        LibUI.attributed_string_insert_at_unattributed(@ref_ptr, text, at)
      end

      def delete(start : LibC::SizeT, end_ : LibC::SizeT) : Nil
        check_available
        check_not_enumerating("delete text")
        validate_byte_range(start, end_, "deletion range")
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
        check_available
        check_not_enumerating("set an attribute")
        validate_byte_range(start, end_, "attribute range")
        attribute.check_transferable
        LibUI.attributed_string_set_attribute(@ref_ptr, attribute, start, end_)
        # AttributedString takes ownership of the attribute
        attribute.transfer_to_attributed_string
      end

      # Each yielded Attribute is borrowed and only valid until the block returns.
      def each_attribute(&block : (Attribute, LibC::SizeT, LibC::SizeT) -> _) : Nil
        each_attribute_while do |attribute, start, end_|
          block.call(attribute, start, end_)
          true
        end
      end

      # Enumerates attributes while the block returns true. Returning false
      # stops enumeration after the current attribute.
      def each_attribute_while(&block : (Attribute, LibC::SizeT, LibC::SizeT) -> Bool) : Nil
        check_available
        each_attribute_box = ::Box.box(block)
        @each_attribute_boxes << each_attribute_box
        @enumeration_depth += 1

        begin
          LibUI.attributed_string_for_each_attribute(@ref_ptr,
            ->(_sender, attr, start, end_, data) do
              begin
                callback = ::Box(typeof(block)).unbox(data)
                # Wrap as borrowed - libui owns this attribute, we must not free it
                attribute = Area::Attribute.borrowed(attr)
                begin
                  callback.call(attribute, start, end_) ? 0_i32 : 1_i32
                ensure
                  attribute.invalidate_borrow
                end
              rescue e
                UIng.handle_callback_error(e, "AttributedString each_attribute")
                1_i32 # uiForEachStop
              end
            end,
            each_attribute_box
          )
        ensure
          @enumeration_depth -= 1
          @each_attribute_boxes.pop
        end
      end

      def num_graphemes : LibC::SizeT
        check_available
        LibUI.attributed_string_num_graphemes(@ref_ptr)
      end

      def byte_index_to_grapheme(pos : LibC::SizeT) : LibC::SizeT
        check_available
        validate_byte_position(pos, "byte index")
        LibUI.attributed_string_byte_index_to_grapheme(@ref_ptr, pos)
      end

      def grapheme_to_byte_index(pos : LibC::SizeT) : LibC::SizeT
        check_available
        if pos > num_graphemes
          raise ArgumentError.new("grapheme index is out of bounds for AttributedString")
        end
        LibUI.attributed_string_grapheme_to_byte_index(@ref_ptr, pos)
      end

      def to_unsafe
        check_available
        @ref_ptr
      end

      def finalize
        free
      end

      private def check_available : Nil
        raise "AttributedString has already been released" if @released
      end

      private def check_not_enumerating(operation : String) : Nil
        return if @enumeration_depth == 0
        raise "Cannot #{operation} while AttributedString is being enumerated"
      end

      private def validate_byte_range(start : LibC::SizeT, end_ : LibC::SizeT, description : String) : Nil
        if start > end_
          raise ArgumentError.new("#{description} start is after its end")
        end

        string_len = native_len
        if end_ > string_len
          raise ArgumentError.new("#{description} is out of bounds for AttributedString")
        end
        validate_codepoint_boundary(start, string_len, "#{description} start")
        validate_codepoint_boundary(end_, string_len, "#{description} end")
      end

      private def validate_byte_position(position : LibC::SizeT, description : String) : Nil
        string_len = native_len
        if position > string_len
          raise ArgumentError.new("#{description} is out of bounds for AttributedString")
        end
        validate_codepoint_boundary(position, string_len, description)
      end

      private def validate_codepoint_boundary(position : LibC::SizeT, string_len : LibC::SizeT, description : String) : Nil
        return if position == string_len

        byte = native_string.as(UInt8*)[position]
        return unless byte & 0xC0 == 0x80
        raise ArgumentError.new("#{description} is not on a UTF-8 codepoint boundary for AttributedString")
      end

      protected def native_len : LibC::SizeT
        LibUI.attributed_string_len(@ref_ptr)
      end

      protected def native_string : Pointer(LibC::Char)
        LibUI.attributed_string_string(@ref_ptr)
      end
    end
  end
end
