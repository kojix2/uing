require "./control"

module UIng
  class Label
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Label))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_label
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
