require "./control"

module UIng
  class Tab
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Tab))
    end

    def initialize
      @ref_ptr = LibUI.new_tab
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
