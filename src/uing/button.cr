require "./control"

module UIng
  class Button < Control
    block_constructor

    # Store callback box to prevent GC collection
    @on_clicked_box : Pointer(Void)?

    def initialize(text : String)
      @ref_ptr = LibUI.new_button(text)
    end

    def destroy
      @on_clicked_box = nil
      super
    end

    def text : String?
      str_ptr = LibUI.button_text(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def text=(text : String) : Nil
      LibUI.button_set_text(@ref_ptr, text)
    end

    def on_clicked(&block : -> _)
      @on_clicked_box = ::Box.box(block)
      LibUI.button_on_clicked(@ref_ptr, ->(sender, data) do
        begin
          data_as_callback = ::Box(typeof(block)).unbox(data)
          data_as_callback.call
        rescue e
          UIng.handle_callback_error(e, "Button on_clicked")
        end
      end, @on_clicked_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
