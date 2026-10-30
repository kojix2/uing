require "./spec_helper"

describe UIng::OpenTypeFeatures do
  it "builds feature sets with an implicit receiver and returns the configured instance" do
    yielded = nil
    features = UIng::OpenTypeFeatures.new do |value|
      yielded = value
      add("liga")
      add("kern", 0_u32)
      :ignored
    end

    features.should be(yielded)
    features.get("liga").should eq(1_u32)
    features.get("kern").should eq(0_u32)
  end

  it "distinguishes absent features from features with value zero" do
    features = UIng::OpenTypeFeatures.new
    features.get("liga").should be_nil

    features.add("liga", 0_u32)
    features.get("liga").should eq(0_u32)
    features.add("liga", UInt32::MAX)
    features.get("liga").should eq(UInt32::MAX)
    values = {} of String => UInt32
    features.for_each { |tag, value| values[tag] = value }
    values.should eq({"liga" => UInt32::MAX})
    features.remove("liga")
    features.get("liga").should be_nil
  end

  it "clones independently" do
    features = UIng::OpenTypeFeatures.new
    features.add("liga")
    copy = features.clone

    features.add("liga", 0_u32)
    copy.get("liga").should eq(1_u32)
    copy.add("kern")
    features.get("kern").should be_nil
  end

  it "validates tags" do
    features = UIng::OpenTypeFeatures.new
    expect_raises(ArgumentError, /exactly 4 bytes/) { features.add("lig") }
    expect_raises(ArgumentError, /printable ASCII/) { features.get("a\nbc") }
    expect_raises(ArgumentError, /exactly 4 bytes/) { features.remove("日本") }
  end

  it "rejects mutation during enumeration and permits nested reads" do
    features = UIng::OpenTypeFeatures.new
    features.add("kern")
    features.add("liga")

    expect_raises(Exception, /being enumerated/) do
      features.for_each { |_tag, _value| features.add("tnum") }
    end
    features.get("tnum").should be_nil

    visits = 0
    features.for_each do |_tag, _value|
      features.for_each { |_nested_tag, _nested_value| visits += 1 }
    end
    visits.should eq(4)

    expect_raises(Exception, "callback failed") do
      features.for_each { |_tag, _value| raise "callback failed" }
    end
    features.add("tnum")
    features.get("tnum").should eq(1_u32)
  end
end
