require "./control"

module UIng
  class DateTimePicker < Control
    block_constructor

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

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
    end

    def initialize
      @ref_ptr = LibUI.new_date_time_picker
    end

    def destroy
      @on_changed_box = nil
      super
    end

    def time : Time
      tm = UIng::TM.new
      LibUI.date_time_picker_time(@ref_ptr, tm)
      tm.to_time
    end

    def time=(time : Time) : Nil
      tm = UIng::TM.new(time)
      LibUI.date_time_picker_set_time(@ref_ptr, tm)
    end

    def on_changed(&block : Time -> _)
      wrapper = -> {
        time = self.time
        block.call(time)
      }
      @on_changed_box = ::Box.box(wrapper)
      LibUI.date_time_picker_on_changed(@ref_ptr, ->(sender, data) do
        begin
          data_as_callback = ::Box(typeof(wrapper)).unbox(data)
          data_as_callback.call
        rescue e
          UIng.handle_callback_error(e, "DateTimePicker on_changed")
        end
      end, @on_changed_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
