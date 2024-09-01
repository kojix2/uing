module UIng
  class TableSelection
    def initialize(@cstruct : LibUI::TableSelection = LibUI::TableSelection.new)
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
