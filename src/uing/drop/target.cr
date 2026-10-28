module UIng
  module Drop
    # A Window or Area that receives drops.
    module Target
      @drop_handler : Handler?
      @drop_context : ::Box(CallbackContext)?
      @owns_drop_handler = false

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
        @owns_drop_handler = false
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
        @owns_drop_handler = false
      end

      # Explicit Handlers must first be removed with clear_drop_handler.
      @[Experimental]
      def on_drop(accepts : Format = Format::All, &block : Event -> Bool) : Nil
        check_callback_drop_handler
        handler = Handler.new(accepts)
        handler.drop { |_target, event| block.call(event) }
        self.drop_handler = handler
        @owns_drop_handler = true
      end

      @[Experimental]
      def clear_on_drop : Nil
        check_callback_drop_handler
        clear_drop_handler
      end

      @[Experimental]
      def on_drop(callback : Nil) : Nil
        clear_on_drop
      end

      private def check_callback_drop_handler : Nil
        check_available
        if @drop_handler && !@owns_drop_handler
          raise ArgumentError.new("drop callbacks cannot modify an explicit Handler; call clear_drop_handler first")
        end
      end
    end
  end
end
