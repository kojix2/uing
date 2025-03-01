require "./control"

module UIng
  class Combobox
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Combobox))
    end

    def initialize
      @ref_ptr = LibUI.new_combobox
    end

    def on_selected(&block : -> Void)
      UIng.combobox_on_selected(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
