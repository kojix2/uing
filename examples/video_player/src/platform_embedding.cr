# Platform-specific embedding implementations for MPV player

module PlatformEmbedding
  # Common interface for all platforms
  abstract def setup_platform_embedding(raw_handle : UInt64)
  abstract def apply_platform_settings

  # macOS-specific embedding module
  module MacOS
    def setup_macos_embedding(raw_handle : UInt64)
      handle = raw_handle.to_i64

      set_window_id(handle)
      set_video_output("gpu")
      apply_platform_settings

      puts "Set macOS NSView handle: #{handle} with gpu mode"
    end

    def apply_macos_settings
      set_property("hwdec", "auto")
      set_property("fullscreen", "no")
    end
  end

  # Windows-specific embedding module
  module Windows
    def setup_windows_embedding(raw_handle : UInt64)
      handle = raw_handle.to_i64
      set_window_id(handle)
      set_video_output("direct3d")
      apply_platform_settings
      puts "Set Windows HWND handle: #{handle} with direct3d mode"
    end

    def apply_windows_settings
      set_property("hwdec", "auto")
      set_property("fullscreen", "no")
      set_property("d3d11-adapter", "auto")
    end
  end

  # Linux-specific embedding module
  module Linux
    def setup_linux_embedding(raw_handle : UInt64)
      widget = Pointer(Void).new(raw_handle).as(LibGTK::GtkWidget)
      LibGTK.gtk_widget_realize(widget)
      gdk_window = LibGTK.gtk_widget_get_window(widget)

      type_name_ptr = LibGTK.g_type_name_from_instance(gdk_window.as(LibGTK::GTypeInstance))
      type_name = String.new(type_name_ptr)
      puts "Window type: #{type_name}"

      case type_name
      when "GdkX11Window"
        setup_x11_window(gdk_window)
      else
        raise "Unsupported window type: #{type_name}"
      end
    end

    def setup_x11_window(gdk_window)
      x11_window_id = LibGDK.gdk_x11_window_get_xid(gdk_window)
      handle = x11_window_id.to_i64

      set_video_output("x11")
      set_window_id(handle)

      puts "Set X11 window ID: #{handle}"
    end

    def apply_linux_settings
      # Linux-specific settings can be added here
    end
  end
end
