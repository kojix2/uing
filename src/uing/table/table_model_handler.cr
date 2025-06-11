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
  #   handler = TableModelHandler.new do |callbacks|
  #     callbacks.num_rows = -> { data.size }
  #     callbacks.cell_value = ->(row, col) { 
  #       TableValue.new(data[row]) # Can safely capture 'data'
  #     }
  #   end
  class TableModelHandler
    include BlockConstructor; block_constructor

    # Global registry to map handler pointers to callback data
    # This prevents GC collection and allows safe callback lookup
    @@handler_registry = {} of Pointer(LibUI::TableModelHandler) => Pointer(Void)

    # Callback class that holds all user-defined callbacks
    # Changed from struct to class to ensure reference semantics
    private class CallbackData
      property num_columns : (-> LibC::Int)?
      property column_type : (LibC::Int -> UIng::TableValueType)?
      property num_rows : (-> LibC::Int)?
      property cell_value : (LibC::Int, LibC::Int -> Pointer(UIng::LibUI::TableValue))?
      property set_cell_value : (LibC::Int, LibC::Int, Pointer(UIng::LibUI::TableValue) -> Void)?

      def initialize
      end
    end

    # Store the handler structure, callback data, and boxed callback data
    @handler : LibUI::TableModelHandler
    @callback_data : CallbackData
    @callback_data_box : Pointer(Void)

    def initialize
      # Create callback data structure
      @callback_data = CallbackData.new
      
      # Box the callback data to prevent GC collection
      @callback_data_box = ::Box.box(@callback_data)
      
      # Create handler with static callback functions
      @handler = LibUI::TableModelHandler.new(
        num_columns: ->(mh : LibUI::TableModelHandler*, m : LibUI::TableModel*) {
          begin
            # Look up callback data from global registry
            if callback_data_box = @@handler_registry[mh]?
              callbacks = ::Box(CallbackData).unbox(callback_data_box)
              if callback = callbacks.num_columns
                callback.call
              else
                0_i32
              end
            else
              0_i32
            end
          rescue
            0_i32
          end
        },
        column_type: ->(mh : LibUI::TableModelHandler*, m : LibUI::TableModel*, column : LibC::Int) {
          begin
            if callback_data_box = @@handler_registry[mh]?
              callbacks = ::Box(CallbackData).unbox(callback_data_box)
              if callback = callbacks.column_type
                callback.call(column)
              else
                UIng::TableValueType::String
              end
            else
              UIng::TableValueType::String
            end
          rescue
            UIng::TableValueType::String
          end
        },
        num_rows: ->(mh : LibUI::TableModelHandler*, m : LibUI::TableModel*) {
          begin
            if callback_data_box = @@handler_registry[mh]?
              callbacks = ::Box(CallbackData).unbox(callback_data_box)
              if callback = callbacks.num_rows
                callback.call
              else
                0_i32
              end
            else
              0_i32
            end
          rescue
            0_i32
          end
        },
        cell_value: ->(mh : LibUI::TableModelHandler*, m : LibUI::TableModel*, row : LibC::Int, column : LibC::Int) {
          begin
            if callback_data_box = @@handler_registry[mh]?
              callbacks = ::Box(CallbackData).unbox(callback_data_box)
              if callback = callbacks.cell_value
                callback.call(row, column)
              else
                LibUI.new_table_value_string("")
              end
            else
              LibUI.new_table_value_string("")
            end
          rescue
            LibUI.new_table_value_string("")
          end
        },
        set_cell_value: ->(mh : LibUI::TableModelHandler*, m : LibUI::TableModel*, row : LibC::Int, column : LibC::Int, value : Pointer(UIng::LibUI::TableValue)) {
          begin
            if callback_data_box = @@handler_registry[mh]?
              callbacks = ::Box(CallbackData).unbox(callback_data_box)
              if callback = callbacks.set_cell_value
                callback.call(row, column, value)
              end
            end
          rescue
            # Ignore errors in set_cell_value
          end
        }
      )
      
      # Register the handler pointer with callback data
      handler_ptr = pointerof(@handler)
      @@handler_registry[handler_ptr] = @callback_data_box
    end

    # Convenience methods for setting individual callbacks
    # These provide a more familiar API similar to the old implementation
    
    def num_columns(&block : -> Int32)
      # Wrap the user's block to automatically convert to LibC::Int
      @callback_data.num_columns = -> {
        result = block.call
        result.as(LibC::Int)
      }
    end

    def column_type(&block : LibC::Int -> UIng::TableValueType)
      @callback_data.column_type = block
    end

    def num_rows(&block : -> Int32)
      # Wrap the user's block to automatically convert to LibC::Int
      @callback_data.num_rows = -> {
        result = block.call
        result.as(LibC::Int)
      }
    end

    def cell_value(&block : LibC::Int, LibC::Int -> UIng::TableValue)
      # Wrap the user's block to automatically call to_unsafe
      @callback_data.cell_value = ->(row : LibC::Int, column : LibC::Int) {
        result = block.call(row, column)
        result.to_unsafe
      }
    end

    def set_cell_value(&block : LibC::Int, LibC::Int, Pointer(UIng::LibUI::TableValue) -> Void)
      @callback_data.set_cell_value = block
    end

    def to_unsafe
      # Return pointer to the handler structure
      pointerof(@handler)
    end

    # Clean up registry entry when handler is finalized
    def finalize
      handler_ptr = pointerof(@handler)
      @@handler_registry.delete(handler_ptr)
    end
  end
end
