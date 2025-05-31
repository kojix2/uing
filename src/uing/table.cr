require "./control"

module UIng
  class Table
    include Control; block_constructor

    # Store callback boxes to prevent GC collection
    @on_row_clicked_box : Pointer(Void)?
    @on_row_double_clicked_box : Pointer(Void)?
    @on_header_clicked_box : Pointer(Void)?
    @on_selection_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Table))
    end

    def initialize(table_params : (TableParams | LibUI::TableParams))
      @ref_ptr = LibUI.new_table(table_params)
    end

    def on_row_clicked(&block : LibC::Int -> Void)
      @on_row_clicked_box = ::Box.box(block)
      UIng.table_on_row_clicked(@ref_ptr, @on_row_clicked_box.not_nil!, &block)
    end

    def on_row_double_clicked(&block : LibC::Int -> Void)
      @on_row_double_clicked_box = ::Box.box(block)
      UIng.table_on_row_double_clicked(@ref_ptr, @on_row_double_clicked_box.not_nil!, &block)
    end

    def on_header_clicked(&block : LibC::Int -> Void)
      @on_header_clicked_box = ::Box.box(block)
      UIng.table_header_on_clicked(@ref_ptr, @on_header_clicked_box.not_nil!, &block)
    end

    def on_selection_changed(&block : -> Void)
      @on_selection_changed_box = ::Box.box(block)
      UIng.table_on_selection_changed(@ref_ptr, @on_selection_changed_box.not_nil!, &block)
    end

    def to_unsafe
      @ref_ptr
    end

    def header_visible=(value : Bool)
      UIng.table_header_set_visible(@ref_ptr, value ? 1 : 0)
    end
  end
end
