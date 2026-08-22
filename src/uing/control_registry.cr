module UIng
  # Internal identity map for native controls and their Crystal wrappers.
  private module ControlRegistry
    @@mutex = Mutex.new
    # Strong references are intentional: native callbacks retain raw pointers
    # into wrapper-owned Crystal boxes. A wrapper remains pinned until the
    # native destroyed notification removes it from this map.
    @@controls = {} of UInt64 => Control

    def self.register(control : Control, native_ptr : Pointer(LibUI::Control), install_destroy_callback : Bool = true) : Nil
      return if native_ptr.null?

      registered = @@mutex.synchronize do
        @@controls[native_ptr.address]? || begin
          @@controls[native_ptr.address] = control
          control
        end
      end

      unless registered.same?(control)
        raise "native control 0x#{native_ptr.address.to_s(16)} already has a registered wrapper"
      end

      if install_destroy_callback
        LibUI.control_on_destroyed(
          native_ptr,
          ->(ptr, _data) { ControlRegistry.native_destroyed(ptr) },
          Pointer(Void).null
        )
      end
    end

    def self.lookup(native_ptr : Pointer(T)) : Control? forall T
      return if native_ptr.null?
      @@mutex.synchronize { @@controls[native_ptr.address]? }
    end

    def self.native_destroyed(native_ptr : Pointer(T)) : Nil forall T
      control = @@mutex.synchronize { @@controls.delete(native_ptr.address) }
      control.try &.mark_destroyed_from_native
    end
  end
end
