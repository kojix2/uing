require "./control"

module UIng
  class ColorButton
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::ColorButton))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_color_button
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
