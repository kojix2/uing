require "./selection/mode"

module UIng
  # Table::Selection represents selected rows in a Table.
  #
  # MEMORY MANAGEMENT:
  #
  # 1. Using on_selection_changed callback (RECOMMENDED):
  #   table.on_selection_changed do |selection|
  #     if selection.num_rows > 0
  #       selected_row = selection.rows.first
  #       # ... use selection data ...
  #     end
  #     # Table::Selection is automatically freed after this block
  #   end
  #
  # 2. Manual selection access:
  #   selection = table.selection  # Get selection
  #   rows = selection.rows        # Copy the selected rows
  #   # ... use selection data ...
  #   selection.free               # MUST free manually when using this pattern
  #
  # 3. Setting a custom Table::Selection object via `table.selection =`:
  #   You can create a Table::Selection manually using `Table::Selection.new(...)`
  #   and assign it to a table.
  #   These objects own a snapshot of the given rows and are managed by
  #   Crystal's garbage collector; do not call `free` on them.
  class Table < Control
    class Selection
      @rows : Array(Int32)?
      @cstruct : LibUI::TableSelection
      @released : Bool = false

      def initialize(@ptr : Pointer(LibUI::TableSelection))
        @rows = nil
        @cstruct = uninitialized LibUI::TableSelection
      end

      def initialize(rows : Array(Int32))
        owned_rows = rows.dup
        @rows = owned_rows
        @cstruct = LibUI::TableSelection.new
        @cstruct.rows = owned_rows.to_unsafe
        @cstruct.num_rows = owned_rows.size
        @ptr = pointerof(@cstruct)
      end

      def num_rows : Int32
        check_available
        @ptr.value.num_rows
      end

      def rows : Array(Int32)
        check_available
        rows_ptr = self.rows_ptr
        Array.new(num_rows) { |i| rows_ptr[i] }
      end

      def rows_ptr : Pointer(Int32)
        check_available
        @ptr.value.rows
      end

      def free : Nil
        return if @rows
        return if @released # Prevent double-free
        LibUI.free_table_selection(@ptr)
        @released = true
      end

      private def check_available : Nil
        raise "Table::Selection has already been released" if @released
      end

      def to_unsafe
        check_available
        @ptr
      end

      # Note: No finalize method needed for Table::Selection
    end
  end
end
