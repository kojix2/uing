module UIng
  class TableSelection
    def initialize(@cstruct : LibUI::TableSelection = LibUI::TableSelection.new)
    end

    def free : Nil
      LibUI.free_table_selection(self.to_unsafe)
    end

    def to_unsafe
      pointerof(@cstruct)
    end
  end
end
