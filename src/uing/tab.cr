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

    # def margined=(index : Int32, value : Bool)
    #   set_margined(index, value ? 1 : 0)
    # end
  end
end
