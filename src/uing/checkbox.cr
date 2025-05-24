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

    def on_toggled(&block : -> Void)
      @on_toggled_box = ::Box.box(block)
      UIng.checkbox_on_toggled(@ref_ptr, @on_toggled_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end

    def text=(value : String)
      set_text(value)
    end

    def checked=(value : Bool)
      set_checked(value ? 1 : 0)
    end
  end
end
