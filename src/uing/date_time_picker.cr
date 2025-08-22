require "./control"

module UIng
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
    end

    def initialize
      @ref_ptr = LibUI.new_date_time_picker
      @tm = UIng::TM.new
    end

    def destroy
      @on_changed_box = nil
      super
    end

    def time : Time
      return Time.local unless @ref_ptr

      begin
        LibUI.date_time_picker_time(@ref_ptr, @tm)
        @tm.to_time
      rescue e
        UIng.handle_callback_error(e, "DateTimePicker time retrieval")
        Time.local
      end
    end

    def time=(time : Time) : Nil
      return unless @ref_ptr

      begin
        # Update our persistent @tm instance with new time
        temp_tm = UIng::TM.new(time)
        LibUI.date_time_picker_set_time(@ref_ptr, temp_tm)
        # Sync @tm with the actual widget state
        LibUI.date_time_picker_time(@ref_ptr, @tm)
      rescue e
        UIng.handle_callback_error(e, "DateTimePicker time setting")
      end
    end

    def on_changed(&block : Time -> _) : Nil
      wrapper = -> {
        return unless @ref_ptr

        begin
          # Use persistent @tm instance to avoid allocation in callback
          LibUI.date_time_picker_time(@ref_ptr, @tm)
          current_time = @tm.to_time
          block.call(current_time)
        rescue e
          UIng.handle_callback_error(e, "DateTimePicker on_changed")
        end
      }
      @on_changed_box = ::Box.box(wrapper)
      if boxed_data = @on_changed_box
        LibUI.date_time_picker_on_changed(
          @ref_ptr,
          ->(_sender, data) {
            begin
              data_as_callback = ::Box(typeof(wrapper)).unbox(data)
              data_as_callback.call
            rescue e
              UIng.handle_callback_error(e, "DateTimePicker callback wrapper")
            end
          },
          boxed_data
        )
      end
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
