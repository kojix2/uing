module UIng
  # Convert control to Pointer(LibUI::Control)
  protected def self.to_control(control : Control)
    control.check_available
    control.to_unsafe.as(Pointer(LibUI::Control))
  end

  protected def self.to_control(control)
    if control.is_a?(Pointer)
      control.as(Pointer(LibUI::Control))
    else
      control.to_unsafe.as(Pointer(LibUI::Control))
    end
  end

  # Convert string pointer to Crystal string
  # and free the pointer
  protected def self.string_from_pointer(str_ptr) : String?
    return if str_ptr.null?
    str = String.new(str_ptr)
    LibUI.free_text(str_ptr)
    str
  end

  # Copy a NULL-terminated array of paths before releasing it with libui-ng.
  protected def self.strings_from_pointer(array_ptr : Pointer(Pointer(LibC::Char))) : Array(String)?
    return if array_ptr.null?

    begin
      paths = [] of String
      index = 0
      until (path_ptr = array_ptr[index]).null?
        paths << String.new(path_ptr)
        index += 1
      end
      paths
    ensure
      LibUI.free_text_array(array_ptr)
    end
  end

  # Init errors use libui-ng's dedicated deallocator rather than free_text.
  private def self.free_init_error(err) : Nil
    LibUI.free_init_error(err)
  end

  private def self.free_text(text) : Nil
    LibUI.free_text(text)
  end
end
