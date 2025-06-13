require "./control"

module UIng
  class Entry < Control
    block_constructor
    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

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

    def text : String?
      str_ptr = LibUI.entry_text(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def text=(text : String) : Nil
      LibUI.entry_set_text(@ref_ptr, text)
    end

    def read_only? : Bool
      LibUI.entry_read_only(@ref_ptr)
    end

    def read_only=(readonly : Bool) : Nil
      LibUI.entry_set_read_only(@ref_ptr, readonly)
    end

    def on_changed(&block : String -> Void)
      wrapper = -> {
        current_text = self.text || ""
        block.call(current_text)
      }
      @on_changed_box = ::Box.box(wrapper)
      LibUI.entry_on_changed(@ref_ptr, ->(sender, data) do
        begin
          data_as_callback = ::Box(typeof(wrapper)).unbox(data)
          data_as_callback.call
        rescue e
          UIng.handle_callback_error(e, "Entry on_changed")
        end
      end, @on_changed_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
