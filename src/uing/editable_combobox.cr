require "./control"

module UIng
  class EditableCombobox < Control
    block_constructor

    @released : Bool = false

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize
      @ref_ptr = LibUI.new_editable_combobox
    end

    def destroy
      return if @released
      @on_changed_box = nil
      super.tap { @released = true }
    end

    def initialize(items : Array(String))
      initialize()
      items.each do |item|
        append(item)
      end
    end

    def append(text : String) : Nil
      LibUI.editable_combobox_append(@ref_ptr, text)
    end

    def text : String?
      str_ptr = LibUI.editable_combobox_text(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def text=(text : String) : Nil
      LibUI.editable_combobox_set_text(@ref_ptr, text)
    end

    def on_changed(&block : String -> Void)
      wrapper = -> {
        current_text = self.text || ""
        block.call(current_text)
      }
      @on_changed_box = ::Box.box(wrapper)
      LibUI.editable_combobox_on_changed(@ref_ptr, ->(sender, data) do
        begin
          data_as_callback = ::Box(typeof(wrapper)).unbox(data)
          data_as_callback.call
        rescue e
          UIng.handle_callback_error(e, "EditableCombobox on_changed")
        end
      end, @on_changed_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
