module UIng
  # TableSelection represents selected rows in a Table.
  #
  # CRITICAL MEMORY MANAGEMENT WARNINGS:
  # 1. TableSelection returned from Table methods MUST be freed after use
  # 2. DO NOT store TableSelection references long-term - use immediately and free
  # 3. Double-free causes crashes - only free once
  # 4. TableSelection is "disposable" - get data, use it, free it immediately
  #
  # Safe usage pattern:
  #   selection = table.selection  # Get selection
  #   rows = selection.num_rows    # Extract data immediately
  #   # ... use rows data ...
  #   selection.free               # Free immediately after use
  #
  # NOTE: Users should NOT create TableSelection instances directly.
  # TableSelection objects are only created by libui-ng and returned from Table methods.
  class TableSelection
    property? freed : Bool = false

    # Internal constructor - only used by libui-ng bindings
    # Users should NOT call this directly
    protected def initialize(@ptr : Pointer(LibUI::TableSelection))
    end

    def num_rows : Int32
      @ptr.value.num_rows
    end

    def rows : Pointer(Int32)
      @ptr.value.rows
    end

    def free : Nil
      return if @freed # Prevent double-free
      # TableSelection returned from libui-ng MUST be freed by caller
      # This is different from other libui-ng objects
      LibUI.free_table_selection(@ptr)
      @freed = true
    end

    def to_unsafe
      @ptr
    end

    # Note: No finalize method needed for TableSelection
    # According to libui-ng developers:
    # - TableSelection objects returned from libui-ng are managed internally
    # - Language bindings should treat these as "borrowed" references that don't need cleanup
    # - libui-ng uses strict ownership model where it manages TableSelection memory internally
    # - Adding finalize would cause double-free errors since libui-ng already manages the memory
  end
end
