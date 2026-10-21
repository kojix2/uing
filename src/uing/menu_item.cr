module UIng
  class MenuItem
    private enum Kind
      Regular
      Check
      Quit
      Preferences
      About
    end

    @released : Bool = false

    # Store callback box to prevent GC collection
    @on_clicked_box : Pointer(Void)?

    protected def initialize(@ref_ptr : Pointer(LibUI::MenuItem))
      @kind = Kind::Regular
    end

    private def initialize(@ref_ptr : Pointer(LibUI::MenuItem), @kind : Kind)
    end

    # :nodoc:
    protected def self.__new_for_menu__(ref_ptr : Pointer(LibUI::MenuItem), kind : Symbol) : MenuItem
      item_kind = case kind
                  when :regular     then Kind::Regular
                  when :check       then Kind::Check
                  when :quit        then Kind::Quit
                  when :preferences then Kind::Preferences
                  when :about       then Kind::About
                  else
                    raise ArgumentError.new("Unknown menu item kind: #{kind}")
                  end
      new(ref_ptr, item_kind)
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

    # Assigns a menu shortcut before the first Window is created.
    # Letters, digits, Delete, and arrow keys require Primary, Ctrl, or Alt.
    # F1 through F12 may be used without modifiers. ASCII lowercase letters
    # are converted to uppercase. libui-ng rejects duplicate shortcuts.
    def set_shortcut(key : Char, modifiers : Modifiers = Modifiers::None) : Nil
      check_available
      code = key.ord
      code -= 32 if 'a'.ord <= code <= 'z'.ord
      unless ('A'.ord <= code <= 'Z'.ord) || ('0'.ord <= code <= '9'.ord)
        raise ArgumentError.new("menu shortcut key must be an ASCII letter or digit")
      end
      set_validated_shortcut(code.to_u32, false, modifiers)
    end

    # Assigns a supported extended key as a menu shortcut.
    def set_shortcut(key : ExtKey, modifiers : Modifiers = Modifiers::None) : Nil
      check_available
      code = key.value
      is_function_key = ExtKey::F1.value <= code <= ExtKey::F12.value
      unless is_function_key || key == ExtKey::Delete ||
             (ExtKey::Up.value <= code <= ExtKey::Right.value)
        raise ArgumentError.new("unsupported extended menu shortcut key: #{key}")
      end
      set_validated_shortcut(code.to_u32, is_function_key, modifiers)
    end

    # Removes a menu shortcut before the first Window is created.
    def clear_shortcut : Nil
      check_available
      LibUI.menu_item_set_shortcut(@ref_ptr, 0_u32, Modifiers::None)
    end

    private def set_validated_shortcut(key_code : UInt32, function_key : Bool, modifiers : Modifiers) : Nil
      allowed = (Modifiers::Primary | Modifiers::Ctrl | Modifiers::Alt | Modifiers::Shift).value
      if (modifiers.value & ~allowed) != 0
        raise ArgumentError.new("menu shortcuts support only Primary, Ctrl, Alt, and Shift modifiers")
      end
      if modifiers.includes?(Modifiers::Primary) && modifiers.includes?(Modifiers::Ctrl)
        raise ArgumentError.new("Primary and Ctrl cannot be combined in a menu shortcut")
      end
      if !function_key && !(modifiers.includes?(Modifiers::Primary) ||
         modifiers.includes?(Modifiers::Ctrl) ||
         modifiers.includes?(Modifiers::Alt))
        raise ArgumentError.new("this menu shortcut key requires Primary, Ctrl, or Alt")
      end

      LibUI.menu_item_set_shortcut(@ref_ptr, key_code, modifiers)
    end

    def checked? : Bool
      check_available
      check_check_item
      LibUI.menu_item_checked(@ref_ptr) != 0
    end

    def checked=(checked : Bool) : Nil
      check_available
      check_check_item
      LibUI.menu_item_set_checked(@ref_ptr, checked ? 1 : 0)
    end

    def on_clicked(&block : UIng::Window? -> Nil) : Nil
      check_available
      if @kind.quit?
        raise ArgumentError.new("Quit menu items use UIng.on_should_quit and cannot have an on_clicked callback")
      end
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

    # Clears the click callback without removing or invalidating the menu item.
    # Equivalent to `on_clicked(nil)`.
    def clear_on_clicked : Nil
      check_available
      return if @kind.quit?
      clear_native_callback if @on_clicked_box
      @on_clicked_box = nil
    end

    def on_clicked(callback : Nil) : Nil
      clear_on_clicked
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
    protected def invalidate_after_uninit : Nil
      @on_clicked_box = nil
      @released = true
    end

    private def check_available : Nil
      raise "MenuItem has already been released" if @released
    end

    private def check_check_item : Nil
      return if @kind.check?
      raise ArgumentError.new("checked state is only available for check MenuItems")
    end
  end
end
