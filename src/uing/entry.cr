require "./control"

module UIng
  class Entry
    include Control; block_constructor

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(@ref_ptr : Pointer(LibUI::Entry))
    end

    def initialize(type : Symbol = :default, read_only = false)
      case type
      when :password
        @ref_ptr = LibUI.new_password_entry
      when :search
        @ref_ptr = LibUI.new_search_entry
      else
        @ref_ptr = LibUI.new_entry
      end
      if read_only
        self.read_only = true
      end
    end

    def on_changed(&block : String -> Void)
      wrapper = -> {
        text = UIng.entry_text(@ref_ptr)
        block.call(text ? text : "")
      }
      @on_changed_box = ::Box.box(wrapper)
      UIng.entry_on_changed(@ref_ptr, @on_changed_box.not_nil!, &wrapper)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
