require "./control"

module UIng
  class Combobox
    include Control

    # Store callback box to prevent GC collection
    @on_selected_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Combobox))
    end

    def initialize
      @ref_ptr = LibUI.new_combobox
    end

    def initialize(items : Array(String))
      initialize()
      items.each do |item|
        append(item)
      end
    end

    def on_selected(&block : -> Void)
      @on_selected_box = ::Box.box(block)
      UIng.combobox_on_selected(@ref_ptr, @on_selected_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
