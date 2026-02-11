module UIng
  class TM
    {% unless flag?(:windows) %}
      # C-side memory managed zone string pointer
      @zone_cstr : Pointer(UInt8)? = nil
      # Crystal-side reference for convenience methods
      @zone : String? = nil
    {% end %}

    def initialize(@cstruct : LibUI::TM = LibUI::TM.new)
      {% unless flag?(:windows) %}
        # Explicitly initialize zone to NULL for safety
        @cstruct.zone = Pointer(UInt8).null
      {% end %}
    end

    # Overloaded constructor: Convert Time to TM
    def initialize(time : ::Time)
      @cstruct = LibUI::TM.new
      {% unless flag?(:windows) %}
        @cstruct.zone = Pointer(UInt8).null
      {% end %}

      self.year = time.year - 1900 # tm_year is years since 1900
      self.mon = time.month - 1    # tm_mon is 0-based (0-11)
      self.mday = time.day
      self.hour = time.hour
      self.min = time.minute
      self.sec = time.second
      self.wday = time.day_of_week.to_i % 7 # 0 = Sunday
      self.yday = time.day_of_year - 1      # 0-based
      self.isdst = 0                        # Not handling DST
      {% unless flag?(:windows) %}
        self.gmtoff = time.offset.to_i64
        self.zone = time.location.name
      {% end %}
    end

    {% unless flag?(:windows) %}
      def zone : String?
        # Return Crystal-side reference if available
        return @zone if @zone
        # Otherwise copy from C pointer if not NULL
        ptr = @cstruct.zone
        return nil if ptr.null?
        String.new(ptr)
      end

      def zone=(value : String)
        # Free previous C memory if allocated
        if (old = @zone_cstr)
          LibC.free(old.as(Void*))
          @zone_cstr = nil
        end

        # Allocate C memory with strdup for safe ownership
        dup = LibC.strdup(value)
        raise "strdup failed" if dup.null?

        @zone_cstr = dup
        @cstruct.zone = dup
        @zone = value
      end

      def finalize
        # Clean up owned C memory
        if (ptr = @zone_cstr)
          LibC.free(ptr.as(Void*))
          @zone_cstr = nil
        end
      end
    {% end %}

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end

    # Convert TM to Time with error handling
    def to_time : ::Time
      begin
        ::Time.local(
          year + 1900, # tm_year is years since 1900
          mon + 1,     # tm_mon is 0-based (0-11)
          mday,
          hour,
          min,
          sec,
          nanosecond: 0
        )
      rescue e
        # Fallback to current time if conversion fails
        ::Time.local
      end
    end

    # Delegate to_s to Time for convenient formatting
    def to_s(io : IO, format : String) : Nil
      to_time.to_s(io, format)
    end

    def to_s(format : String) : String
      to_time.to_s(format)
    end

    def to_s(io : IO) : Nil
      to_time.to_s(io)
    end
  end
end
