require "./control"

module UIng
  class Separator
    include Control; block_constructor

    def initialize(@ref_ptr : Pointer(LibUI::Separator))
    end

    def initialize(orientation : (Symbol | String))
      case orientation.to_s
      when "horizontal"
        @ref_ptr = LibUI.new_horizontal_separator
      when "vertical"
        @ref_ptr = LibUI.new_vertical_separator
      else
        raise "Invalid orientation: #{orientation}"
      end
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
