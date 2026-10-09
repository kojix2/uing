require "../control"
require "./area/*"
require "./area/draw/*"
require "./area/attribute/*"

module UIng
  class Area < Control
    block_constructor

    @borrowed : Bool = false

    # Keep a reference to the Area::Handler to prevent GC
    @area_handler : Handler?

    protected def initialize(@ref_ptr : Pointer(LibUI::Area), borrowed : Bool = true)
      @borrowed = borrowed
      register_control
    end

    def destroy : Nil
      return if @borrowed
      super
    end

    def initialize(area_handler : Handler)
      @area_handler = area_handler # Keep reference to prevent GC
      @ref_ptr = LibUI.new_area(area_handler.to_unsafe)
      register_control
    end

    # scrolling area

    def initialize(area_handler : Handler, width : Int32, height : Int32)
      @area_handler = area_handler # Keep reference to prevent GC
      @ref_ptr = LibUI.new_scrolling_area(area_handler.to_unsafe, width, height)
      register_control
    end

    protected def after_destroy : Nil
      @area_handler = nil
    end

    def set_size(width : Int32, height : Int32) : Nil
      LibUI.area_set_size(ref_ptr, width, height)
    end

    def queue_redraw_all : Nil
      LibUI.area_queue_redraw_all(ref_ptr)
    end

    def scroll_to(x : Number, y : Number, width : Number, height : Number) : Nil
      scroll_x = NumericValue.finite(x, "area scroll x")
      scroll_y = NumericValue.finite(y, "area scroll y")
      scroll_width = NumericValue.finite(width, "area scroll width")
      scroll_height = NumericValue.finite(height, "area scroll height")
      LibUI.area_scroll_to(ref_ptr, scroll_x, scroll_y, scroll_width, scroll_height)
    end

    def begin_user_window_move : Nil
      LibUI.area_begin_user_window_move(ref_ptr)
    end

    def begin_user_window_resize(edge : WindowResizeEdge) : Nil
      LibUI.area_begin_user_window_resize(ref_ptr, edge)
    end

    def to_unsafe
      ref_ptr
    end
  end
end
