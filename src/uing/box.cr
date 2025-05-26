require "./control"

module UIng
  # Note: The name Box is already taken by Crystal's built-in class Box.

  # Why not use HorizontalBox and VerticalBox?
  # Because the method_missing macro generates methods based on the class name.
  # If we use HorizontalBox and VerticalBox, methods like `horizontal_box_xxx`
  # and `vertical_box_xxx` will be generated.
  # However, we want methods like `box_xxx` to be generated.

  class Box
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Box))
    end

    def initialize(orientation : (Symbol | String))
      case orientation.to_s
      when "horizontal"
        @ref_ptr = LibUI.new_horizontal_box
      when "vertical"
        @ref_ptr = LibUI.new_vertical_box
      else
        raise "Invalid orientation: #{orientation}"
      end
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
