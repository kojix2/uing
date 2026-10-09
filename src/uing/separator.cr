require "./control"

module UIng
  class Separator < Control
    block_constructor

    @ref_ptr : Pointer(LibUI::Separator)

    def initialize(orientation : Orientation | Symbol)
      value = orientation.is_a?(Symbol) ? Orientation.parse(orientation.to_s) : orientation
      @ref_ptr = case value
                 when .horizontal?
                   LibUI.new_horizontal_separator
                 when .vertical?
                   LibUI.new_vertical_separator
                 else
                   raise ArgumentError.new("Unsupported separator orientation: #{value}")
                 end
      register_control
    end

    def to_unsafe
      ref_ptr
    end
  end
end
