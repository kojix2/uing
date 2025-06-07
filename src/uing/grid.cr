require "./control"

module UIng
  class Grid
    include Control; block_constructor

    @children_refs : Array(Control) = [] of Control

    def initialize(@ref_ptr : Pointer(LibUI::Grid))
    end

    def initialize(padded : Bool = false)
      @ref_ptr = LibUI.new_grid
      self.padded = true if padded
    end

    def append(control, left : Int32, top : Int32, xspan : Int32, yspan : Int32, hexpand : Bool, halign : UIng::Align, vexpand : Bool, valign : UIng::Align) : Nil
      LibUI.grid_append(@ref_ptr, UIng.to_control(control), left, top, xspan, yspan, hexpand, halign, vexpand, valign)
      @children_refs << control
    end

    def insert_at(control, existing, at : UIng::At, xspan : Int32, yspan : Int32, hexpand : Bool, halign : UIng::Align, vexpand : Bool, valign : UIng::Align) : Nil
      LibUI.grid_insert_at(@ref_ptr, UIng.to_control(control), UIng.to_control(existing), at, xspan, yspan, hexpand, halign, vexpand, valign)
      @children_refs << control
    end

    def padded? : Bool
      LibUI.grid_padded(@ref_ptr)
    end

    def padded=(padded : Bool) : Nil
      LibUI.grid_set_padded(@ref_ptr, padded)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
