require "./control"

module UIng
  class Button
    include Control

    # Store callback box to prevent GC collection
    @on_clicked_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Button))
    end

    def initialize(text : String)
      @ref_ptr = LibUI.new_button(text)
    end

    def on_clicked(&block : -> Void)
      @on_clicked_box = ::Box.box(block)
      UIng.button_on_clicked(@ref_ptr, @on_clicked_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
