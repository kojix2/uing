require "./control"

module UIng
  class Checkbox
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Checkbox))
    end

    def initialize(text : String)
      @ref_ptr = LibUI.new_checkbox(text)
    end

    def on_toggled(&block : -> Void)
      UIng.checkbox_on_toggled(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
