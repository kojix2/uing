require "../spec_helper"

{% if env("UING_NATIVE_GUI_TESTS") == "1" %}
  describe UIng::DateTimePicker do
    before_all { UIng.init }
    after_all { UIng.uninit }
    after_each { UIng.on_error(nil) }

    it "treats DateTimePicker values as local wall-clock fields" do
      previous_location = Time::Location.local
      local_location = Time::Location.posix_tz(
        "America/New_York",
        "EST5EDT,M3.2.0,M11.1.0"
      )
      Time::Location.local = local_location
      picker = UIng::DateTimePicker.new

      [{2025, 1, 15, -18_000}, {2025, 7, 15, -14_400}].each do |year, month, day, offset|
        source = Time.utc(year, month, day, 12, 34)
        picker.time = source
        displayed = picker.time

        {displayed.year, displayed.month, displayed.day}.should eq({year, month, day})
        {displayed.hour, displayed.minute}.should eq({12, 34})
        displayed.location.should be(local_location)
        displayed.offset.should eq(offset)
        displayed.to_utc.should_not eq(source)
      end
    ensure
      picker.try &.destroy
      Time::Location.local = previous_location if previous_location
    end
  end
{% end %}
