module UIng
  module Drop
    private alias CallbackContext = Tuple(Target, Handler)

    class Error < Exception
      getter status : LibUI::DropStatus

      def initialize(@status : LibUI::DropStatus)
        super("drop registration failed: #{@status}")
      end
    end

    # Shared drop callbacks receive their Window/Area target first. Configure
    # and register on the UI thread; callback changes apply to all targets.
    # Return true from over/drop to accept Copy/the drop.
    class Handler
      getter accepts : Format
      protected getter drop_callback : Proc(Target, Event, Bool)?
      protected getter over_callback : Proc(Target, Info, Bool)?
      protected getter leave_callback : Proc(Target, Nil)?
      @native = LibUI::DropHandler.new

      def self.new(accepts : Format = Format::All, &)
        handler = new(accepts)
        with handler yield handler
        handler
      end

      def initialize(@accepts : Format = Format::All)
        if @accepts.none? || (@accepts.value & ~Format::All.value) != 0
          raise ArgumentError.new("accepted drop formats must be Text, Files, or both")
        end
        @native = LibUI::DropHandler.new(
          size: LibC::SizeT.new(sizeof(LibUI::DropHandler)),
          drop: ->(info : LibUI::DropInfo*, payload : LibUI::DropData*, data : Void*) : LibUI::DropResult {
            begin
              target, handler = ::Box(CallbackContext).unbox(data)
              if callback = handler.drop_callback
                callback.call(target, Event.new(info.value, payload.value)) ? LibUI::DropResult::Accepted : LibUI::DropResult::Rejected
              else
                LibUI::DropResult::Rejected
              end
            rescue error
              UIng.handle_callback_error(error, "Drop drop")
              LibUI::DropResult::Rejected
            end
          },
          over: ->(info : LibUI::DropInfo*, data : Void*) : LibUI::DropAction {
            begin
              target, handler = ::Box(CallbackContext).unbox(data)
              callback = handler.over_callback
              # Over may itself clear the required drop callback.
              if handler.drop_callback && (callback.nil? || callback.call(target, Info.new(info.value))) && handler.drop_callback
                LibUI::DropAction::Copy
              else
                LibUI::DropAction::None
              end
            rescue error
              UIng.handle_callback_error(error, "Drop over")
              LibUI::DropAction::None
            end
          },
          leave: ->(data : Void*) {
            begin
              target, handler = ::Box(CallbackContext).unbox(data)
              handler.leave_callback.try &.call(target)
            rescue error
              UIng.handle_callback_error(error, "Drop leave")
            end
          }
        )
      end

      def drop(&block : Proc(Target, Event, Bool)) : Nil
        @drop_callback = block
      end

      def clear_drop : Nil
        @drop_callback = nil
      end

      def drop(callback : Nil) : Nil
        clear_drop
      end

      # Metadata only: filenames and text are available in drop, not over.
      # Without this callback, compatible Copy offers are accepted while a drop
      # callback is installed. Clearing drop also rejects hover offers.
      def over(&block : Proc(Target, Info, Bool)) : Nil
        @over_callback = block
      end

      def clear_over : Nil
        @over_callback = nil
      end

      def over(callback : Nil) : Nil
        clear_over
      end

      # Ends hover feedback. It may precede a successful drop and is not a
      # cancellation or destruction notification.
      def leave(&block : Proc(Target, Nil)) : Nil
        @leave_callback = block
      end

      def clear_leave : Nil
        @leave_callback = nil
      end

      def leave(callback : Nil) : Nil
        clear_leave
      end

      # The target retains the callback context; active calls retain their Proc.
      # Native retirement stops new calls. ReleaseUserData remains unused.
      def to_unsafe : LibUI::DropHandler*
        raise ArgumentError.new("a drop callback is required") unless @drop_callback
        pointerof(@native)
      end
    end
  end
end
