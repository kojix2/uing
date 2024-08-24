module UIng
  class TableModelHandler
    def initialize
      @cstruct = LibUI::TableModelHandler.new
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
