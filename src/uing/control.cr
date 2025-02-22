module UIng
  module Control
    macro method_missing(call)
      {% if call.block %}
      def {{call.name}}(*args, **kwargs, &block : -> U) forall U
        UIng.{{ @type.name.split("::").last.underscore.id }}_{{call.name.id}}(@ref_ptr, *args, **kwargs, &block)
      end
      {% else %}
      def {{call.name}}(*args, **kwargs)
        UIng.{{ @type.name.split("::").last.underscore.id }}_{{call.name.id}}(@ref_ptr, *args, **kwargs)
      end
      {% end %}
    end

    def destroy
      UIng.control_destroy(@ref_ptr)
    end

    def handle
      UIng.control_handle(@ref_ptr)
    end

    def parent
      UIng.control_parent(@ref_ptr)
    end

    def set_parent(parent)
      UIng.control_set_parent(@ref_ptr, parent)
    end

    def parent=(parent)
      set_parent(parent)
    end

    def toplevel
      UIng.control_toplevel(@ref_ptr)
    end

    def visible? : Bool
      UIng.control_visible?(@ref_ptr) == 1
    end

    def show
      UIng.control_show(@ref_ptr)
    end

    def hide
      UIng.control_hide(@ref_ptr)
    end

    def enabled? : Bool
      UIng.control_enabled?(@ref_ptr) == 1
    end

    def enable
      UIng.control_enable(@ref_ptr)
    end

    def disable
      UIng.control_disable(@ref_ptr)
    end
  end
end
