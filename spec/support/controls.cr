require "../spec_helper"

module UIng
  def self.registered_control_for_spec(ptr : Pointer(T)) : Control? forall T
    ControlRegistry.lookup(ptr)
  end

  def self.native_control_destroyed_for_spec(ptr : Pointer(T)) : Nil forall T
    ControlRegistry.native_destroyed(ptr)
  end
end

module SpecSupport
  class LifetimeControl < UIng::Control
    @ref_ptr : Pointer(UIng::LibUI::Button)

    getter? cleaned_up = false

    def initialize(address : UInt64 = 0_u64, register : Bool = false)
      @ref_ptr = Pointer(UIng::LibUI::Button).new(address)
      register_control(install_destroy_callback: false) if register
    end

    def adopt(parent : UIng::Control) : Nil
      take_ownership(parent)
    end

    def state_name : String
      lifecycle_state.to_s
    end

    protected def destroy_native : Nil
    end

    protected def after_destroy : Nil
      @cleaned_up = true
    end

    def to_unsafe
      ref_ptr
    end
  end

  class LifetimeContainer < SpecSupport::LifetimeControl
    @child : UIng::Control?

    def initialize(@child : UIng::Control? = nil, address : UInt64 = 0_u64, register : Bool = false)
      super(address, register)
    end

    def adopt_child(child : SpecSupport::LifetimeControl) : Nil
      @child = child
      child.adopt(self)
    end

    def contains?(child : UIng::Control) : Bool
      @child.same?(child)
    end

    def delete(child : UIng::Control)
      unless @child.same?(child)
        raise "SpecSupport::LifetimeContainer does not contain child"
      end
      @child = nil
      child.release_ownership
    end

    protected def after_destroy : Nil
      super
      @child = nil
    end
  end

  class RegistryWindow < UIng::Window
    def initialize(address : UInt64)
      @ref_ptr = Pointer(UIng::LibUI::Window).new(address)
      register_control(install_destroy_callback: false)
    end

    def close_result(&block : -> Bool) : Bool
      handle_closing(block)
    end

    def state_name : String
      lifecycle_state.to_s
    end

    protected def destroy_native : Nil
    end
  end

  class RegistryArea < UIng::Area
    def initialize(address : UInt64)
      @ref_ptr = Pointer(UIng::LibUI::Area).new(address)
      register_control(install_destroy_callback: false)
    end
  end
end
