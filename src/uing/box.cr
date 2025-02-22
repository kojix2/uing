require "./control"

module UIng
  # Note: The name Box is already taken by Crystal's built-in class Box.
  class Box
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Box))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_box
    # end

    forward_missing_to(@ref_ptr)

    def to_unsafe
      @ref_ptr
    end
  end
end
