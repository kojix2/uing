module UIng
  class DateTimePicker
    def initialize(@ref_ptr : Pointer(LibUI::DateTimePicker))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_date_time_picker
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
