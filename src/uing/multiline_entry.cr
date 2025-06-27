require "./control"

module UIng
  class MultilineEntry < Control
    block_constructor

    # Store callback box to prevent GC collection
    @on_changed_box : Pointer(Void)?

    def initialize(wrapping = true, read_only = false)
      if wrapping
        @ref_ptr = LibUI.new_multiline_entry
      else
        @ref_ptr = LibUI.new_non_wrapping_multiline_entry
      end
      if read_only
        self.read_only = true
      end
    end

    def destroy
      @on_changed_box = nil
      super
    end

    def text : String?
      str_ptr = LibUI.multiline_entry_text(@ref_ptr)
      UIng.string_from_pointer(str_ptr)
    end

    def text=(text : String) : Nil
      LibUI.multiline_entry_set_text(@ref_ptr, text)
    end

    def append(text : String) : Nil
      LibUI.multiline_entry_append(@ref_ptr, text)
    end

    def read_only? : Bool
      LibUI.multiline_entry_read_only(@ref_ptr)
    end

    def read_only=(readonly : Bool) : Nil
      LibUI.multiline_entry_set_read_only(@ref_ptr, readonly)
    end

    def on_changed(&block : -> _)
      @on_changed_box = ::Box.box(block)
      LibUI.multiline_entry_on_changed(@ref_ptr, ->(sender, data) do
        begin
          data_as_callback = ::Box(typeof(block)).unbox(data)
          data_as_callback.call
        rescue e
          UIng.handle_callback_error(e, "MultilineEntry on_changed")
        end
      end, @on_changed_box.not_nil!)
    end

    # If a large amount of text is entered in the multiline entry,
    # it is heavy to get the text in the callback, so a separate method is provided.

    def on_changed_with_text(&block : String -> _)
      wrapper = -> {
        current_text = self.text || ""
        block.call(current_text)
      }
      @on_changed_box = ::Box.box(wrapper)
      LibUI.multiline_entry_on_changed(@ref_ptr, ->(sender, data) do
        begin
          data_as_callback = ::Box(typeof(wrapper)).unbox(data)
          data_as_callback.call
        rescue e
          UIng.handle_callback_error(e, "MultilineEntry on_changed_with_text")
        end
      end, @on_changed_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
