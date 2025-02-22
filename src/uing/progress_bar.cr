require "./control"

module UIng
  class ProgressBar
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::ProgressBar))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_progress_bar
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
