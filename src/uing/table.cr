require "./control"

module UIng
  class Table
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Table))
    end

    def initialize(table_params : (TableParams | LibUI::TableParams))
      @ref_ptr = LibUI.new_table(table_params)
    end

    def on_selection_changed(&block : -> Void)
      UIng.table_on_selection_changed(@ref_ptr, &block)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
