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
  end
end
