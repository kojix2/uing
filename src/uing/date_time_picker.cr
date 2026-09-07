require "./control"

module UIng
  # A native picker for local calendar and clock fields.
  #
  # `Time` values are treated as wall-clock values: the setter copies their
  # displayed date and time fields without converting them to another time
  # zone. Values returned by the getter and callbacks use
  # `Time::Location.local`. The original instant, offset, and location therefore
  # do not round-trip when they differ from the local time zone.
  class DateTimePicker < Control
    block_constructor

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?
    # Keep TM instance to avoid repeated allocation and ensure memory safety
    @tm : UIng::TM

    def initialize(type : Symbol)
      case type
      when :date
        @ref_ptr = LibUI.new_date_picker
      when :time
        @ref_ptr = LibUI.new_time_picker
      when :date_time
        @ref_ptr = LibUI.new_date_time_picker
      else
        raise "Invalid type: #{type}"
      end
      @tm = UIng::TM.new
      register_control
    end

    def initialize
      @ref_ptr = LibUI.new_date_time_picker
      @tm = UIng::TM.new
      register_control
    end

    protected def after_destroy : Nil
      @on_changed_box = nil
    end

    # Returns the displayed wall-clock value in `Time::Location.local`.
    def time : Time
      LibUI.date_time_picker_time(ref_ptr, @tm)
      @tm.to_time
    end

    # Sets the displayed wall-clock fields from *time* without time-zone
    # conversion.
    def time=(time : Time) : Nil
      # Update our persistent @tm instance with new time
      temp_tm = UIng::TM.new(time)
      LibUI.date_time_picker_set_time(ref_ptr, temp_tm)
      # Sync @tm with the actual widget state
      LibUI.date_time_picker_time(ref_ptr, @tm)
    end

    # Invokes the block with the displayed wall-clock value in
    # `Time::Location.local`.
    def on_changed(&block : Time -> Nil) : Nil
      wrapper = -> : Nil {
        LibUI.date_time_picker_time(ref_ptr, @tm)
        current_time = @tm.to_time
        block.call(current_time)
      }
      @on_changed_box = ::Box.box(wrapper)
      if boxed_data = @on_changed_box
        LibUI.date_time_picker_on_changed(
          ref_ptr,
          ->(_sender, data) : Nil {
            begin
              data_as_callback = ::Box(typeof(wrapper)).unbox(data)
              data_as_callback.call
            rescue e
              UIng.handle_callback_error(e, "DateTimePicker on_changed")
            end
          },
          boxed_data
        )
      end
    end

    def to_unsafe
      ref_ptr
    end
  end
end
