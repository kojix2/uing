module UIng
  # FIXME: The API for this class should be modified.
  class TableValue
    property? released : Bool = false

    def initialize(@ref_ptr : Pointer(LibUI::TableValue))
    end

    # Overloaded initializers for convenient creation
    def initialize(str : String)
      @ref_ptr = LibUI.new_table_value_string(str)
    end

    def initialize(image : Image)
      @ref_ptr = LibUI.new_table_value_image(image.to_unsafe)
    end

    def initialize(i : Int32)
      @ref_ptr = LibUI.new_table_value_int(i)
    end

    def initialize(r : Float64, g : Float64, b : Float64, a : Float64)
      @ref_ptr = LibUI.new_table_value_color(r, g, b, a)
    end

    # def initialize
    #   @ref_ptr = LibUI.new_table_value
    # end

    def self.new_color(r : Float64, g : Float64, b : Float64, a : Float64) : TableValue
      TableValue.new(r, g, b, a)
    end

    def free : Nil
      return if @released
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

    def finalize
      free
    end
  end
end
