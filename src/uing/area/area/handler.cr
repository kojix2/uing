module UIng
  # Area::Handler provides callbacks for Area events with closure support.
  #
  # DESIGN PHILOSOPHY: UI Event Handling (Object-Oriented Approach)
  # - Callbacks receive Area parameter to enable direct UI manipulation
  # - Supports stateful operations like triggering redraws, cursor changes, etc.
  # - Emphasizes interactive UI patterns where callbacks modify UI state
  # - Area parameter enables fine-grained control over UI behavior
  #
  # CRITICAL MEMORY MANAGEMENT WARNINGS:
  # 1. Area::Handler MUST remain alive while Area exists
  # 2. Callbacks become invalid if handler is GC'd - causes crashes
  # 3. Use closures safely - they can capture external data and variables
  #
  # Closure-friendly callback pattern:
  #   handler = Area::Handler.new do
  #     draw { |area, params| puts "Drawing..." }
  #     mouse_event { |area, event| puts "Mouse event" }
  #     key_event { |area, event| true } # Return true if handled
  #   end
  class Area < Control
    class Handler
      include BlockConstructor; block_constructor

      # Store the extended handler structure and individual boxes for GC protection
      @extended_handler : LibUI::AreaHandlerExtended
      @draw_box : Pointer(Void)
      @mouse_event_box : Pointer(Void)
      @mouse_crossed_box : Pointer(Void)
      @drag_broken_box : Pointer(Void)
      @key_event_box : Pointer(Void)

      def initialize
        # Initialize instance variables
        @draw_box = Pointer(Void).null
        @mouse_event_box = Pointer(Void).null
        @mouse_crossed_box = Pointer(Void).null
        @drag_broken_box = Pointer(Void).null
        @key_event_box = Pointer(Void).null

        # Create extended handler with static callback functions
        @extended_handler = uninitialized LibUI::AreaHandlerExtended

        # Initialize the base handler with static callbacks
        @extended_handler.base_handler = LibUI::AreaHandler.new(
          draw: ->(ah : LibUI::AreaHandler*, area : LibUI::Area*, params : LibUI::AreaDrawParams*) {
            begin
              # Cast the handler pointer to our extended structure
              extended = ah.as(LibUI::AreaHandlerExtended*)
              if !extended.value.draw_box.null?
                callback = ::Box(Proc(Area, Area::DrawParams, Void)).unbox(extended.value.draw_box)
                # Create wrapper instances for type-safe access
                area_wrapper = Area.new(area)
                params_wrapper = Area::DrawParams.new(params)
                callback.call(area_wrapper, params_wrapper)
              end
            rescue e
              UIng.handle_callback_error(e, "Area draw")
            end
          },
          mouse_event: ->(ah : LibUI::AreaHandler*, area : LibUI::Area*, event : LibUI::AreaMouseEvent*) {
            begin
              extended = ah.as(LibUI::AreaHandlerExtended*)
              if !extended.value.mouse_event_box.null?
                callback = ::Box(Proc(Area, Area::MouseEvent, Void)).unbox(extended.value.mouse_event_box)
                # Create wrapper instances for type-safe access
                area_wrapper = Area.new(area)
                event_wrapper = Area::MouseEvent.new(event)
                callback.call(area_wrapper, event_wrapper)
              end
            rescue e
              UIng.handle_callback_error(e, "Area mouse_event")
            end
          },
          mouse_crossed: ->(ah : LibUI::AreaHandler*, area : LibUI::Area*, left : LibC::Int) {
            begin
              extended = ah.as(LibUI::AreaHandlerExtended*)
              if !extended.value.mouse_crossed_box.null?
                callback = ::Box(Proc(Area, Bool, Void)).unbox(extended.value.mouse_crossed_box)
                # Create wrapper instances for type-safe access
                area_wrapper = Area.new(area)
                left_bool = left != 0
                callback.call(area_wrapper, left_bool)
              end
            rescue e
              UIng.handle_callback_error(e, "Area mouse_crossed")
            end
          },
          drag_broken: ->(ah : LibUI::AreaHandler*, area : LibUI::Area*) {
            begin
              extended = ah.as(LibUI::AreaHandlerExtended*)
              if !extended.value.drag_broken_box.null?
                callback = ::Box(Proc(Area, Void)).unbox(extended.value.drag_broken_box)
                # Create wrapper instances for type-safe access
                area_wrapper = Area.new(area)
                callback.call(area_wrapper)
              end
            rescue e
              UIng.handle_callback_error(e, "Area drag_broken")
            end
          },
          key_event: ->(ah : LibUI::AreaHandler*, area : LibUI::Area*, event : LibUI::AreaKeyEvent*) : LibC::Int {
            begin
              extended = ah.as(LibUI::AreaHandlerExtended*)
              if !extended.value.key_event_box.null?
                callback = ::Box(Proc(Area, Area::KeyEvent, Bool)).unbox(extended.value.key_event_box)
                # Create wrapper instances for type-safe access
                area_wrapper = Area.new(area)
                event_wrapper = Area::KeyEvent.new(event)
                result = callback.call(area_wrapper, event_wrapper)
                result ? 1_i32 : 0_i32
              else
                0_i32
              end
            rescue e
              UIng.handle_callback_error(e, "Area key_event")
              0_i32
            end
          }
        )

        # Initialize the box pointers in the extended handler
        @extended_handler.draw_box = @draw_box
        @extended_handler.mouse_event_box = @mouse_event_box
        @extended_handler.mouse_crossed_box = @mouse_crossed_box
        @extended_handler.drag_broken_box = @drag_broken_box
        @extended_handler.key_event_box = @key_event_box
      end

      # Convenience methods for setting individual callbacks
      # Each method boxes the callback individually for type safety and efficiency

      def draw(&block : (Area, Area::DrawParams) -> Void)
        @draw_box = ::Box.box(block)
        @extended_handler.draw_box = @draw_box
      end

      def mouse_event(&block : (Area, Area::MouseEvent) -> Void)
        @mouse_event_box = ::Box.box(block)
        @extended_handler.mouse_event_box = @mouse_event_box
      end

      def mouse_crossed(&block : (Area, Bool) -> Void)
        @mouse_crossed_box = ::Box.box(block)
        @extended_handler.mouse_crossed_box = @mouse_crossed_box
      end

      def drag_broken(&block : (Area) -> Void)
        @drag_broken_box = ::Box.box(block)
        @extended_handler.drag_broken_box = @drag_broken_box
      end

      def key_event(&block : (Area, Area::KeyEvent) -> Bool)
        @key_event_box = ::Box.box(block)
        @extended_handler.key_event_box = @key_event_box
      end

      def to_unsafe
        # Return pointer to the extended handler, but cast to base handler type
        # This maintains the extended structure layout while providing C compatibility
        pointerof(@extended_handler).as(LibUI::AreaHandler*)
      end
    end
  end
end
