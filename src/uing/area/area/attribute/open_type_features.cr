module UIng
  class OpenTypeFeatures
    @released : Bool = false
    @for_each_box : Pointer(Void)?

    def initialize
      @ref_ptr = LibUI.new_open_type_features
    end

    # Used in clone method
    def initialize(ref_ptr : Pointer(LibUI::OpenTypeFeatures))
      @ref_ptr = ref_ptr
    end

    def free : Nil
      return if @released
      LibUI.free_open_type_features(@ref_ptr)
      @released = true
    end

    def clone : OpenTypeFeatures
      ref_ptr = LibUI.open_type_features_clone(@ref_ptr)
      OpenTypeFeatures.new(ref_ptr)
    end

    def add(tag : String, value : Int32 = 1) : Nil
      raise ArgumentError.new("OpenType tag must be exactly 4 characters") unless tag.size == 4
      bytes = tag.bytes
      LibUI.open_type_features_add(@ref_ptr, bytes[0], bytes[1], bytes[2], bytes[3], value.to_u32)
    end

    def remove(tag : String) : Nil
      raise ArgumentError.new("OpenType tag must be exactly 4 characters") unless tag.size == 4
      bytes = tag.bytes
      LibUI.open_type_features_remove(@ref_ptr, bytes[0], bytes[1], bytes[2], bytes[3])
    end

    def get(tag : String) : {Bool, Int32}
      raise ArgumentError.new("OpenType tag must be exactly 4 characters") unless tag.size == 4
      bytes = tag.bytes
      result = LibUI.open_type_features_get(@ref_ptr, bytes[0], bytes[1], bytes[2], bytes[3], out value)
      {result, value.to_i32}
    end

    # FIXME : Is this appropriate for OpenTypeFeatures?

    def for_each(&callback : (String, Int32) -> _) : Nil
      @for_each_box = ::Box.box(callback)
      proc = ->(_otf : Pointer(LibUI::OpenTypeFeatures), a : LibC::Char, b : LibC::Char, c : LibC::Char, d : LibC::Char, value : UInt32, data : Pointer(Void)) : LibC::Int do
        data_as_callback = ::Box(typeof(callback)).unbox(data)
        tag = "#{a.chr}#{b.chr}#{c.chr}#{d.chr}"
        data_as_callback.call(tag, value.to_i32)
        0 # uiForEachContinue
      end
      LibUI.open_type_features_for_each(@ref_ptr, proc, @for_each_box.not_nil!)

      # Clear the box reference after enumeration completes
      @for_each_box = nil
    end

    def to_unsafe
      @ref_ptr
    end

    def finalize
      # Releasing timing is not critical for this class
      free
    end
  end
end
