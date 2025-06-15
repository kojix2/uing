module UIng
  # TableModel manages data for Table controls.
  #
  # CRITICAL MEMORY MANAGEMENT WARNINGS:
  # 1. TableModel MUST be freed AFTER all Tables using it are destroyed
  # 2. TableModelHandler callbacks become invalid after TableModel is freed
  # 3. DO NOT rely on GC/finalize for automatic cleanup - use explicit free()
  # 4. Avoid circular references in TableModelHandler callbacks
  #
  # Safe usage pattern:
  #   model_handler = TableModelHandler.new
  #   model = TableModel.new(model_handler)
  #   table = Table.new(TableParams.new(model))
  #   # ... use table ...
  #   table.destroy  # Destroy table first
  #   model.free     # Then free model
  class TableModel
    property? released : Bool = false

    # Store TableModelHandler reference to prevent GC collection
    # IMPORTANT: This prevents GC of handler while model is alive
    @model_handler_ref : TableModelHandler?

    def initialize(@ref_ptr : Pointer(LibUI::TableModel))
    end

    def initialize(model_handler : TableModelHandler)
      @ref_ptr = LibUI.new_table_model(model_handler)
      @model_handler_ref = model_handler
    end

    # Explicitly free the TableModel.
    # WARNING: Only call this AFTER all Tables using this model are destroyed.
    # Calling this while Tables are still active will cause crashes.
    def free : Nil
      return if @released
      LibUI.free_table_model(@ref_ptr)
      @released = true
      # Clear handler reference to allow GC
      @model_handler_ref = nil
    end

    def row_inserted(new_index : Int32) : Nil
      LibUI.table_model_row_inserted(@ref_ptr, new_index)
    end

    def row_changed(index : Int32) : Nil
      LibUI.table_model_row_changed(@ref_ptr, index)
    end

    def row_deleted(old_index : Int32) : Nil
      LibUI.table_model_row_deleted(@ref_ptr, old_index)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
