require "./control"

module UIng
  class DateTimePicker
    include Control

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::DateTimePicker))
    end

    def initialize(type : (Symbol | String))
      case type.to_s
      when "date"
        @ref_ptr = LibUI.new_date_picker
      when "time"
        @ref_ptr = LibUI.new_time_picker
      else
        raise "Invalid type: #{type}"
      end
    end

    def initialize
      @ref_ptr = LibUI.new_date_time_picker
    end

    def on_changed(&block : UIng::TM -> Void)
      wrapper = -> {
        tm = UIng::TM.new
        self.time(tm)
        block.call(tm)
      }
      @on_changed_box = ::Box.box(wrapper)
      UIng.date_time_picker_on_changed(@ref_ptr, @on_changed_box.not_nil!, &wrapper)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
