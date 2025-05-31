require "./control"

module UIng
  class EditableCombobox
    include Control; block_constructor

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::EditableCombobox))
    end

    def initialize
      @ref_ptr = LibUI.new_editable_combobox
    end

    def initialize(items : Array(String))
      initialize()
      items.each do |item|
        append(item)
      end
    end

    def on_changed(&block : String -> Void)
      wrapper = -> {
        text = UIng.editable_combobox_text(@ref_ptr) || ""
        block.call(text)
      }
      @on_changed_box = ::Box.box(wrapper)
      UIng.editable_combobox_on_changed(@ref_ptr, @on_changed_box.not_nil!, &wrapper)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
