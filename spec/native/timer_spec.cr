require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::Timer do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "runs managed timers and suppresses callbacks after stop" do
      window = UIng::Window.new("Timer lifecycle", 160, 80)
      window.show
      calls = 0
      cancelled_calls = 0
      timer = UIng.timer(1) do
        calls += 1
        false
      end
      cancelled = UIng.timer(1.millisecond) do
        cancelled_calls += 1
        true
      end
      cancelled.stop

      UIng.main_steps
      deadline = Time.instant + 5.seconds
      until timer.stopped?
        UIng.main_step(false)
        raise "timed out waiting for managed timer" if Time.instant >= deadline
        sleep 1.millisecond
      end

      calls.should eq(1)
      cancelled.stopped?.should be_true
      cancelled_calls.should eq(0)
    ensure
      timer.try &.stop
      cancelled.try &.stop
      window.try &.destroy
    end
  end
{% end %}
