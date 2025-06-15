module UIng
  # TableValue represents data values in Table cells.
  #
  # UNIFIED MEMORY MANAGEMENT:
  # TableValue uses a borrowed flag to automatically handle memory management.
  #
  # CRITICAL WARNINGS:
  # 1. TableValue from TableModelHandler callbacks is "borrowed" - automatically protected from free
  # 2. TableValue created by Crystal code MUST be freed after use
  # 3. DO NOT store TableValue references long-term
  # 4. libui-ng takes ownership when TableValue is passed to Table methods
  # 5. Image data returned from TableValue.image is borrowed - DO NOT free
  # 6. String data returned from TableValue.string is borrowed - DO NOT free
  #
  # Safe usage patterns:
  #   # In TableModelHandler callback (borrowed - automatically protected):
  #   def cell_value(...)
  #     value = LibUI.new_table_value_string("data")
  #     return value  # libui-ng will free this
  #   end
  #
  #   # Creating for immediate use (must free):
  #   value = TableValue.new("data")
  #   data = value.string  # Extract data immediately
  #   value.free           # Free immediately after use
  #
  #   # Reading from borrowed TableValue (automatically protected):
  #   def set_cell_value(row, column, value_ptr)
  #     table_value = TableValue.new(value_ptr, borrowed: true)  # Marked as borrowed
  #     data = table_value.string                               # Extract data
  #     table_value.free  # Safe to call - will be ignored for borrowed values
  #   end
  class TableValue
    property? released : Bool = false
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

    # def initialize
    #   @ref_ptr = LibUI.new_table_value
    # end

    def self.new_color(r : Float64, g : Float64, b : Float64, a : Float64) : TableValue
      TableValue.new(r, g, b, a)
    end

    def free : Nil
      return if @released
      return if @borrowed # Don't free borrowed TableValue
      LibUI.free_table_value(@ref_ptr)
      @released = true
    end

    def get_type : TableValueType
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
      when TableValueType::String
        string
      when TableValueType::Image
        image
      when TableValueType::Int
        int
      when TableValueType::Color
        color
      else
        raise "Unknown TableValue type: #{get_type}"
      end
    end

    def to_unsafe
      @ref_ptr
    end

    # Note: No finalize method needed for TableValue
    # - TableValue objects returned from table model callbacks are immediately freed by libui-ng
    # - Language bindings should treat these as "borrowed" references that don't need cleanup
    # - libui-ng uses strict ownership model where it manages TableValue memory internally
    # - Adding finalize would cause double-free errors since libui-ng already frees the memory
  end
end
