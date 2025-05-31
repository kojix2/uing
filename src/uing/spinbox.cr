require "./control"

module UIng
  class Spinbox
    include Control; block_constructor

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Spinbox))
    end

    def initialize(min, max)
      @ref_ptr = LibUI.new_spinbox(min, max)
    end

    def initialize(min, max, value)
      @ref_ptr = LibUI.new_spinbox(min, max)
      self.value = value
    end

    def on_changed(&block : LibC::Int -> Void)
      wrapper = -> {
        v = self.value
        block.call(v)
      }
      @on_changed_box = ::Box.box(wrapper)
      UIng.spinbox_on_changed(@ref_ptr, @on_changed_box.not_nil!, &wrapper)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
