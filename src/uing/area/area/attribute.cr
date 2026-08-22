module UIng
  class Area < Control
    # Attribute represents text styling properties for AttributedString.
    #
    # IMPORTANT: Ownership rules
    # - When passed to `AttributedString#set_attribute`, ownership transfers to libui.
    # - After ownership transfer, the Attribute MUST NOT be reused or freed manually.
    # - Each `set_attribute` call requires a NEW Attribute instance.
    class Attribute
      include BlockConstructor; block_constructor

      property? released : Bool = false
      @borrowed : Bool = false

      def initialize(@ref_ptr : Pointer(LibUI::Attribute), @borrowed : Bool = false)
      end

      # Internal: Create a borrowed Attribute wrapper for libui-owned pointers.
      # Used by for_each_attribute where libui retains ownership.
      protected def self.borrowed(ref_ptr : Pointer(LibUI::Attribute)) : Attribute
        Attribute.new(ref_ptr, borrowed: true)
      end

      def self.new_family(family : String) : Attribute
        ref_ptr = LibUI.new_family_attribute(family)
        Attribute.new(ref_ptr)
      end

      def self.new_size(size : Float64) : Attribute
        ref_ptr = LibUI.new_size_attribute(size)
        Attribute.new(ref_ptr)
      end

      def self.new_weight(weight : TextWeight) : Attribute
        ref_ptr = LibUI.new_weight_attribute(weight)
        Attribute.new(ref_ptr)
      end

      def self.new_italic(italic : TextItalic) : Attribute
        ref_ptr = LibUI.new_italic_attribute(italic)
        Attribute.new(ref_ptr)
      end

      def self.new_stretch(stretch : TextStretch) : Attribute
        ref_ptr = LibUI.new_stretch_attribute(stretch)
        Attribute.new(ref_ptr)
      end

      def self.new_color(r : Float64, g : Float64, b : Float64, a : Float64) : Attribute
        ref_ptr = LibUI.new_color_attribute(r, g, b, a)
        Attribute.new(ref_ptr)
      end

      def self.new_background(r : Float64, g : Float64, b : Float64, a : Float64) : Attribute
        ref_ptr = LibUI.new_background_attribute(r, g, b, a)
        Attribute.new(ref_ptr)
      end

      def self.new_underline(underline : Underline) : Attribute
        ref_ptr = LibUI.new_underline_attribute(underline)
        Attribute.new(ref_ptr)
      end

      def self.new_underline_color(underline_color : UnderlineColor, r : Float64, g : Float64, b : Float64, a : Float64) : Attribute
        ref_ptr = LibUI.new_underline_color_attribute(underline_color, r, g, b, a)
        Attribute.new(ref_ptr)
      end

      def self.new_features(open_type_features : OpenTypeFeatures) : Attribute
        ref_ptr = LibUI.new_features_attribute(open_type_features.to_unsafe)
        Attribute.new(ref_ptr)
      end

      def free : Nil
        return if @released
        LibUI.free_attribute(@ref_ptr) unless @borrowed
        @released = true
      end

      def type : Type
        check_available
        LibUI.attribute_get_type(@ref_ptr)
      end

      def family : String?
        check_available
        str_ptr = LibUI.attribute_family(@ref_ptr)
        # The returned string is owned by the attribute
        # and should not be freed (probably)
        str_ptr.null? ? nil : String.new(str_ptr)
      end

      def size : Float64
        check_available
        LibUI.attribute_size(@ref_ptr)
      end

      def weight : TextWeight
        check_available
        LibUI.attribute_weight(@ref_ptr)
      end

      def italic : TextItalic
        check_available
        LibUI.attribute_italic(@ref_ptr)
      end

      def stretch : TextStretch
        check_available
        LibUI.attribute_stretch(@ref_ptr)
      end

      def color : {Float64, Float64, Float64, Float64}
        check_available
        LibUI.attribute_color(@ref_ptr, out r, out g, out b, out a)
        {r, g, b, a}
      end

      def underline : Underline
        check_available
        LibUI.attribute_underline(@ref_ptr)
      end

      def underline_color : {UnderlineColor, Float64, Float64, Float64, Float64}
        check_available
        underline_color = UnderlineColor::Custom
        LibUI.attribute_underline_color(@ref_ptr, pointerof(underline_color), out r, out g, out b, out a)
        {underline_color, r, g, b, a}
      end

      def features : OpenTypeFeatures
        check_available
        ref_ptr = LibUI.attribute_features(@ref_ptr)
        OpenTypeFeatures.new(ref_ptr, borrowed: true)
      end

      def to_unsafe
        check_available
        @ref_ptr
      end

      def finalize
        free
      end

      private def check_available : Nil
        raise "Attribute has already been released" if @released
      end
    end
  end
end
