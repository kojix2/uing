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
  class TableSelection
    property? managed_by_libui : Bool = false

    def initialize(@cstruct : LibUI::TableSelection = LibUI::TableSelection.new)
      @managed_by_libui = false # TableSelection created by ourselves
    end

    def initialize(ptr : Pointer(LibUI::TableSelection))
      @cstruct = ptr.value
      @managed_by_libui = true # TableSelection managed by LibUI - MUST be freed
    end

    def num_rows : Int32
      @cstruct.num_rows
    end

    def rows : Pointer(Int32)
      @cstruct.rows
    end

    def free : Nil
      return if @managed_by_libui # Don't free TableSelection managed by LibUI
      LibUI.free_table_selection(self.to_unsafe)
    end

    def to_unsafe
      pointerof(@cstruct)
    end

    # Note: No finalize method needed for TableSelection
    # According to libui-ng developers:
    # - TableSelection objects returned from libui-ng are managed internally
    # - Language bindings should treat these as "borrowed" references that don't need cleanup
    # - libui-ng uses strict ownership model where it manages TableSelection memory internally
    # - Adding finalize would cause double-free errors since libui-ng already manages the memory
  end
end
