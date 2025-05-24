require "./control"

module UIng
  class Entry
    include Control

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Entry))
    end

    def initialize
      @ref_ptr = LibUI.new_entry
    end

    def on_changed(&block : -> Void)
      @on_changed_box = ::Box.box(block)
      UIng.entry_on_changed(@ref_ptr, @on_changed_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end

    def text=(value : String)
      set_text(value)
    end

    def read_only=(value : Bool)
      set_read_only(value ? 1 : 0)
    end
  end
end
