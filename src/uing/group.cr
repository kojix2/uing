require "./control"

module UIng
  class Group
    include Control; block_constructor

    def initialize(@ref_ptr : Pointer(LibUI::Group))
    end

    def initialize(title : String, margined : Bool = false)
      @ref_ptr = LibUI.new_group(title)
      self.margined = true if margined
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
