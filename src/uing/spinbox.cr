require "./control"

module UIng
  class Spinbox < Control
    block_constructor

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

    def value : Int32
      LibUI.spinbox_value(@ref_ptr)
    end

    def value=(value : Int32) : Nil
      LibUI.spinbox_set_value(@ref_ptr, value)
    end

    def on_changed(&block : Int32 -> Void)
      wrapper = -> {
        v = self.value
        block.call(v)
      }
      @on_changed_box = ::Box.box(wrapper)
      LibUI.spinbox_on_changed(@ref_ptr, ->(sender, data) do
        data_as_callback = ::Box(typeof(wrapper)).unbox(data)
        data_as_callback.call
      end, @on_changed_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
