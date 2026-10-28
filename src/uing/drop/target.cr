module UIng
  module Drop
    # A Window or Area that receives drops.
    module Target
      @drop_handler : Handler?
      @drop_context : ::Box(CallbackContext)?

      def drop_handler : Handler?
        check_available
        @drop_handler
      end

      # Replaces the current registration on the UI thread. Failure preserves
      # the previous handler. Native child receivers retain their own behavior;
      # an Area is an exclusive drop zone and rejection does not retry Window.
      def drop_handler=(handler : Handler) : Nil
        check_available
        context = ::Box(CallbackContext).new({self.as(Target), handler})
        status = set_native_drop_handler(handler.accepts.value, handler.to_unsafe, context.as(Void*))
        raise Error.new(status) unless status.ok?
        @drop_context = context
        @drop_handler = handler
      end

      def drop_handler=(handler : Nil) : Nil
        clear_drop_handler
      end

      def clear_drop_handler : Nil
        check_available
        status = set_native_drop_handler(0_u32, Pointer(LibUI::DropHandler).null, Pointer(Void).null)
        raise Error.new(status) unless status.ok?
        @drop_handler = nil
        @drop_context = nil
      end
    end
  end
end
