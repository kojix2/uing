module UIng
  class TableSelection
    property? managed_by_libui : Bool = false

    def initialize(@cstruct : LibUI::TableSelection = LibUI::TableSelection.new)
      @managed_by_libui = false  # TableSelection created by ourselves
    end

    def initialize(ptr : Pointer(LibUI::TableSelection))
      @cstruct = ptr.value
      @managed_by_libui = true  # TableSelection managed by LibUI
    end

    def num_rows : Int32
      @cstruct.num_rows
    end

    def rows : Pointer(Int32)
      @cstruct.rows
    end

    def free : Nil
      return if @managed_by_libui  # Don't free TableSelection managed by LibUI
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
