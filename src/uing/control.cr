module UIng
  module Control
    def destroy
      LibUI.control_destroy(@ref_ptr)
    end

    def handle
      LibUI.control_handle(@ref_ptr)
    end

    def parent
      LibUI.control_parent(@ref_ptr)
    end

    def set_parent(parent)
      LibUI.control_set_parent(@ref_ptr, parent)
    end

    def parent=(parent)
      set_parent(parent)
    end

    def toplevel
      LibUI.control_toplevel(@ref_ptr)
    end

    def visible? : Bool
      LibUI.control_visible?(@ref_ptr) == 1
    end

    def show
      LibUI.control_show(@ref_ptr)
    end

    def hide
      LibUI.control_hide(@ref_ptr)
    end

    def enabled? : Bool
      LibUI.control_enabled?(@ref_ptr) == 1
    end

    def enable
      LibUI.control_enable(@ref_ptr)
    end

    def disable
      LibUI.control_disable(@ref_ptr)
    end
  end
end
