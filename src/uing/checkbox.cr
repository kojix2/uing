require "./control"

module UIng
  class Checkbox
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Checkbox))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_checkbox
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
