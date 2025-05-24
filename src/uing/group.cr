require "./control"

module UIng
  class Group
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Group))
    end

    def initialize(title : String)
      @ref_ptr = LibUI.new_group(title)
    end

    def to_unsafe
      @ref_ptr
    end

    def title=(value : String)
      set_title(value)
    end

    def margined=(value : Bool)
      set_margined(value ? 1 : 0)
    end

    def child=(control)
      set_child(control)
    end
  end
end
