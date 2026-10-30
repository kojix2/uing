module UIng
  alias ErrorHandler = Proc(Exception, String, Nil)

  # Optional application-defined callback error policy. Errors are always
  # logged; UI notification is left to the application.
  @@error_handler : ErrorHandler?

  @[Experimental]
  def self.on_error(&handler : Exception, String -> Nil) : Nil
    @@callback_mutex.synchronize { @@error_handler = handler }
  end

  @[Experimental]
  def self.on_error(handler : Nil) : Nil
    @@callback_mutex.synchronize { @@error_handler = nil }
  end

  @[Experimental]
  # Equivalent to `on_error(nil)`.
  def self.clear_on_error : Nil
    on_error(nil)
  end

  # Handle callback errors by printing the error message and backtrace, then
  # invoking the application-defined policy when one has been configured.
  def self.handle_callback_error(ex : Exception, ctx : String = "callback")
    report_callback_error(ex, ctx)

    handler = @@callback_mutex.synchronize { @@error_handler }
    return unless handler

    begin
      handler.call(ex, ctx)
    rescue error
      Crystal::System.print_error "error handler failed: %s\n", error.message
    end
  end

  private def self.report_callback_error(ex : Exception, ctx : String) : Nil
    # As UIng is a UI library, applications may not have standard output available
    # Use Crystal's system error output to ensure error messages are properly logged
    Crystal::System.print_error "%s error: %s\n", ctx, ex.message
    if backtrace = ex.backtrace?
      backtrace.each { |frame| Crystal::System.print_error "  from %s\n", frame }
    end
  end
end
