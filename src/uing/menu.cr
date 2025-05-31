module UIng
  class Menu
    include MethodMissing; block_constructor

    def initialize(@ref_ptr : Pointer(LibUI::Menu))
    end

    def initialize(name : String)
      @ref_ptr = LibUI.new_menu(name)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
