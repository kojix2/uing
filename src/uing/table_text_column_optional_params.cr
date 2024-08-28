module UIng
  class TableTextColumnOptionalParams
    def initialize(@cstruct : LibUI::TableTextColumnOptionalParams = LibUI::TableTextColumnOptionalParams.new)
    end

    forward_missing_to(@cstruct)

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
