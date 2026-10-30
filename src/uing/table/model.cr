require "./model/handler"

module UIng
  # Table::Model manages data for Table controls.
  #
  # CRITICAL MEMORY MANAGEMENT WARNINGS:
  # 1. Table::Model MUST be freed AFTER all Tables using it are destroyed
  # 2. Table::Model::Handler callbacks become invalid after Table::Model is freed
  # 3. DO NOT rely on GC/finalize for automatic cleanup - use explicit free()
  # 4. Avoid circular references in Table::Model::Handler callbacks
  #
  # Safe usage pattern:
  #   model_handler = Table::Model::Handler.new
  #   model = Table::Model.new(model_handler)
  #   table = Table.new(model)
  #   # ... use table ...
  #   table.destroy  # Destroy table first
  #   model.free     # Then free model
  class Table < Control
    class Model
      @free_requested : Bool = false
      @native_freed : Bool = false
      @tables = Set(Table).new
      @column_types : Array(Value::Type)?

      # Store Table::Model::Handler reference to prevent GC collection
      # IMPORTANT: This prevents GC of handler while model is alive
      @model_handler_ref : Handler?

      protected def initialize(@ref_ptr : Pointer(LibUI::TableModel))
        @column_types = nil
      end

      # Wraps a native model without a Crystal-side schema. Table column
      # validation is intentionally unavailable for models created this way.
      def self.unsafe_wrap(ref_ptr : Pointer(LibUI::TableModel)) : Model
        new(ref_ptr)
      end

      def initialize(model_handler : Handler)
        handler_ptr = model_handler.to_unsafe
        @column_types = model_handler.sealed_column_types
        @ref_ptr = LibUI.new_table_model(handler_ptr)
        @model_handler_ref = model_handler
      end

      # Explicitly free the Table::Model.
      # Tables may be DestroyPending; libui-ng defers the native model free until
      # those table destructions have completed. An Alive Table still rejects it.
      def free : Nil
        return if @free_requested
        if @tables.any? { |table| !table.released? }
          raise "Table::Model cannot be freed while it is still used by a Table"
        end
        @free_requested = true
        finish_free if @tables.empty?
      end

      # Internal lifetime bookkeeping used by Table. Keeping the wrappers here
      # also prevents a live native Table from outliving its Crystal wrapper.
      protected def register(table : Table) : Nil
        check_available
        @tables.add(table)
      end

      protected def unregister(table : Table) : Nil
        @tables.delete(table)
        finish_free if @free_requested && @tables.empty?
      end

      protected def free_native : Nil
        LibUI.free_table_model(@ref_ptr)
      end

      protected def validate_data_column(column : Int32, expected_type : Value::Type, role : String) : Nil
        validate_column(column, expected_type, role)
      end

      protected def validate_state_column(column : Int32, role : String) : Nil
        return if column == ModelColumn::Never.value || column == ModelColumn::Always.value
        validate_column(column, Value::Type::Int, role)
      end

      protected def validate_optional_color_column(column : Int32, role : String) : Nil
        return if column == -1
        validate_column(column, Value::Type::Color, role)
      end

      private def check_available : Nil
        raise "Table::Model has already been released" if @free_requested
      end

      private def finish_free : Nil
        return if @native_freed
        free_native
        @native_freed = true
        @model_handler_ref = nil
      end

      private def validate_column(column : Int32, expected_type : Value::Type, role : String) : Nil
        column_types = @column_types || return
        unless 0 <= column < column_types.size
          raise ArgumentError.new("#{role} model column #{column} is out of range for #{column_types.size} columns")
        end

        actual_type = column_types[column]
        return if actual_type == expected_type
        raise ArgumentError.new("#{role} model column #{column} type mismatch: expected #{expected_type}, got #{actual_type}")
      end

      def row_inserted(new_index : Int32) : Nil
        check_available
        LibUI.table_model_row_inserted(@ref_ptr, new_index)
      end

      def row_changed(index : Int32) : Nil
        check_available
        LibUI.table_model_row_changed(@ref_ptr, index)
      end

      def row_deleted(old_index : Int32) : Nil
        check_available
        LibUI.table_model_row_deleted(@ref_ptr, old_index)
      end

      def to_unsafe
        check_available
        @ref_ptr
      end
    end
  end
end
