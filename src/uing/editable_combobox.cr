require "./control"

module UIng
  class EditableCombobox
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::EditableCombobox))
    end

    def initialize
      @ref_ptr = LibUI.new_editable_combobox
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
