module UIng
  class MenuItem
    @released : Bool = false

    # Store callback box to prevent GC collection
    @on_clicked_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::MenuItem))
    end

    def destroy
      return if @released
      clear_native_callback
      @on_clicked_box = nil
      @released = true
    end

    private def clear_native_callback : Nil
      LibUI.menu_item_on_clicked(
        @ref_ptr,
        ->(_sender, _window, _data) : Nil { },
        Pointer(Void).null
      )
    end

    # no new_menu_item function in libui

    def enable : Nil
      check_available
      LibUI.menu_item_enable(@ref_ptr)
    end

    def disable : Nil
      check_available
      LibUI.menu_item_disable(@ref_ptr)
    end

    def checked? : Bool
      check_available
      LibUI.menu_item_checked(@ref_ptr)
    end

    def checked=(checked : Bool) : Nil
      check_available
      LibUI.menu_item_set_checked(@ref_ptr, checked)
    end

    def on_clicked(&block : UIng::Window? -> Nil) : Nil
      check_available
      # Convert to the internal callback format that matches LibUI expectation
      callback2 = ->(w : Pointer(LibUI::Window)) : Nil {
        block.call(window_from_native(w))
      }
      @on_clicked_box = ::Box.box(callback2)
      if boxed_data = @on_clicked_box
        LibUI.menu_item_on_clicked(
          @ref_ptr,
          ->(_sender, window, data) : Nil {
            begin
              data_as_callback = ::Box(typeof(callback2)).unbox(data)
              data_as_callback.call(window)
            rescue e
              UIng.handle_callback_error(e, "MenuItem on_clicked")
            end
          },
          boxed_data
        )
      end
    end

    private def window_from_native(window : Pointer(LibUI::Window)) : Window?
      return if window.null?
      ControlRegistry.lookup(window).as?(Window) || Window.new(window, borrowed: true)
    end

    def to_unsafe
      check_available
      @ref_ptr
    end

    # Marks an item invalid after libui-ng has released all menus in uiUninit().
    # This must not call back into native code because the pointer is already dead.
    # :nodoc:
    def invalidate_after_uninit : Nil
      @on_clicked_box = nil
      @released = true
    end

    private def check_available : Nil
      raise "MenuItem has already been released" if @released
    end
  end
end
