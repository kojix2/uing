module UIng
  class MenuItem
    @released : Bool = false

    # Store callback box to prevent GC collection
    @on_clicked_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::MenuItem))
    end

    def destroy
      return if @released
      @on_clicked_box = nil
      @released = true
    end

    # no new_menu_item function in libui

    def enable : Nil
      LibUI.menu_item_enable(@ref_ptr)
    end

    def disable : Nil
      LibUI.menu_item_disable(@ref_ptr)
    end

    def checked? : Bool
      LibUI.menu_item_checked(@ref_ptr)
    end

    def checked=(checked : Bool) : Nil
      LibUI.menu_item_set_checked(@ref_ptr, checked)
    end

    def on_clicked(&block : UIng::Window -> _)
      # Convert to the internal callback format that matches LibUI expectation
      callback2 = ->(w : Pointer(LibUI::Window)) {
        block.call(UIng::Window.new(w))
      }
      @on_clicked_box = ::Box.box(callback2)
      if boxed_data = @on_clicked_box
        LibUI.menu_item_on_clicked(
          @ref_ptr,
          ->(_sender, window, data) {
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

    def to_unsafe
      @ref_ptr
    end
  end
end
