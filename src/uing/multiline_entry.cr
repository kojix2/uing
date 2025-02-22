require "./control"

module UIng
  class MultilineEntry
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::MultilineEntry))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_multiline_entry
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
