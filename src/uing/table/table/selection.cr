require "./selection/mode"

module UIng
  class Table < Control
    # A Crystal-managed snapshot of selected row indices. Values returned by
    # Table#selection and on_selection_changed can be retained without freeing.
    class Selection
      @rows : Array(Int32)
      @cstruct : LibUI::TableSelection
      @ptr : Pointer(LibUI::TableSelection)

      protected def initialize(native_ptr : Pointer(LibUI::TableSelection))
        @rows = begin
          native_selection = native_ptr.value
          rows_ptr = native_selection.rows
          Array.new(native_selection.num_rows) { |index| rows_ptr[index] }
        ensure
          LibUI.free_table_selection(native_ptr)
        end
        @cstruct = LibUI::TableSelection.new
        @cstruct.rows = @rows.to_unsafe
        @cstruct.num_rows = @rows.size
        @ptr = pointerof(@cstruct)
      end

      def initialize(rows : Array(Int32))
        @rows = rows.dup
        @cstruct = LibUI::TableSelection.new
        @cstruct.rows = @rows.to_unsafe
        @cstruct.num_rows = @rows.size
        @ptr = pointerof(@cstruct)
      end

      def num_rows : Int32
        @ptr.value.num_rows
      end

      def rows : Array(Int32)
        @rows.dup
      end

      def rows_ptr : Pointer(Int32)
        @ptr.value.rows
      end

      def to_unsafe
        @ptr
      end
    end
  end
end
