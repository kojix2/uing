require "./control"

module UIng
  class Spinbox
    include Control

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Spinbox))
    end

    def initialize(min, max)
      @ref_ptr = LibUI.new_spinbox(min, max)
    end

    def on_changed(&block : -> Void)
      @on_changed_box = ::Box.box(block)
      UIng.spinbox_on_changed(@ref_ptr, @on_changed_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
