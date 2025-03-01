require "./control"

module UIng
  class Entry
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Entry))
    end

    def initialize
      @ref_ptr = LibUI.new_entry
    end

    def on_changed(&block : -> Void)
      UIng.entry_on_changed(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
