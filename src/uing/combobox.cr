require "./control"

module UIng
  class Combobox
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Combobox))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_combobox
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
