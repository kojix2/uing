module UIng
  class TM
    {% unless flag?(:windows) %}
      @zone : String? = nil
    {% end %}

    def initialize
      @cstruct = LibUI::Tm.new
      {% unless flag?(:windows) %}
        # Explicitly initialize zone to NULL for safety
        @cstruct.zone = Pointer(LibC::Char).null
      {% end %}
    end

    # Copies the calendar and clock fields from *time*. This does not convert
    # the value to the process-local time zone.
    def initialize(time : ::Time)
      @cstruct = LibUI::Tm.new
      {% unless flag?(:windows) %}
        @cstruct.zone = Pointer(LibC::Char).null
      {% end %}

      self.year = time.year - 1900 # tm_year is years since 1900
      self.mon = time.month - 1    # tm_mon is 0-based (0-11)
      self.mday = time.day
      self.hour = time.hour
      self.min = time.minute
      self.sec = time.second
      self.wday = time.day_of_week.to_i % 7 # 0 = Sunday
      self.yday = time.day_of_year - 1      # 0-based
      self.isdst = -1                       # Let mktime determine whether DST applies
      {% unless flag?(:windows) %}
        self.gmtoff = time.offset.to_i64
        self.zone = time.location.name
      {% end %}
    end

    {% unless flag?(:windows) %}
      def zone : String?
        ptr = @cstruct.zone
        if ptr.null?
          @zone = nil
          return nil
        end
        if owned = @zone
          return owned if ptr == owned.to_unsafe
        end
        capture_native_zone
        @zone
      end

      def zone=(value : String)
        @zone = String.new(value.to_slice)
        @cstruct.zone = @zone.not_nil!.to_unsafe
      end
    {% end %}

    # Copy a zone written by native code before its pointer can become stale.
    # Windows' struct tm has no zone field.
    def capture_native_zone : Nil
      {% unless flag?(:windows) %}
        ptr = @cstruct.zone
        @zone = ptr.null? ? nil : String.new(ptr)
        @cstruct.zone = @zone ? @zone.not_nil!.to_unsafe : Pointer(LibC::Char).null
      {% end %}
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end

    # Converts the calendar and clock fields to a value in
    # `Time::Location.local`. Stored offset and zone fields are not used.
    # Invalid date/time fields raise `ArgumentError`.
    def to_time : ::Time
      ::Time.local(
        year + 1900, # tm_year is years since 1900
        mon + 1,     # tm_mon is 0-based (0-11)
        mday,
        hour,
        min,
        sec,
        nanosecond: 0
      )
    end

    def to_time? : ::Time?
      to_time
    rescue ArgumentError
      nil
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
