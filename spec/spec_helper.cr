require "spec"
require "../src/uing"

module UIng
  @@expected_callback_error_for_spec : Tuple(String, String)? = nil

  # Suppress only the expected diagnostic; unexpected errors and GC warnings
  # still reach stderr. The application error handler is exercised as usual.
  def self.expect_callback_error_log(message : String, context : String, &)
    previous = @@expected_callback_error_for_spec
    @@expected_callback_error_for_spec = {message, context}
    begin
      yield
    ensure
      @@expected_callback_error_for_spec = previous
    end
  end

  private def self.report_callback_error(ex : Exception, ctx : String) : Nil
    return if @@expected_callback_error_for_spec == {ex.message, ctx}
    previous_def
  end
end
