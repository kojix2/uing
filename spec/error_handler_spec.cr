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
      UIng.handle_callback_error(error, "test callback")
    ensure
      UIng.on_error(nil)
    end

    received_error.should be(error)
    received_context.should eq("test callback")
  end
end
