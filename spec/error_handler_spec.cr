require "./spec_helper"

describe "callback error handling" do
  it "passes callback failures to an application-defined handler" do
    received_error = nil
    received_context = nil
    error = Exception.new("boom")

    UIng.on_error do |exception, context|
      received_error = exception
      received_context = context
    end

    begin
      UIng.expect_callback_error_log("boom", "test callback") do
        UIng.handle_callback_error(error, "test callback")
      end
    ensure
      UIng.on_error(nil)
    end

    received_error.should be(error)
    received_context.should eq("test callback")
  end
end
