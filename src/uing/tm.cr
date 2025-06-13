module UIng
  class TM
    def initialize(@cstruct : LibUI::TM = LibUI::TM.new)
    end

    # Overloaded constructor: Convert Time to TM
    def initialize(time : ::Time)
      @cstruct = LibUI::TM.new
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
      def zone
        String.new(@cstruct.zone)
      end

      def zone=(value : String)
        @zone = value
        @cstruct.zone = @zone.to_unsafe
      end
    {% end %}

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end

    # Convert TM to Time
    def to_time : ::Time
      ::Time.local(
        self.year + 1900, # tm_year is years since 1900
        self.mon + 1,     # tm_mon is 0-based (0-11)
        self.mday,
        self.hour,
        self.min,
        self.sec,
        nanosecond: 0
      )
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
