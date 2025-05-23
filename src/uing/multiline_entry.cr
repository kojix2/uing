require "./control"

module UIng
  class MultilineEntry
    include Control

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::MultilineEntry))
    end

    def initialize(wrapping = true)
      if wrapping
        @ref_ptr = LibUI.new_multiline_entry
      else
        @ref_ptr = LibUI.new_non_wrapping_multiline_entry
      end
    end

    def on_changed(&block : -> Void)
      @on_changed_box = ::Box.box(block)
      UIng.multiline_entry_on_changed(@ref_ptr, @on_changed_box.not_nil!, &block)
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
