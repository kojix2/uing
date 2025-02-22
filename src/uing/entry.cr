require "./control"

module UIng
  class Entry
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Entry))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_entry
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
