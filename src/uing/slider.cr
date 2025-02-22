require "./control"

module UIng
  class Slider
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Slider))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_slider
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
