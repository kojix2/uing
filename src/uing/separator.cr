require "./control"

module UIng
  class Separator < Control
    block_constructor

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

    def destroy
      super
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
