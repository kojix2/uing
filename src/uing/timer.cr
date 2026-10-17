module UIng
  # A repeating UI timer. `stop` prevents further user callbacks immediately;
  # libui-ng removes its native timer when the next tick returns zero.
  class Timer
    @stopped = false
    @callback : Proc(Bool)?

    # :nodoc:
    def self.__create__(callback : -> Bool) : Timer
      new(callback)
    end

    private def initialize(@callback : Proc(Bool))
    end

    # Stops future user callbacks. Call on the UI thread; it is safe to call
    # this inside the callback.
    def stop : Nil
      @stopped = true
      @callback = nil
    end

    # Whether the timer has been stopped explicitly, by returning `false`, by
    # a callback error, or by `UIng.uninit`.
    def stopped? : Bool
      @stopped
    end

    # :nodoc:
    def __tick__ : Bool
      return false if @stopped
      callback = @callback || return false

      begin
        keep_running = callback.call
        stop unless keep_running
      rescue error
        stop
        UIng.handle_callback_error(error, "UIng.timer")
      end

      !@stopped
    end
  end
end
