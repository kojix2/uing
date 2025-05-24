require "./control"

module UIng
  class EditableCombobox
    include Control

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::EditableCombobox))
    end

    def initialize
      @ref_ptr = LibUI.new_editable_combobox
    end

    def on_changed(&block : -> Void)
      @on_changed_box = ::Box.box(block)
      UIng.editable_combobox_on_changed(@ref_ptr, @on_changed_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end

    def text=(value : String)
      set_text(value)
    end
  end
end
