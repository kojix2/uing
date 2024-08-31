module UIng
  class ProgressBar
    def initialize(@ref_ptr : Pointer(LibUI::ProgressBar))
    end

    def initialize
      @ref_ptr = LibUI.new_progress_bar
    end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
