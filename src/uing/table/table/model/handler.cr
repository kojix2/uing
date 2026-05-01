module UIng
  # Table::Model::Handler provides callbacks for Table data operations with closure support.
  #
  # DESIGN PHILOSOPHY: Pure Data Access (Functional Approach)
  # - Callbacks are pure functions focused on data retrieval and computation
  # - No Table::Model parameter passed to avoid side effects and maintain data purity
  # - Emphasizes immutable data access patterns
  # - Callbacks should not modify external state beyond returning requested data
  #
  # CRITICAL MEMORY MANAGEMENT WARNINGS:
  # 1. Table::Model::Handler MUST remain alive while Table::Model exists
  # 2. Callbacks become invalid if handler is GC'd - causes crashes
  # 3. Use closures safely - they can capture external data and variables
  #
  # Closure-friendly callback pattern:
  #   data = ["row1", "row2", "row3"]
  #   handler = Table::Model::Handler.new do
  #     num_rows { data.size }
  #     cell_value { |row, col| TableValue.new(data[row][col]) }
  #   end
  class Table < Control
    class Model
      class Handler
        include BlockConstructor; block_constructor

        # Store the extended handler structure and individual boxes for GC protection
        @extended_handler : LibUI::TableModelHandlerExtended
        @num_columns_box : Pointer(Void)
        @column_type_box : Pointer(Void)
        @num_rows_box : Pointer(Void)
        @cell_value_box : Pointer(Void)
        @set_cell_value_box : Pointer(Void)

        def initialize
          # Initialize instance variables
          @num_columns_box = Pointer(Void).null
          @column_type_box = Pointer(Void).null
          @num_rows_box = Pointer(Void).null
          @cell_value_box = Pointer(Void).null
          @set_cell_value_box = Pointer(Void).null

          # Create extended handler with static callback functions
          @extended_handler = uninitialized LibUI::TableModelHandlerExtended

          # Initialize the base handler with static callbacks
          @extended_handler.base_handler = LibUI::TableModelHandler.new(
            num_columns: ->(mh : LibUI::TableModelHandler*, _m : LibUI::TableModel*) {
              begin
                # Cast the handler pointer to our extended structure
                extended = mh.as(LibUI::TableModelHandlerExtended*)
                if !extended.value.num_columns_box.null?
                  callback = ::Box(Proc(Int32)).unbox(extended.value.num_columns_box)
                  result = callback.call
                  result.as(LibC::Int)
                else
                  0_i32
                end
              rescue e
                UIng.handle_callback_error(e, "Table::Model::Handler num_columns")
                0_i32
              end
            },
            column_type: ->(mh : LibUI::TableModelHandler*, _m : LibUI::TableModel*, column : LibC::Int) {
              begin
                extended = mh.as(LibUI::TableModelHandlerExtended*)
                if !extended.value.column_type_box.null?
                  callback = ::Box(Proc(LibC::Int, Value::Type)).unbox(extended.value.column_type_box)
                  callback.call(column)
                else
                  Value::Type::String
                end
              rescue e
                UIng.handle_callback_error(e, "Table::Model::Handler column_type")
                Value::Type::String
              end
            },
            num_rows: ->(mh : LibUI::TableModelHandler*, _m : LibUI::TableModel*) {
              begin
                extended = mh.as(LibUI::TableModelHandlerExtended*)
                if !extended.value.num_rows_box.null?
                  callback = ::Box(Proc(Int32)).unbox(extended.value.num_rows_box)
                  result = callback.call
                  result.as(LibC::Int)
                else
                  0_i32
                end
              rescue e
                UIng.handle_callback_error(e, "Table::Model::Handler num_rows")
                0_i32
              end
            },
            cell_value: ->(mh : LibUI::TableModelHandler*, _m : LibUI::TableModel*, row : LibC::Int, column : LibC::Int) {
              begin
                extended = mh.as(LibUI::TableModelHandlerExtended*)
                if !extended.value.cell_value_box.null?
                  callback = ::Box(Proc(LibC::Int, LibC::Int, Value)).unbox(extended.value.cell_value_box)
                  result = callback.call(row, column)
                  result.to_unsafe
                else
                  LibUI.new_table_value_string("")
                end
              rescue e
                UIng.handle_callback_error(e, "Table::Model::Handler cell_value")
                LibUI.new_table_value_string("")
              end
            },
            set_cell_value: ->(mh : LibUI::TableModelHandler*, _m : LibUI::TableModel*, row : LibC::Int, column : LibC::Int, value : Pointer(UIng::LibUI::TableValue)) {
              begin
                extended = mh.as(LibUI::TableModelHandlerExtended*)
                if !extended.value.set_cell_value_box.null?
                  callback = ::Box(Proc(LibC::Int, LibC::Int, Value, Nil)).unbox(extended.value.set_cell_value_box)
                  table_value = Value.new(value, borrowed: true)
                  callback.call(row, column, table_value)
                end
              rescue e
                UIng.handle_callback_error(e, "Table::Model::Handler set_cell_value")
              end
            }
          )

          # Initialize the box pointers to null in the extended handler
          @extended_handler.num_columns_box = Pointer(Void).null
          @extended_handler.column_type_box = Pointer(Void).null
          @extended_handler.num_rows_box = Pointer(Void).null
          @extended_handler.cell_value_box = Pointer(Void).null
          @extended_handler.set_cell_value_box = Pointer(Void).null
        end

        # Convenience methods for setting individual callbacks
        # Each method boxes the callback individually for type safety and efficiency

        def num_columns(&block : -> Int32)
          @num_columns_box = ::Box.box(block)
          @extended_handler.num_columns_box = @num_columns_box
        end

        def column_type(&block : LibC::Int -> Value::Type)
          @column_type_box = ::Box.box(block)
          @extended_handler.column_type_box = @column_type_box
        end

        def num_rows(&block : -> Int32)
          @num_rows_box = ::Box.box(block)
          @extended_handler.num_rows_box = @num_rows_box
        end

        def cell_value(&block : LibC::Int, LibC::Int -> Value)
          @cell_value_box = ::Box.box(block)
          @extended_handler.cell_value_box = @cell_value_box
        end

        def set_cell_value(&block : LibC::Int, LibC::Int, Value -> Nil)
          @set_cell_value_box = ::Box.box(block)
          @extended_handler.set_cell_value_box = @set_cell_value_box
        end

        def to_unsafe
          # Return pointer to the extended handler, but cast to base handler type
          # This maintains the extended structure layout while providing C compatibility
          pointerof(@extended_handler).as(LibUI::TableModelHandler*)
        end
      end
    end
  end
end
