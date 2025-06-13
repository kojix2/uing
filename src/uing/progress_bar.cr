require "./control"

module UIng
  class ProgressBar < Control
    block_constructor

    def initialize
      @ref_ptr = LibUI.new_progress_bar
    end

    def value : Int32
      LibUI.progress_bar_value(@ref_ptr)
    end

    def value=(n : Int32) : Nil
      LibUI.progress_bar_set_value(@ref_ptr, n)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
