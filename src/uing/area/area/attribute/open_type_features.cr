module UIng
  class OpenTypeFeatures
    @released : Bool = false
    @borrowed : Bool = false
    @enumeration_depth : Int32 = 0
    @for_each_boxes = [] of Pointer(Void)

    def initialize
      @ref_ptr = LibUI.new_open_type_features
    end

    # Used for wrappers around libui pointers. By default the wrapper owns the
    # pointer, but uiAttributeFeatures() returns a pointer owned by its attribute.
    def initialize(ref_ptr : Pointer(LibUI::OpenTypeFeatures), @borrowed : Bool = false)
      @ref_ptr = ref_ptr
    end

    def free : Nil
      return if @released
      check_not_enumerating("free")
      LibUI.free_open_type_features(@ref_ptr) unless @borrowed
      @released = true
    end

    def clone : OpenTypeFeatures
      check_available
      ref_ptr = LibUI.open_type_features_clone(@ref_ptr)
      OpenTypeFeatures.new(ref_ptr)
    end

    def add(tag : String, value : UInt32 = 1_u32) : Nil
      check_available
      check_not_enumerating("add features")
      bytes = tag_bytes(tag)
      LibUI.open_type_features_add(@ref_ptr, bytes[0], bytes[1], bytes[2], bytes[3], value)
    end

    def remove(tag : String) : Nil
      check_available
      check_not_enumerating("remove features")
      bytes = tag_bytes(tag)
      LibUI.open_type_features_remove(@ref_ptr, bytes[0], bytes[1], bytes[2], bytes[3])
    end

    def get(tag : String) : {Bool, UInt32}
      check_available
      bytes = tag_bytes(tag)
      result = LibUI.open_type_features_get(@ref_ptr, bytes[0], bytes[1], bytes[2], bytes[3], out value)
      return {false, 0_u32} if result == 0
      {true, value}
    end

    def for_each(&callback : (String, UInt32) -> _) : Nil
      check_available
      boxed_callback = ::Box.box(callback)
      @for_each_boxes << boxed_callback
      @enumeration_depth += 1

      proc = ->(_otf : Pointer(LibUI::OpenTypeFeatures), a : LibC::Char, b : LibC::Char, c : LibC::Char, d : LibC::Char, value : UInt32, data : Pointer(Void)) : LibC::Int do
        begin
          data_as_callback = ::Box(typeof(callback)).unbox(data)
          tag = "#{a.chr}#{b.chr}#{c.chr}#{d.chr}"
          data_as_callback.call(tag, value)
          0_i32 # uiForEachContinue
        rescue e
          UIng.handle_callback_error(e, "OpenTypeFeatures for_each")
          1_i32 # uiForEachStop
        end
      end

      begin
        LibUI.open_type_features_for_each(@ref_ptr, proc, boxed_callback)
      ensure
        @enumeration_depth -= 1
        @for_each_boxes.pop
      end
    end

    def to_unsafe
      check_available
      @ref_ptr
    end

    def finalize
      # Releasing timing is not critical for this class
      free
    end

    private def check_available : Nil
      raise "OpenTypeFeatures has already been released" if @released
    end

    private def check_not_enumerating(operation : String) : Nil
      return if @enumeration_depth == 0
      raise "Cannot #{operation} while OpenTypeFeatures is being enumerated"
    end

    private def tag_bytes(tag : String) : Bytes
      raise ArgumentError.new("OpenType tag must be exactly 4 bytes") unless tag.bytesize == 4

      bytes = tag.to_slice
      unless bytes.all? { |byte| 0x20 <= byte <= 0x7e }
        raise ArgumentError.new("OpenType tag must contain only printable ASCII bytes")
      end

      bytes
    end
  end
end
