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
      LibUI.table_on_row_clicked(@ref_ptr, ->(table, row, data) do
        callback = ::Box(typeof(block)).unbox(data)
        callback.call(row)
      end, @on_row_clicked_box.not_nil!)
    end

    def on_row_double_clicked(&block : LibC::Int -> Void)
      @on_row_double_clicked_box = ::Box.box(block)
      LibUI.table_on_row_double_clicked(@ref_ptr, ->(table, row, data) do
        callback = ::Box(typeof(block)).unbox(data)
        callback.call(row)
      end, @on_row_double_clicked_box.not_nil!)
    end

    def on_header_clicked(&block : LibC::Int -> Void)
      @on_header_clicked_box = ::Box.box(block)
      LibUI.table_header_on_clicked(@ref_ptr, ->(table, column, data) do
        callback = ::Box(typeof(block)).unbox(data)
        callback.call(column)
      end, @on_header_clicked_box.not_nil!)
    end

    def on_selection_changed(&block : -> Void)
      @on_selection_changed_box = ::Box.box(block)
      LibUI.table_on_selection_changed(@ref_ptr, ->(table, data) do
        callback = ::Box(typeof(block)).unbox(data)
        callback.call
      end, @on_selection_changed_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end

    def header_visible=(value : Bool)
      LibUI.table_header_set_visible(@ref_ptr, value ? 1 : 0)
    end

    def append_text_column(name : String, text_model_column : Int32, text_editable_model_column : Int32, table_text_column_optional_params = nil) : Nil
      LibUI.table_append_text_column(@ref_ptr, name, text_model_column, text_editable_model_column, table_text_column_optional_params)
    end

    def append_image_column(name : String, image_model_column : Int32) : Nil
      LibUI.table_append_image_column(@ref_ptr, name, image_model_column)
    end

    def append_image_text_column(name : String, image_model_column : Int32, text_model_column : Int32, text_editable_model_column : Int32, table_text_column_optional_params = nil) : Nil
      LibUI.table_append_image_text_column(@ref_ptr, name, image_model_column, text_model_column, text_editable_model_column, table_text_column_optional_params)
    end

    def append_checkbox_column(name : String, checkbox_model_column : Int32, checkbox_editable_model_column : Int32) : Nil
      LibUI.table_append_checkbox_column(@ref_ptr, name, checkbox_model_column, checkbox_editable_model_column)
    end

    def append_checkbox_text_column(name : String, checkbox_model_column : Int32, checkbox_editable_model_column : Int32, text_model_column : Int32, text_editable_model_column : Int32, table_text_column_optional_params = nil) : Nil
      LibUI.table_append_checkbox_text_column(@ref_ptr, name, checkbox_model_column, checkbox_editable_model_column, text_model_column, text_editable_model_column, table_text_column_optional_params)
    end

    def append_progress_bar_column(name : String, progress_model_column : Int32) : Nil
      LibUI.table_append_progress_bar_column(@ref_ptr, name, progress_model_column)
    end

    def append_button_column(name : String, button_model_column : Int32, button_clickable_model_column : Int32) : Nil
      LibUI.table_append_button_column(@ref_ptr, name, button_model_column, button_clickable_model_column)
    end

    def header_visible? : Bool
      LibUI.table_header_visible(@ref_ptr)
    end

    def header_set_sort_indicator(column : Int32, sort_indicator : SortIndicator) : Nil
      LibUI.table_header_set_sort_indicator(@ref_ptr, column, sort_indicator)
    end

    def header_sort_indicator(column : Int32) : SortIndicator
      LibUI.table_header_sort_indicator(@ref_ptr, column)
    end

    def column_width(column : Int32) : Int32
      LibUI.table_column_width(@ref_ptr, column)
    end

    def column_set_width(column : Int32, width : Int32) : Nil
      LibUI.table_column_set_width(@ref_ptr, column, width)
    end

    def selection_mode : TableSelectionMode
      LibUI.table_get_selection_mode(@ref_ptr)
    end

    def selection_mode=(mode : TableSelectionMode) : Nil
      LibUI.table_set_selection_mode(@ref_ptr, mode)
    end

    def selection : TableSelection
      ref_ptr = LibUI.table_get_selection(@ref_ptr)
      TableSelection.new(ref_ptr)
    end

    def selection=(selection : TableSelection) : Nil
      LibUI.table_set_selection(@ref_ptr, selection.to_unsafe)
    end
  end
end
