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
  # 3. Setting a custom TableSelection object via `table.selection =`:
  #   You can create a TableSelection manually using `TableSelection.new(...)`
  #   and assign it to a table.
  #   The data will be immediately copied or consumed by libui-ng,
  #   so the object does **not** need to be freed manually.
  #   Memory is automatically managed by Crystal's garbage collector.
  class TableSelection
    rows : Array(Int32)?
    property? freed : Bool = false

    def initialize(@ptr : Pointer(LibUI::TableSelection))
      @rows = nil
      @cstruct = nil
    end

    def initialize(rows : Array(Int32))
      # Create a new TableSelection with the given rows
      @rows = rows
      @cstruct = LibUI::TableSelection.new(@rows.to_unsafe, @rows.size)
      @ptr = Pointer(LibUI::TableSelection).new(@cstruct)
    end

    def num_rows : Int32
      @ptr.value.num_rows
    end

    def rows : Pointer(Int32)
      @ptr.value.rows
    end

    def free : Nil
      return if @rows
      return if @freed # Prevent double-free
      LibUI.free_table_selection(@ptr)
      @freed = true
    end

    def to_unsafe
      @ptr
    end

    # Note: No finalize method needed for TableSelection
  end
end
