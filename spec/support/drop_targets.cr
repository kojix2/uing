require "../spec_helper"

module SpecSupport
  class DropWindowForSpec < UIng::Window
    getter native_handler = UIng::LibUI::DropHandler.new
    getter user_data = Pointer(Void).null
    property status = UIng::LibUI::DropStatus::OK

    def initialize
      @ref_ptr = Pointer(UIng::LibUI::Window).null
    end

    protected def set_native_drop_handler(formats : LibC::UInt, handler : UIng::LibUI::DropHandler*, data : Void*) : UIng::LibUI::DropStatus
      return @status unless @status.ok?
      @native_handler = handler.null? ? UIng::LibUI::DropHandler.new : handler.value
      @user_data = data
      @status
    end

    def destroy : Nil
      return if released?
      @user_data = Pointer(Void).null
      mark_destroyed_from_native
    end
  end
end
