require "./control"

module UIng
  class MultilineEntry
    include Control

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
      UIng.multiline_entry_on_changed(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
