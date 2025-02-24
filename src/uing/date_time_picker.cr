require "./control"

module UIng
  class DateTimePicker
    include Control

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

    def on_changed(&block)
      UIng.date_time_picker_on_changed(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
