module UIng
  # TableSelection represents selected rows in a Table.
  #
  # AUTOMATIC MEMORY MANAGEMENT:
  # TableSelection is automatically managed by the UIng library.
  # Users do NOT need to manually free TableSelection objects.
  #
  # Recommended usage patterns:
  #
  # 1. Using on_selection_changed callback (RECOMMENDED):
  #   table.on_selection_changed do |selection|
  #     if selection.num_rows > 0
  #       selected_row = selection.rows[0]
  #       # ... use selection data ...
  #     end
  #     # TableSelection is automatically freed after this block
  #   end
  #
  # 2. Manual selection access (use with caution):
  #   selection = table.selection  # Get selection
  #   rows = selection.num_rows    # Extract data immediately
  #   # ... use selection data ...
  #   selection.free               # MUST free manually when using this pattern
  #
  # IMPORTANT NOTES:
  # - Users should NOT create TableSelection instances directly
  # - TableSelection objects are only created by libui-ng and returned from Table methods
  # - When using table.selection directly, you MUST call free() after use
  # - The on_selection_changed callback automatically handles memory management
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
