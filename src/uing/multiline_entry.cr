require "./control"

module UIng
  class MultilineEntry
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::MultilineEntry))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_multiline_entry
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
