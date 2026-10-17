require "./control"

module UIng
  class Grid < Control
    block_constructor

    @children_refs : Array(Control) = [] of Control

    def initialize(padded : Bool = false)
      @ref_ptr = LibUI.new_grid
      self.padded = true if padded
      register_control
    end

    protected def after_destroy : Nil
      @children_refs.clear
    end

    def delete(child : Control)
      unless @children_refs.includes?(child)
        raise "Grid does not contain child"
      end
      delete_native_child(child)
      @children_refs.delete(child)
      child.release_ownership
    end

    protected def delete_native_child(child : Control) : Nil
      LibUI.grid_delete(ref_ptr, UIng.to_control(child))
    end

    def append(control, left : Int32, top : Int32,
               xspan : Int32 = 1, yspan : Int32 = 1,
               hexpand : Bool = false, halign : UIng::Align = UIng::Align::Fill,
               vexpand : Bool = false, valign : UIng::Align = UIng::Align::Fill) : Nil
      check_spans(xspan, yspan)
      control.check_can_move(self)
      LibUI.grid_append(ref_ptr, UIng.to_control(control), left, top, xspan, yspan, hexpand, halign, vexpand, valign)
      @children_refs << control
      control.take_ownership(self)
    end

    def insert_at(control, existing, at : At,
                  xspan : Int32 = 1, yspan : Int32 = 1,
                  hexpand : Bool = false, halign : UIng::Align = UIng::Align::Fill,
                  vexpand : Bool = false, valign : UIng::Align = UIng::Align::Fill) : Nil
      unless @children_refs.includes?(existing)
        raise ArgumentError.new("existing control does not belong to this Grid")
      end
      check_spans(xspan, yspan)
      control.check_can_move(self)
      LibUI.grid_insert_at(ref_ptr, UIng.to_control(control), UIng.to_control(existing), at, xspan, yspan, hexpand, halign, vexpand, valign)
      @children_refs << control
      control.take_ownership(self)
    end

    def padded? : Bool
      LibUI.grid_padded(ref_ptr) != 0
    end

    def padded=(padded : Bool) : Nil
      LibUI.grid_set_padded(ref_ptr, padded ? 1 : 0)
    end

    def to_unsafe
      ref_ptr
    end

    private def check_spans(xspan : Int32, yspan : Int32) : Nil
      raise ArgumentError.new("xspan must be at least 1") if xspan < 1
      raise ArgumentError.new("yspan must be at least 1") if yspan < 1
    end
  end
end
