require "./control"

module UIng
  class Spinbox
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Spinbox))
    end

    def initialize(min, max)
      @ref_ptr = LibUI.new_spinbox(min, max)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
