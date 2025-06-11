module UIng
  # TableModelHandler provides callbacks for Table data operations with closure support.
  #
  # CRITICAL MEMORY MANAGEMENT WARNINGS:
  # 1. TableModelHandler MUST remain alive while TableModel exists
  # 2. Callbacks become invalid if handler is GC'd - causes crashes
  # 3. Use closures safely - they can capture external data and variables
  #
  # Closure-friendly callback pattern:
  #   data = ["row1", "row2", "row3"]
  #   handler = TableModelHandler.new do
  #     num_rows { data.size }
  #     cell_value { |row, col| TableValue.new(data[row][col]) }
  #   end
  class TableModelHandler
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
        num_columns: ->(mh : LibUI::TableModelHandler*, m : LibUI::TableModel*) {
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
          rescue
            0_i32
          end
        },
        column_type: ->(mh : LibUI::TableModelHandler*, m : LibUI::TableModel*, column : LibC::Int) {
          begin
            extended = mh.as(LibUI::TableModelHandlerExtended*)
            if !extended.value.column_type_box.null?
              callback = ::Box(Proc(LibC::Int, UIng::TableValueType)).unbox(extended.value.column_type_box)
              callback.call(column)
            else
              UIng::TableValueType::String
            end
          rescue
            UIng::TableValueType::String
          end
        },
        num_rows: ->(mh : LibUI::TableModelHandler*, m : LibUI::TableModel*) {
          begin
            extended = mh.as(LibUI::TableModelHandlerExtended*)
            if !extended.value.num_rows_box.null?
              callback = ::Box(Proc(Int32)).unbox(extended.value.num_rows_box)
              result = callback.call
              result.as(LibC::Int)
            else
              0_i32
            end
          rescue
            0_i32
          end
        },
        cell_value: ->(mh : LibUI::TableModelHandler*, m : LibUI::TableModel*, row : LibC::Int, column : LibC::Int) {
          begin
            extended = mh.as(LibUI::TableModelHandlerExtended*)
            if !extended.value.cell_value_box.null?
              callback = ::Box(Proc(LibC::Int, LibC::Int, UIng::TableValue)).unbox(extended.value.cell_value_box)
              result = callback.call(row, column)
              result.to_unsafe
            else
              LibUI.new_table_value_string("")
            end
          rescue
            LibUI.new_table_value_string("")
          end
        },
        set_cell_value: ->(mh : LibUI::TableModelHandler*, m : LibUI::TableModel*, row : LibC::Int, column : LibC::Int, value : Pointer(UIng::LibUI::TableValue)) {
          begin
            extended = mh.as(LibUI::TableModelHandlerExtended*)
            if !extended.value.set_cell_value_box.null?
              callback = ::Box(Proc(LibC::Int, LibC::Int, Pointer(UIng::LibUI::TableValue), Nil)).unbox(extended.value.set_cell_value_box)
              callback.call(row, column, value)
            end
          rescue
            # Ignore errors in set_cell_value
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

    def column_type(&block : LibC::Int -> UIng::TableValueType)
      @column_type_box = ::Box.box(block)
      @extended_handler.column_type_box = @column_type_box
    end

    def num_rows(&block : -> Int32)
      @num_rows_box = ::Box.box(block)
      @extended_handler.num_rows_box = @num_rows_box
    end

    def cell_value(&block : LibC::Int, LibC::Int -> UIng::TableValue)
      @cell_value_box = ::Box.box(block)
      @extended_handler.cell_value_box = @cell_value_box
    end

    def set_cell_value(&block : LibC::Int, LibC::Int, Pointer(UIng::LibUI::TableValue) -> Nil)
      @set_cell_value_box = ::Box.box(block)
      @extended_handler.set_cell_value_box = @set_cell_value_box
    end

    def to_unsafe
      # Return pointer to the base_handler field of the extended handler
      # This ensures libui-ng receives a valid TableModelHandler pointer
      pointerof(@extended_handler).as(LibUI::TableModelHandler*)
    end
  end
end
