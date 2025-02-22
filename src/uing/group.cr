require "./control"

module UIng
  class Group
    include Control

    def initialize(@ref_ptr : Pointer(LibUI::Group))
    end

    # def initialize
    #   @ref_ptr = LibUI.new_group
    # end

    def to_unsafe
      @ref_ptr
    end
  end
end
