module UIng
  class Area
    include MethodMissing

    def initialize(@ref_ptr : Pointer(LibUI::Area))
    end

    def initialize(area_handler : Pointer(LibUI::AreaHandler))
      @ref_ptr = LibUI.new_area(area_handler)
    end

    def initialize(area_handler : AreaHandler)
      @ref_ptr = LibUI.new_area(area_handler.to_unsafe)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
