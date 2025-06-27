require "./control"

module UIng
  class Checkbox < Control
    block_constructor

    # Store callback box to prevent GC collection
    @on_toggled_box : Pointer(Void)?

    def initialize(text : String)
      @ref_ptr = LibUI.new_checkbox(text)
    end

    def destroy
      @on_toggled_box = nil
      super
    end

    def text : String?
      str_ptr = LibUI.checkbox_text(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def text=(text : String) : Nil
      LibUI.checkbox_set_text(@ref_ptr, text)
    end

    def checked? : Bool
      LibUI.checkbox_checked(@ref_ptr)
    end

    def checked=(checked : Bool) : Nil
      LibUI.checkbox_set_checked(@ref_ptr, checked)
    end

    def on_toggled(&block : Bool -> _)
      wrapper = -> {
        checked = self.checked?
        block.call(checked)
      }
      @on_toggled_box = ::Box.box(wrapper)
      LibUI.checkbox_on_toggled(@ref_ptr, ->(sender, data) do
        begin
          data_as_callback = ::Box(typeof(wrapper)).unbox(data)
          data_as_callback.call
        rescue e
          UIng.handle_callback_error(e, "Checkbox on_toggled")
        end
      end, @on_toggled_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
