require "./control"

module UIng
  class Table
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Table))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_table
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
