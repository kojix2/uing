module UIng
  lib LibUI
    struct Control
      signature : UInt32
      os_signature : UInt32
      type_signature : UInt32
      destroy : (Pointer(Control) -> Void)
      handle : (Pointer(Control) -> Pointer(Void))
      parent : (Pointer(Control) -> Pointer(Control))
      set_parent : (Pointer(Control), Pointer(Control) -> Void)
      toplevel : (Pointer(Control) -> LibC::Int)
      visible : (Pointer(Control) -> LibC::Int)
      show : (Pointer(Control) -> Void)
      hide : (Pointer(Control) -> Void)
      enabled : (Pointer(Control) -> LibC::Int)
      enable : (Pointer(Control) -> Void)
      disable : (Pointer(Control) -> Void)
    end
  end
end
