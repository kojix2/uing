module UIng
  class Area < Control
    # Drawing and input callbacks with closure support.
    # Area retains the Handler and its Procs; native UserData points back to it.
    # Keep captured native resources unfreed while callbacks use them.
    # Direct LibUI callers must retain the Handler themselves.
    #
    #   handler = Area::Handler.new do
    #     draw { |area, params| puts "Drawing..." }
    #     key_event { |area, event| true } # Return true if handled
    #   end
    class Handler
      include BlockConstructor; block_constructor

      @native = LibUI::AreaHandler.new
      protected getter draw_callback : Proc(Area, Area::Draw::Params, Nil)?
      protected getter mouse_event_callback : Proc(Area, Area::MouseEvent, Nil)?
      protected getter mouse_crossed_callback : Proc(Area, Bool, Nil)?
      protected getter drag_broken_callback : Proc(Area, Nil)?
      protected getter key_event_callback : Proc(Area, Area::KeyEvent, Bool)?
      protected getter scroll_event_callback : Proc(Area, Area::ScrollEvent, Bool)?

      SCROLL_CALLBACK = ->(ah : LibUI::AreaHandler*, area : LibUI::Area*, event : LibUI::AreaScrollEvent*) : LibC::Int {
        begin
          handler = ::Box(Handler).unbox(ah.value.user_data)
          callback = handler.scroll_event_callback || return 0_i32
          area_wrapper = ControlRegistry.lookup(area).as?(Area) || Area.new(area, borrowed: true)
          callback.call(area_wrapper, Area::ScrollEvent.new(event)) ? 1_i32 : 0_i32
        rescue e
          UIng.handle_callback_error(e, "Area scroll_event")
          0_i32
        end
      }

      # ameba:disable Metrics/CyclomaticComplexity
      def initialize
        @native = LibUI::AreaHandler.new(
          draw: ->(ah : LibUI::AreaHandler*, area : LibUI::Area*, params : LibUI::AreaDrawParams*) {
            begin
              handler = ::Box(Handler).unbox(ah.value.user_data)
              if callback = handler.draw_callback
                # Create wrapper instances for type-safe access
                area_wrapper = ControlRegistry.lookup(area).as?(Area) || Area.new(area, borrowed: true)
                params_wrapper = Area::Draw::Params.borrowed(params)
                begin
                  callback.call(area_wrapper, params_wrapper)
                ensure
                  params_wrapper.invalidate_borrow
                end
              end
            rescue e
              UIng.handle_callback_error(e, "Area draw")
            end
          },
          mouse_event: ->(ah : LibUI::AreaHandler*, area : LibUI::Area*, event : LibUI::AreaMouseEvent*) {
            begin
              handler = ::Box(Handler).unbox(ah.value.user_data)
              if callback = handler.mouse_event_callback
                # Create wrapper instances for type-safe access
                area_wrapper = ControlRegistry.lookup(area).as?(Area) || Area.new(area, borrowed: true)
                event_wrapper = Area::MouseEvent.new(event)
                callback.call(area_wrapper, event_wrapper)
              end
            rescue e
              UIng.handle_callback_error(e, "Area mouse_event")
            end
          },
          mouse_crossed: ->(ah : LibUI::AreaHandler*, area : LibUI::Area*, left : LibC::Int) {
            begin
              handler = ::Box(Handler).unbox(ah.value.user_data)
              if callback = handler.mouse_crossed_callback
                # Create wrapper instances for type-safe access
                area_wrapper = ControlRegistry.lookup(area).as?(Area) || Area.new(area, borrowed: true)
                left_bool = left != 0
                callback.call(area_wrapper, left_bool)
              end
            rescue e
              UIng.handle_callback_error(e, "Area mouse_crossed")
            end
          },
          drag_broken: ->(ah : LibUI::AreaHandler*, area : LibUI::Area*) {
            begin
              handler = ::Box(Handler).unbox(ah.value.user_data)
              if callback = handler.drag_broken_callback
                # Create wrapper instances for type-safe access
                area_wrapper = ControlRegistry.lookup(area).as?(Area) || Area.new(area, borrowed: true)
                callback.call(area_wrapper)
              end
            rescue e
              UIng.handle_callback_error(e, "Area drag_broken")
            end
          },
          key_event: ->(ah : LibUI::AreaHandler*, area : LibUI::Area*, event : LibUI::AreaKeyEvent*) : LibC::Int {
            begin
              handler = ::Box(Handler).unbox(ah.value.user_data)
              if callback = handler.key_event_callback
                # Create wrapper instances for type-safe access
                area_wrapper = ControlRegistry.lookup(area).as?(Area) || Area.new(area, borrowed: true)
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
          },
          scroll_event: nil,
          user_data: ::Box.box(self)
        )
      end

      # ameba:enable Metrics/CyclomaticComplexity

      # Convenience methods for setting individual callbacks

      def draw(&block : (Area, Area::Draw::Params) -> Nil)
        @draw_callback = block
      end

      def clear_draw : Nil
        @draw_callback = nil
      end

      def draw(callback : Nil) : Nil
        clear_draw
      end

      def mouse_event(&block : (Area, Area::MouseEvent) -> Nil)
        @mouse_event_callback = block
      end

      def clear_mouse_event : Nil
        @mouse_event_callback = nil
      end

      def mouse_event(callback : Nil) : Nil
        clear_mouse_event
      end

      def mouse_crossed(&block : (Area, Bool) -> Nil)
        @mouse_crossed_callback = block
      end

      def clear_mouse_crossed : Nil
        @mouse_crossed_callback = nil
      end

      def mouse_crossed(callback : Nil) : Nil
        clear_mouse_crossed
      end

      def drag_broken(&block : (Area) -> Nil)
        @drag_broken_callback = block
      end

      def clear_drag_broken : Nil
        @drag_broken_callback = nil
      end

      def drag_broken(callback : Nil) : Nil
        clear_drag_broken
      end

      def key_event(&block : (Area, Area::KeyEvent) -> Bool)
        @key_event_callback = block
      end

      def clear_key_event : Nil
        @key_event_callback = nil
      end

      def key_event(callback : Nil) : Nil
        clear_key_event
      end

      # Receives wheel and trackpad movement. Return true to consume it, or
      # false to allow a scrolling Area to scroll normally.
      def scroll_event(&block : (Area, Area::ScrollEvent) -> Bool)
        @scroll_event_callback = block
        @native.scroll_event = SCROLL_CALLBACK
      end

      def clear_scroll_event : Nil
        @native.scroll_event = nil
        @scroll_event_callback = nil
      end

      def scroll_event(callback : Nil) : Nil
        clear_scroll_event
      end

      def to_unsafe
        pointerof(@native)
      end
    end
  end
end
