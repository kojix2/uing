require "./control"

module UIng
  class Combobox < Control
    block_constructor

    # Store callback box to prevent GC collection
    @on_selected_box : Pointer(Void)?

    def initialize
      @ref_ptr = LibUI.new_combobox
    end

    def destroy
      @on_selected_box = nil
      super
    end

    def initialize(items : Array(String))
      initialize()
      items.each do |item|
        append(item)
      end
    end

    def append(text : String) : Nil
      LibUI.combobox_append(@ref_ptr, text)
    end

    def insert_at(index : Int32, text : String) : Nil
      LibUI.combobox_insert_at(@ref_ptr, index, text)
    end

    def delete(index : Int32) : Nil
      LibUI.combobox_delete(@ref_ptr, index)
    end

    def clear : Nil
      LibUI.combobox_clear(@ref_ptr)
    end

    def num_items : Int32
      LibUI.combobox_num_items(@ref_ptr)
    end

    def selected : Int32
      LibUI.combobox_selected(@ref_ptr)
    end

    def selected=(index : Int32) : Nil
      LibUI.combobox_set_selected(@ref_ptr, index)
    end

    def on_selected(&block : Int32 -> Void)
      wrapper = -> {
        idx = self.selected
        block.call(idx)
      }
      @on_selected_box = ::Box.box(wrapper)
      LibUI.combobox_on_selected(@ref_ptr, ->(sender, data) do
        begin
          data_as_callback = ::Box(typeof(wrapper)).unbox(data)
          data_as_callback.call
        rescue e
          UIng.handle_callback_error(e, "Combobox on_selected")
        end
      end, @on_selected_box.not_nil!)
    end

    def to_unsafe
      @ref_ptr
    end
  end
end
