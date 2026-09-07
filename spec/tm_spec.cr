require "./spec_helper"

private def tm_with_date(year : Int32, month : Int32, day : Int32) : UIng::TM
  UIng::TM.new.tap do |value|
    value.year = year - 1900
    value.mon = month - 1
    value.mday = day
  end
end

describe UIng::TM do
  it "converts valid fields to Time" do
    time = tm_with_date(2024, 2, 29).to_time

    {time.year, time.month, time.day}.should eq({2024, 2, 29})
  end

  it "raises when its fields do not describe a valid time" do
    expect_raises(ArgumentError) do
      tm_with_date(2024, 13, 1).to_time
    end
  end

  it "offers a nil-returning conversion for invalid fields" do
    tm_with_date(2023, 2, 29).to_time?.should be_nil
  end

  it "preserves wall-clock fields instead of the instant across time zones" do
    previous_location = Time::Location.local
    local_location = Time::Location.posix_tz(
      "America/New_York",
      "EST5EDT,M3.2.0,M11.1.0"
    )
    Time::Location.local = local_location

    [{2025, 1, 15, -18_000}, {2025, 7, 15, -14_400}].each do |year, month, day, offset|
      source = Time.utc(year, month, day, 12, 34, 56)
      converted = UIng::TM.new(source).to_time

      {converted.year, converted.month, converted.day}.should eq({year, month, day})
      {converted.hour, converted.minute, converted.second}.should eq({12, 34, 56})
      converted.location.should be(local_location)
      converted.offset.should eq(offset)
      converted.to_utc.should_not eq(source)
    end
  ensure
    Time::Location.local = previous_location if previous_location
  end
end
