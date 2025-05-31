require "./control"

module UIng
  class Checkbox
    include Control

    # Store callback box to prevent GC collection
    @on_toggled_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Checkbox))
    end

    def initialize(text : String)
      @ref_ptr = LibUI.new_checkbox(text)
    end

    def initialize(text : String, &block : Bool -> Void)
      initialize(text)
      on_toggled(&block)
    end

    def on_toggled(&block : Bool -> Void)
      wrapper = -> {
        checked = self.checked
        block.call(checked)
      }
      @on_toggled_box = ::Box.box(wrapper)
      UIng.checkbox_on_toggled(@ref_ptr, @on_toggled_box.not_nil!, &wrapper)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
