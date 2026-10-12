module UIng
  # A Crystal-managed set of OpenType feature tags and values.
  class OpenTypeFeatures
    private class NativeCopyState
      getter values = {} of String => UInt32
      property error : Exception? = nil
    end

    @values : Hash(String, UInt32)
    @enumeration_depth : Int32 = 0

    def initialize
      @values = {} of String => UInt32
    end

    protected def initialize(@values : Hash(String, UInt32))
    end

    protected def initialize(ref_ptr : Pointer(LibUI::OpenTypeFeatures))
      state = NativeCopyState.new
      @values = state.values
      LibUI.open_type_features_for_each(
        ref_ptr,
        ->(_otf : Pointer(LibUI::OpenTypeFeatures), a : LibC::Char, b : LibC::Char, c : LibC::Char, d : LibC::Char, value : UInt32, data : Pointer(Void)) : LibUI::ForEach {
          callback_state = ::Box(NativeCopyState).unbox(data)
          begin
            callback_state.values["#{a.chr}#{b.chr}#{c.chr}#{d.chr}"] = value
            0_u32
          rescue error
            callback_state.error = error
            1_u32
          end
        },
        ::Box.box(state)
      )
      if error = state.error
        raise error
      end
    end

    def clone : OpenTypeFeatures
      OpenTypeFeatures.new(@values.dup)
    end

    def add(tag : String, value : UInt32 = 1_u32) : Nil
      check_not_enumerating("add features")
      validate_tag(tag)
      @values[tag] = value
    end

    def remove(tag : String) : Nil
      check_not_enumerating("remove features")
      validate_tag(tag)
      @values.delete(tag)
    end

    def get(tag : String) : UInt32?
      validate_tag(tag)
      @values[tag]?
    end

    def for_each(&callback : (String, UInt32) -> _) : Nil
      @enumeration_depth += 1
      begin
        @values.each do |tag, value|
          callback.call(tag, value)
        end
      ensure
        @enumeration_depth -= 1
      end
    end

    private def check_not_enumerating(operation : String) : Nil
      return if @enumeration_depth == 0
      raise "Cannot #{operation} while OpenTypeFeatures is being enumerated"
    end

    private def validate_tag(tag : String) : Nil
      raise ArgumentError.new("OpenType tag must be exactly 4 bytes") unless tag.bytesize == 4

      unless tag.to_slice.all? { |byte| 0x20 <= byte <= 0x7e }
        raise ArgumentError.new("OpenType tag must contain only printable ASCII bytes")
      end
    end
  end
end
