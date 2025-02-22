require "./control"

module UIng
  class DateTimePicker
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::DateTimePicker))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_date_time_picker
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
