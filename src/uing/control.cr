module UIng
  module BlockConstructor
    macro block_constructor
      def self.new(*args, &block)
        instance = new(*args)
        with instance yield
        instance
      end

      def self.new(*args, **kwargs, &block)
        instance = new(*args, **kwargs)
        with instance yield
        instance
      end
    end
  end

  abstract class Control
    include BlockConstructor

    # Parent reference (for GC protection and tree uniqueness)
    # Use `__parent__` and `__set_parent__` if you need to access native functions for some reason
    protected property parent : Control? 

    def destroy : Nil
      LibUI.control_destroy(UIng.to_control(@ref_ptr))
    end

    def handle
      LibUI.control_handle(UIng.to_control(@ref_ptr))
    end

    # native libui function
    def __parent__
      LibUI.control_parent(UIng.to_control(@ref_ptr))
    end

    # native libui function
    # should not be used directly
    def __set_parent__(parent) : Nil
      LibUI.control_set_parent(UIng.to_control(@ref_ptr), UIng.to_control(parent))
    end

    def toplevel? : Bool
      LibUI.control_toplevel(UIng.to_control(@ref_ptr))
    end

    def visible? : Bool
      LibUI.control_visible(UIng.to_control(@ref_ptr))
    end

    def show : Nil
      LibUI.control_show(UIng.to_control(@ref_ptr))
    end

    def hide : Nil
      LibUI.control_hide(UIng.to_control(@ref_ptr))
    end

    def enabled? : Bool
      LibUI.control_enabled(UIng.to_control(@ref_ptr))
    end

    def enable : Nil
      LibUI.control_enable(UIng.to_control(@ref_ptr))
    end

    def disable : Nil
      LibUI.control_disable(UIng.to_control(@ref_ptr))
    end

    def enabled_to_user? : Bool
      LibUI.control_enabled_to_user(UIng.to_control(@ref_ptr))
    end

    def verify_set_parent(parent) : Nil
      LibUI.control_verify_set_parent(UIng.to_control(@ref_ptr), UIng.to_control(parent))
    end

    abstract def to_unsafe
  end
end
