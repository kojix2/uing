require "./value/type"

module UIng
  class Table < Control
    class Value
      @released : Bool = false
      property? borrowed : Bool = false

      # Unified constructor - handles both borrowed and owned TableValue
      def initialize(@ref_ptr : Pointer(LibUI::TableValue), borrowed : Bool = true)
        @borrowed = borrowed
      end

      # Public constructors for creating new TableValue objects
      # These MUST be freed after use
      def initialize(str : String)
        @ref_ptr = LibUI.new_table_value_string(str)
        @borrowed = false
      end

      def initialize(image : Image)
        @ref_ptr = LibUI.new_table_value_image(image.to_unsafe)
        @borrowed = false
      end

      def initialize(i : Int32)
        @ref_ptr = LibUI.new_table_value_int(i)
        @borrowed = false
      end

      def initialize(r : Float64, g : Float64, b : Float64, a : Float64)
        @ref_ptr = LibUI.new_table_value_color(r, g, b, a)
        @borrowed = false
      end

      def self.new_color(r : Float64, g : Float64, b : Float64, a : Float64) : TableValue
        TableValue.new(r, g, b, a)
      end

      def free : Nil
        return if @released
        return if @borrowed # Don't free borrowed TableValue
        LibUI.free_table_value(@ref_ptr)
        @released = true
      end

      def type : Value::Type
        LibUI.table_value_get_type(@ref_ptr)
      end

      def string : String?
        str_ptr = LibUI.table_value_string(@ref_ptr)
        return nil if str_ptr.null?
        # DO NOT free the string pointer - it's borrowed from libui-ng
        String.new(str_ptr)
      end

      def image : Pointer(LibUI::Image)
        # Return the raw pointer - DO NOT create new Image object
        # The returned pointer is borrowed from libui-ng and should not be freed
        LibUI.table_value_image(@ref_ptr)
      end

      def int : Int32
        LibUI.table_value_int(@ref_ptr)
      end

      def color : {Float64, Float64, Float64, Float64}
        LibUI.table_value_color(@ref_ptr, out r, out g, out b, out a)
        {r, g, b, a}
      end

      def value
        case get_type
        when .string? then string
        when .image?  then image
        when .int?    then int
        when .color?  then color
        else
          raise "Unknown TableValue type: #{get_type}"
        end
      end

      def to_unsafe
        @ref_ptr
      end
    end
  end
end
