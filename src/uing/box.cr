require "./control"

module UIng
  # Note: The name Box is already taken by Crystal's built-in class Box.
  abstract class Box
    include Control

    def to_unsafe
      @ref_ptr
    end
  end

  class VerticalBox < Box
    def initialize(@ref_ptr : Pointer(LibUI::Box))
    end

    def initialize
      @ref_ptr = LibUI.new_vertical_box
    end
  end

  class HorizontalBox < Box
    def initialize(@ref_ptr : Pointer(LibUI::Box))
    end

    def initialize
      @ref_ptr = LibUI.new_horizontal_box
    end
  end
end
