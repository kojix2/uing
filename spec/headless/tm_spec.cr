require "../spec_helper"

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

  it "raises when its fields do not describe a valid time" do
    expect_raises(ArgumentError) do
      tm_with_date(2024, 13, 1).to_time
    end
  end

  it "offers a nil-returning conversion for invalid fields" do
    tm_with_date(2023, 2, 29).to_time?.should be_nil
  end

  {% unless flag?(:windows) %}
    it "keeps its own copy of the zone string" do
      source = String.new("TEST".to_slice)
      tm = UIng::TM.new
      tm.zone = source

      tm.zone.should eq("TEST")
      tm.to_unsafe.value.zone.should_not eq(source.to_unsafe)
      GC.collect
      String.new(tm.to_unsafe.value.zone).should eq("TEST")

      tm.zone = "NEXT"
      tm.zone.should eq("NEXT")
      String.new(tm.to_unsafe.value.zone).should eq("NEXT")
    end

    it "copies a zone supplied by native code" do
      native_zone = String.new("NATIVE".to_slice)
      tm = UIng::TM.new
      tm.zone = "OLD"
      tm.to_unsafe.value.zone = native_zone.to_unsafe

      tm.capture_native_zone
      tm.zone.should eq("NATIVE")
      tm.to_unsafe.value.zone.should_not eq(native_zone.to_unsafe)

      borrowed_zone = String.new("BORROWED".to_slice)
      tm.to_unsafe.value.zone = borrowed_zone.to_unsafe
      tm.zone.should eq("BORROWED")
      tm.to_unsafe.value.zone.should_not eq(borrowed_zone.to_unsafe)

      tm.to_unsafe.value.zone = Pointer(LibC::Char).null
      tm.capture_native_zone
      tm.zone.should be_nil
    end
  {% end %}
end
