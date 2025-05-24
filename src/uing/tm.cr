module UIng
  class TM
    # Default constructor
    def initialize(@cstruct : LibUI::TM = LibUI::TM.new)
    end

    # Overloaded constructor: Convert Time to TM
    def initialize(time : ::Time)
      @cstruct = LibUI::TM.new
      self.year = time.year
      self.mon = time.month
      self.mday = time.day
      self.hour = time.hour
      self.min = time.minute
      self.sec = time.second
      self.wday = time.day_of_week.to_i % 7  # 0 = Sunday
      self.yday = time.day_of_year - 1       # 0-based
      self.isdst = 0 # Not handling DST
      {% unless flag?(:windows) %}
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
        self.year,
        self.mon,
        self.mday,
        self.hour,
        self.min,
        self.sec
      )
    end
  end
end
