require "../spec_helper"

module SpecSupport
  class DetachableControl < UIng::Control
    @ref_ptr : Pointer(UIng::LibUI::Button)

    def initialize
      @ref_ptr = Pointer(UIng::LibUI::Button).new(0x200_u64)
    end

    def adopt(parent : UIng::Control) : Nil
      take_ownership(parent)
    end

    def to_unsafe
      ref_ptr
    end
  end

  class DetachableWindow < UIng::Window
    getter? native_child_cleared = false

    def initialize
      @ref_ptr = Pointer(UIng::LibUI::Window).null
    end

    protected def set_native_child(child : Pointer(UIng::LibUI::Control)) : Nil
      @native_child_cleared = child.null?
    end

    protected def destroy_native : Nil
    end
  end

  class DetachableGroup < UIng::Group
    getter? native_child_cleared = false

    def initialize
      @ref_ptr = Pointer(UIng::LibUI::Group).null
    end

    protected def set_native_child(child : Pointer(UIng::LibUI::Control)) : Nil
      @native_child_cleared = child.null?
    end

    protected def destroy_native : Nil
    end
  end

  class DetachableGrid < UIng::Grid
    getter? native_child_deleted = false

    def initialize
      @ref_ptr = Pointer(UIng::LibUI::Grid).null
    end

    def adopt(child : SpecSupport::DetachableControl) : Nil
      @children_refs << child
      child.adopt(self)
    end

    protected def delete_native_child(child : UIng::Control) : Nil
      @native_child_deleted = true
    end
  end

  class DetachableTab < UIng::Tab
    getter native_delete_calls = 0
    getter native_deleted_index : Int32?

    def initialize
      @ref_ptr = Pointer(UIng::LibUI::Tab).null
    end

    def adopt(child : SpecSupport::DetachableControl) : Nil
      @children_refs << child
      child.adopt(self)
    end

    def child_refs : Array(UIng::Control)
      @children_refs.dup
    end

    protected def delete_native_child(index : Int32) : Nil
      @native_delete_calls += 1
      @native_deleted_index = index
    end
  end
end
