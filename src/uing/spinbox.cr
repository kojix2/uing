require "./control"

module UIng
  class Spinbox
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Spinbox))
    end

    def initialize(min, max)
      @ref_ptr = LibUI.new_spinbox(min, max)
    end

    def on_changed(&block : -> Void)
      UIng.spinbox_on_changed(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
