require "../control"
require "./table/*"

module UIng
  class Table < Control
    block_constructor

    # Store callback boxes to prevent GC collection
    @on_row_clicked_box : Pointer(Void)?
    @on_row_double_clicked_box : Pointer(Void)?
    @on_header_clicked_box : Pointer(Void)?
    @on_selection_changed_box : Pointer(Void)?

    # Store Model reference to prevent GC collection
    @table_model_ref : Model?

    # IMPORTANT: This method accepts Table::Model instead of Table::Params
    def initialize(model : Model, row_background_color_model_column : LibC::Int = -1)
      table_params = Params.new(model, row_background_color_model_column)
      @ref_ptr = LibUI.new_table(table_params)
      @table_model_ref = model
    end

    def destroy
      @on_row_clicked_box = nil
      @on_row_double_clicked_box = nil
      @on_header_clicked_box = nil
      @on_selection_changed_box = nil
      super
    end

    def on_row_clicked(&block : LibC::Int -> _) : Nil
      @on_row_clicked_box = ::Box.box(block)
      if boxed_data = @on_row_clicked_box
        LibUI.table_on_row_clicked(
          @ref_ptr,
          ->(_table, row, data) {
            begin
              callback = ::Box(typeof(block)).unbox(data)
              callback.call(row)
            rescue e
              UIng.handle_callback_error(e, "Table on_row_clicked")
            end
          },
          boxed_data
        )
      end
    end

    def on_row_double_clicked(&block : LibC::Int -> _) : Nil
      @on_row_double_clicked_box = ::Box.box(block)
      if boxed_data = @on_row_double_clicked_box
        LibUI.table_on_row_double_clicked(
          @ref_ptr,
          ->(_table, row, data) {
            begin
              callback = ::Box(typeof(block)).unbox(data)
              callback.call(row)
            rescue e
              UIng.handle_callback_error(e, "Table on_row_double_clicked")
            end
          },
          boxed_data
        )
      end
    end

    def on_header_clicked(&block : LibC::Int -> _) : Nil
      @on_header_clicked_box = ::Box.box(block)
      if boxed_data = @on_header_clicked_box
        LibUI.table_header_on_clicked(
          @ref_ptr,
          ->(_table, column, data) {
            begin
              callback = ::Box(typeof(block)).unbox(data)
              callback.call(column)
            rescue e
              UIng.handle_callback_error(e, "Table on_header_clicked")
            end
          },
          boxed_data
        )
      end
    end

    def on_selection_changed(&block : Selection -> _) : Nil
      @on_selection_changed_box = ::Box.box(block)
      if boxed_data = @on_selection_changed_box
        LibUI.table_on_selection_changed(
          @ref_ptr,
          ->(table, data) {
            begin
              callback = ::Box(typeof(block)).unbox(data)
              # Get current selection and pass it to the callback
              selection_ptr = LibUI.table_get_selection(table)
              selection = Selection.new(selection_ptr)
              callback.call(selection)
              # Automatically free the selection after callback
              selection.free
            rescue e
              UIng.handle_callback_error(e, "Table on_selection_changed")
            end
          },
          boxed_data
        )
      end
    end

    def to_unsafe
      @ref_ptr
    end

    def header_visible=(value : Bool)
      LibUI.table_header_set_visible(@ref_ptr, value)
    end

    def append_text_column(name : String, text_model_column : Int32, text_editable_model_column : Int32) : Nil
      LibUI.table_append_text_column(@ref_ptr, name, text_model_column, text_editable_model_column, nil)
    end

    def append_text_column(name : String, text_model_column : Int32, text_editable_model_column : Int32, table_text_column_optional_params : TableTextColumnOptionalParams) : Nil
      LibUI.table_append_text_column(@ref_ptr, name, text_model_column, text_editable_model_column, table_text_column_optional_params)
    end

    def append_text_column(name : String, text_model_column : Int32, text_editable_model_column : Int32, color_model_column : Int32) : Nil
      table_text_column_optional_params = TableTextColumnOptionalParams.new(color_model_column)
      LibUI.table_append_text_column(@ref_ptr, name, text_model_column, text_editable_model_column, table_text_column_optional_params)
    end

    def append_image_column(name : String, image_model_column : Int32) : Nil
      LibUI.table_append_image_column(@ref_ptr, name, image_model_column)
    end

    def append_image_text_column(name : String, image_model_column : Int32, text_model_column : Int32, text_editable_model_column : Int32) : Nil
      LibUI.table_append_image_text_column(@ref_ptr, name, image_model_column, text_model_column, text_editable_model_column, nil)
    end

    def append_image_text_column(name : String, image_model_column : Int32, text_model_column : Int32, text_editable_model_column : Int32, table_text_column_optional_params : TableTextColumnOptionalParams) : Nil
      LibUI.table_append_image_text_column(@ref_ptr, name, image_model_column, text_model_column, text_editable_model_column, table_text_column_optional_params)
    end

    def append_image_text_column(name : String, image_model_column : Int32, text_model_column : Int32, text_editable_model_column : Int32, color_model_column : Int32) : Nil
      table_text_column_optional_params = TableTextColumnOptionalParams.new(color_model_column)
      LibUI.table_append_image_text_column(@ref_ptr, name, image_model_column, text_model_column, text_editable_model_column, table_text_column_optional_params)
    end

    def append_checkbox_column(name : String, checkbox_model_column : Int32, checkbox_editable_model_column : Int32) : Nil
      LibUI.table_append_checkbox_column(@ref_ptr, name, checkbox_model_column, checkbox_editable_model_column)
    end

    def append_checkbox_text_column(name : String, checkbox_model_column : Int32, checkbox_editable_model_column : Int32, text_model_column : Int32, text_editable_model_column : Int32) : Nil
      LibUI.table_append_checkbox_text_column(@ref_ptr, name, checkbox_model_column, checkbox_editable_model_column, text_model_column, text_editable_model_column, nil)
    end

    def append_checkbox_text_column(name : String, checkbox_model_column : Int32, checkbox_editable_model_column : Int32, text_model_column : Int32, text_editable_model_column : Int32, table_text_column_optional_params : TableTextColumnOptionalParams) : Nil
      LibUI.table_append_checkbox_text_column(@ref_ptr, name, checkbox_model_column, checkbox_editable_model_column, text_model_column, text_editable_model_column, table_text_column_optional_params)
    end

    def append_checkbox_text_column(name : String, checkbox_model_column : Int32, checkbox_editable_model_column : Int32, text_model_column : Int32, text_editable_model_column : Int32, color_model_column : Int32) : Nil
      table_text_column_optional_params = TableTextColumnOptionalParams.new(color_model_column)
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

    def selection_mode : Selection::Mode
      LibUI.table_get_selection_mode(@ref_ptr)
    end

    def selection_mode=(mode : Selection::Mode) : Nil
      LibUI.table_set_selection_mode(@ref_ptr, mode)
    end

    def selection : Selection
      ref_ptr = LibUI.table_get_selection(@ref_ptr)
      Selection.new(ref_ptr)
    end

    # Block version that automatically frees the selection after the block
    # This eliminates the need for manual free() calls
    def selection(& : Selection -> Nil) : Nil
      selection_obj = selection
      begin
        yield selection_obj
      ensure
        selection_obj.free
      end
    end

    def selection=(selection : Selection) : Nil
      LibUI.table_set_selection(@ref_ptr, selection.to_unsafe)
    end
  end
end
