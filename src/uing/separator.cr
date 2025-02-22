require "./control"

module UIng
  class Separator
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Separator))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_separator
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
