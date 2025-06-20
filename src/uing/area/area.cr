require "../control"
require "./area/*"
require "./area/draw/*"
require "./area/attribute/*"

module UIng
  class Area < Control
    block_constructor

    # Keep a reference to the Area::Handler to prevent GC
    @area_handler : Handler?

    def initialize(@ref_ptr : Pointer(LibUI::Area))
    end

    def initialize(area_handler : Handler)
      @area_handler = area_handler # Keep reference to prevent GC
      @ref_ptr = LibUI.new_area(area_handler.to_unsafe)
    end

    # scrolling area

    def initialize(area_handler : Pointer(LibUI::AreaHandler), width : Int32, height : Int32)
      @ref_ptr = LibUI.new_scrolling_area(area_handler, width, height)
    end

    def initialize(area_handler : Handler, width : Int32, height : Int32)
      @area_handler = area_handler # Keep reference to prevent GC
      @ref_ptr = LibUI.new_scrolling_area(area_handler.to_unsafe, width, height)
    end

    def set_size(width : Int32, height : Int32) : Nil
      LibUI.area_set_size(@ref_ptr, width, height)
    end

    def queue_redraw_all : Nil
      LibUI.area_queue_redraw_all(@ref_ptr)
    end

    def scroll_to(x : Float64, y : Float64, width : Float64, height : Float64) : Nil
      LibUI.area_scroll_to(@ref_ptr, x, y, width, height)
    end

    def begin_user_window_move : Nil
      LibUI.area_begin_user_window_move(@ref_ptr)
    end

    def begin_user_window_resize(edge : WindowResizeEdge) : Nil
      LibUI.area_begin_user_window_resize(@ref_ptr, edge)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
