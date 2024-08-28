module UIng
  class TableParams
    def initialize(@cstruct : LibUI::TableParams = LibUI::TableParams.new)
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
