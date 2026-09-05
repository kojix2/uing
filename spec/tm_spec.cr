require "./spec_helper"

private def tm_with_date(year : Int32, month : Int32, day : Int32) : UIng::TM
  UIng::TM.new.tap do |tm|
    tm.year = year - 1900
    tm.mon = month - 1
    tm.mday = day
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
end
