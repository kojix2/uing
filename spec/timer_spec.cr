require "./spec_helper"

describe UIng::Timer do
  it "stops before the first tick without invoking the user callback" do
    calls = 0
    timer = UIng::Timer.__create__(-> { calls += 1; true })

    timer.stop
    timer.stop

    timer.stopped?.should be_true
    timer.__tick__.should be_false
    calls.should eq(0)
  end

  it "continues on true and stops on false" do
    calls = 0
    timer = UIng::Timer.__create__(-> { calls += 1; calls < 2 })

    timer.__tick__.should be_true
    timer.stopped?.should be_false
    timer.__tick__.should be_false
    timer.stopped?.should be_true
    timer.__tick__.should be_false
    calls.should eq(2)
  end

  it "honors stop called from inside the callback" do
    timer = nil.as(UIng::Timer?)
    timer = UIng::Timer.__create__(-> { timer.not_nil!.stop; true })

    timer.not_nil!.__tick__.should be_false
    timer.not_nil!.stopped?.should be_true
  end

  it "stops and reports callback errors without propagating them" do
    reported = nil.as(Exception?)
    UIng.on_error { |error, _context| reported = error }
    timer = UIng::Timer.__create__(-> { raise "timer failed"; true })

    UIng.expect_callback_error_log("timer failed", "UIng.timer") do
      timer.__tick__.should be_false
    end

    timer.stopped?.should be_true
    reported.not_nil!.message.should eq("timer failed")
  ensure
    UIng.clear_on_error
  end
end

describe "integer millisecond timers" do
  it "rejects intervals outside the native range" do
    callback_called = false
    [0_i64, -1_i64, Int32::MAX.to_i64 + 1].each do |interval|
      expect_raises(ArgumentError, /timer interval must be between/) do
        UIng.timer(interval) { callback_called = true; true }
      end
    end
    callback_called.should be_false
  end

  it "rejects registration before initialization" do
    expect_raises(RuntimeError, /must be initialized/) do
      UIng.timer(1) { true }
    end
  end
end

describe "Time::Span timers" do
  it "rejects invalid intervals before entering libui-ng" do
    callback_called = false
    [Time::Span.zero, -1.nanosecond, (Int32::MAX.to_i64 + 1).milliseconds].each do |interval|
      expect_raises(ArgumentError, /timer interval must be positive/) do
        UIng.timer(interval) { callback_called = true; true }
      end
    end
    callback_called.should be_false
  end

  it "rejects registration before initialization" do
    expect_raises(RuntimeError, /must be initialized/) do
      UIng.timer(1.second) { true }
    end
  end
end
