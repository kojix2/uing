module UIng
  # FIXME: The API for this class should be modified.
  class TableValue
    property? released : Bool = false
    property? managed_by_libui : Bool = false

    def initialize(@ref_ptr : Pointer(LibUI::TableValue))
      @managed_by_libui = true # TableValue managed by LibUI
    end

    # Overloaded initializers for convenient creation
    def initialize(str : String)
      @ref_ptr = LibUI.new_table_value_string(str)
      @managed_by_libui = false # TableValue created by ourselves
    end

    def initialize(image : Image)
      @ref_ptr = LibUI.new_table_value_image(image.to_unsafe)
      @managed_by_libui = false
    end

    def initialize(i : Int32)
      @ref_ptr = LibUI.new_table_value_int(i)
      @managed_by_libui = false
    end

    def initialize(r : Float64, g : Float64, b : Float64, a : Float64)
      @ref_ptr = LibUI.new_table_value_color(r, g, b, a)
      @managed_by_libui = false
    end

    # def initialize
    #   @ref_ptr = LibUI.new_table_value
    # end

    def self.new_color(r : Float64, g : Float64, b : Float64, a : Float64) : TableValue
      TableValue.new(r, g, b, a)
    end

    def free : Nil
      return if @released
      return if @managed_by_libui # Don't free TableValue managed by LibUI
      LibUI.free_table_value(@ref_ptr)
      @released = true
    end

    def get_type : TableValueType
      LibUI.table_value_get_type(@ref_ptr)
    end

    def string : String?
      str_ptr = LibUI.table_value_string(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def image : Image
      ref_ptr = LibUI.table_value_image(@ref_ptr)
      Image.new(ref_ptr)
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
