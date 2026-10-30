module UIng
  class Table < Control
    class Model
      # Table model callbacks with closure support.
      # Model retains the Handler and its Procs; native UserData points back to it.
      # Direct LibUI callers must retain the Handler themselves.
      #
      # Column count and types are sealed when first passed to libui-ng.
      # cell_value returns a new owned Value (or nil where allowed), transferred
      # to libui-ng. set_cell_value receives a borrowed Value?, valid only during
      # that callback. Keep captured native resources unfreed while used.
      class Handler
        include BlockConstructor; block_constructor

        @native = LibUI::TableModelHandler.new
        @num_columns_callback : Proc(Int32)?
        @column_type_callback : Proc(LibC::Int, Value::Type)?
        @column_types : Array(Value::Type)?
        protected getter num_rows_callback : Proc(Int32)?
        protected getter cell_value_callback : Proc(LibC::Int, LibC::Int, Value?)?
        protected getter set_cell_value_callback : Proc(LibC::Int, LibC::Int, Value?, Nil)?

        # Ameba counts branches inside the C callback closures as branches of
        # this initializer even though each closure is an independent handler.
        # ameba:disable Metrics/CyclomaticComplexity
        def initialize
          @native = LibUI::TableModelHandler.new(
            num_columns: ->(mh : LibUI::TableModelHandler*, _m : LibUI::TableModel*) {
              begin
                handler = ::Box(Handler).unbox(mh.value.user_data)
                handler.sealed_column_types.size
              rescue e
                UIng.handle_callback_error(e, "Table::Model::Handler num_columns")
                0_i32
              end
            },
            column_type: ->(mh : LibUI::TableModelHandler*, _m : LibUI::TableModel*, column : LibC::Int) {
              begin
                handler = ::Box(Handler).unbox(mh.value.user_data)
                column_types = handler.sealed_column_types
                if column >= 0 && column < column_types.size
                  column_types[column]
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
                handler = ::Box(Handler).unbox(mh.value.user_data)
                if callback = handler.num_rows_callback
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
            # This callback must select a type-correct fallback without allowing
            # exceptions to cross the C boundary.
            # ameba:disable Metrics/CyclomaticComplexity
            cell_value: ->(mh : LibUI::TableModelHandler*, _model : LibUI::TableModel*, row : LibC::Int, column : LibC::Int) {
              handler = ::Box(Handler).unbox(mh.value.user_data)
              column_types = handler.sealed_column_types
              expected_type = if column >= 0 && column < column_types.size
                                column_types[column]
                              else
                                Value::Type::String
                              end

              value_ptr = begin
                if callback = handler.cell_value_callback
                  if result = callback.call(row, column)
                    actual_type = result.type
                    if actual_type != expected_type
                      result.free
                      raise "Table cell value type mismatch for column #{column}: expected #{expected_type}, got #{actual_type}"
                    end
                    result.transfer_to_libui
                  elsif expected_type.color?
                    Pointer(LibUI::TableValue).null
                  else
                    raise "Table cell value for column #{column} cannot be nil for type #{expected_type}"
                  end
                end
              rescue e
                UIng.handle_callback_error(e, "Table::Model::Handler cell_value")
                nil
              end

              if value_ptr
                value_ptr
              else
                case expected_type
                when .string? then LibUI.new_table_value_string("")
                when .image?  then LibUI.new_table_value_image(Pointer(LibUI::Image).null)
                when .int?    then LibUI.new_table_value_int(0)
                when .color?  then Pointer(LibUI::TableValue).null
                else               Pointer(LibUI::TableValue).null
                end
              end
            },
            set_cell_value: ->(mh : LibUI::TableModelHandler*, _m : LibUI::TableModel*, row : LibC::Int, column : LibC::Int, value : Pointer(UIng::LibUI::TableValue)) {
              begin
                handler = ::Box(Handler).unbox(mh.value.user_data)
                if callback = handler.set_cell_value_callback
                  table_value = value.null? ? nil : Value.borrowed(value)
                  begin
                    callback.call(row, column, table_value)
                  ensure
                    table_value.try &.invalidate_borrow
                  end
                end
              rescue e
                UIng.handle_callback_error(e, "Table::Model::Handler set_cell_value")
              end
            },
            user_data: ::Box.box(self)
          )
        end

        # ameba:enable Metrics/CyclomaticComplexity

        # Convenience methods for setting individual callbacks

        def num_columns(&block : -> Int32)
          raise "Cannot change table schema after it has been sealed" if @column_types
          @num_columns_callback = block
        end

        def column_type(&block : LibC::Int -> Value::Type)
          raise "Cannot change table schema after it has been sealed" if @column_types
          @column_type_callback = block
        end

        def num_rows(&block : -> Int32)
          @num_rows_callback = block
        end

        def cell_value(&block : LibC::Int, LibC::Int -> Value?)
          @cell_value_callback = block
        end

        def set_cell_value(&block : LibC::Int, LibC::Int, Value? -> Nil)
          @set_cell_value_callback = block
        end

        # Removes the optional edit/click callback; equivalent to `set_cell_value(nil)`.
        def clear_set_cell_value : Nil
          @set_cell_value_callback = nil
        end

        def set_cell_value(callback : Nil) : Nil
          clear_set_cell_value
        end

        def to_unsafe
          seal_schema
          pointerof(@native)
        end

        protected def sealed_column_types : Array(Value::Type)
          seal_schema
        end

        private def seal_schema : Array(Value::Type)
          column_types = @column_types
          return column_types unless column_types.nil?

          num_columns = @num_columns_callback.try(&.call) || 0
          raise ArgumentError.new("Table model column count cannot be negative") if num_columns < 0

          column_types = Array(Value::Type).new(num_columns) do |column|
            @column_type_callback.try(&.call(column)) || Value::Type::String
          end
          @column_types = column_types

          column_types
        end
      end
    end
  end
end
