module UIng
  # FIXME: The API for this class should be modified.
  class TableValue
    def initialize(@ref_ptr : Pointer(LibUI::TableValue))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_table_value
    # end

    def self.new_string(str : String) : TableValue
      ref_ptr = LibUI.new_table_value_string(str)
      TableValue.new(ref_ptr)
    end

    def self.new_image(image : Image) : TableValue
      ref_ptr = LibUI.new_table_value_image(image.to_unsafe)
      TableValue.new(ref_ptr)
    end

    def self.new_int(i : Int32) : TableValue
      ref_ptr = LibUI.new_table_value_int(i)
      TableValue.new(ref_ptr)
    end

    def self.new_color(r : Float64, g : Float64, b : Float64, a : Float64) : TableValue
      ref_ptr = LibUI.new_table_value_color(r, g, b, a)
      TableValue.new(ref_ptr)
    end

    def free : Nil
      LibUI.free_table_value(@ref_ptr)
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

    def to_unsafe
      @ref_ptr
    end
  end
end
