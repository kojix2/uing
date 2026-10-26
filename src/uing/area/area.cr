require "../control"
require "./area/*"
require "./area/draw/*"
require "./area/attribute/*"

module UIng
  class Area < Control
    block_constructor

    @borrowed : Bool = false
    @scrolling : Bool = false
    @owns_handler : Bool = false

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

    # Creates an Area with its own handler for per-Area event callbacks.
    @[Experimental]
    def initialize
      area_handler = Handler.new
      @area_handler = area_handler
      @owns_handler = true
      @ref_ptr = LibUI.new_area(area_handler.to_unsafe)
      register_control
    end

    def initialize(area_handler : Handler)
      @area_handler = area_handler # Keep reference to prevent GC
      @ref_ptr = LibUI.new_area(area_handler.to_unsafe)
      register_control
    end

    # scrolling area

    # Creates a scrolling Area with its own handler.
    @[Experimental]
    def initialize(width : Int32, height : Int32)
      area_handler = Handler.new
      @area_handler = area_handler
      @owns_handler = true
      @ref_ptr = LibUI.new_scrolling_area(area_handler.to_unsafe, width, height)
      @scrolling = true
      register_control
    end

    def initialize(area_handler : Handler, width : Int32, height : Int32)
      @area_handler = area_handler # Keep reference to prevent GC
      @ref_ptr = LibUI.new_scrolling_area(area_handler.to_unsafe, width, height)
      @scrolling = true
      register_control
    end

    protected def after_destroy : Nil
      @area_handler = nil
    end

    # Registers a draw callback for an Area created without an explicit handler.
    @[Experimental]
    def on_draw(&block : Draw::Params -> Nil) : Nil
      owned_handler("on_draw").draw { |_area, params| block.call(params) }
    end

    @[Experimental]
    def clear_on_draw : Nil
      owned_handler("clear_on_draw").clear_draw
    end

    @[Experimental]
    def on_draw(callback : Nil) : Nil
      clear_on_draw
    end

    @[Experimental]
    def on_mouse_event(&block : MouseEvent -> Nil) : Nil
      owned_handler("on_mouse_event").mouse_event { |_area, event| block.call(event) }
    end

    @[Experimental]
    def clear_on_mouse_event : Nil
      owned_handler("clear_on_mouse_event").clear_mouse_event
    end

    @[Experimental]
    def on_mouse_event(callback : Nil) : Nil
      clear_on_mouse_event
    end

    @[Experimental]
    def on_mouse_crossed(&block : Bool -> Nil) : Nil
      owned_handler("on_mouse_crossed").mouse_crossed { |_area, left| block.call(left) }
    end

    @[Experimental]
    def clear_on_mouse_crossed : Nil
      owned_handler("clear_on_mouse_crossed").clear_mouse_crossed
    end

    @[Experimental]
    def on_mouse_crossed(callback : Nil) : Nil
      clear_on_mouse_crossed
    end

    @[Experimental]
    def on_drag_broken(&block : -> Nil) : Nil
      owned_handler("on_drag_broken").drag_broken { |_area| block.call }
    end

    @[Experimental]
    def clear_on_drag_broken : Nil
      owned_handler("clear_on_drag_broken").clear_drag_broken
    end

    @[Experimental]
    def on_drag_broken(callback : Nil) : Nil
      clear_on_drag_broken
    end

    @[Experimental]
    def on_key_event(&block : KeyEvent -> Bool) : Nil
      owned_handler("on_key_event").key_event { |_area, event| block.call(event) }
    end

    @[Experimental]
    def clear_on_key_event : Nil
      owned_handler("clear_on_key_event").clear_key_event
    end

    @[Experimental]
    def on_key_event(callback : Nil) : Nil
      clear_on_key_event
    end

    @[Experimental]
    def on_scroll_event(&block : ScrollEvent -> Bool) : Nil
      owned_handler("on_scroll_event").scroll_event { |_area, event| block.call(event) }
    end

    @[Experimental]
    def clear_on_scroll_event : Nil
      owned_handler("clear_on_scroll_event").clear_scroll_event
    end

    @[Experimental]
    def on_scroll_event(callback : Nil) : Nil
      clear_on_scroll_event
    end

    # Changes the content size of a scrolling Area.
    def set_size(width : Int32, height : Int32) : Nil
      require_scrolling("set_size")
      LibUI.area_set_size(ref_ptr, width, height)
    end

    def queue_redraw_all : Nil
      LibUI.area_queue_redraw_all(ref_ptr)
    end

    # Scrolls a scrolling Area to make the given rectangle visible.
    def scroll_to(x : Number, y : Number, width : Number, height : Number) : Nil
      require_scrolling("scroll_to")
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

    private def require_scrolling(method : String) : Nil
      check_available
      raise ArgumentError.new("Area##{method} requires a scrolling Area") unless @scrolling
    end

    private def owned_handler(method : String) : Handler
      check_available
      raise ArgumentError.new("Area##{method} requires an Area created without an explicit Handler") unless @owns_handler
      @area_handler.not_nil!
    end
  end
end
