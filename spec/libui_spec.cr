require "./spec_helper"

describe UIng do
  it "has a version number" do
    UIng::VERSION.should be_a(String)
  end

  it "rejects invalid timer intervals before retaining or calling the callback" do
    callback_called = false

    [0_i64, -1_i64, Int32::MAX.to_i64 + 1].each do |interval|
      expect_raises(ArgumentError, /between 1 and Int32::MAX/) do
        UIng.timer(interval) do
          callback_called = true
          0
        end
      end
    end

    callback_called.should be_false
  end
end
