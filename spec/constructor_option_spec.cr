require "./spec_helper"

describe "constructor option enums" do
  it "accepts enum values, symbol literals, and symbol variables" do
    orientation = :vertical
    entry_type = :search
    picker_type = :date

    typeof(UIng::Box.new(UIng::Orientation::Horizontal)).should eq(UIng::Box)
    typeof(UIng::Box.new(orientation)).should eq(UIng::Box)
    typeof(UIng::Separator.new(UIng::Orientation::Vertical)).should eq(UIng::Separator)
    typeof(UIng::Separator.new(orientation)).should eq(UIng::Separator)
    typeof(UIng::Entry.new(UIng::Entry::Type::Password)).should eq(UIng::Entry)
    typeof(UIng::Entry.new(entry_type)).should eq(UIng::Entry)
    typeof(UIng::DateTimePicker.new(UIng::DateTimePicker::Type::Time)).should eq(UIng::DateTimePicker)
    typeof(UIng::DateTimePicker.new(picker_type)).should eq(UIng::DateTimePicker)
  end

  it "provides typed variants for symbol constructor options" do
    UIng::Orientation.parse("horizontal").should eq(UIng::Orientation::Horizontal)
    UIng::Orientation.parse("vertical").should eq(UIng::Orientation::Vertical)
    UIng::Entry::Type.parse("default").should eq(UIng::Entry::Type::Default)
    UIng::Entry::Type.parse("password").should eq(UIng::Entry::Type::Password)
    UIng::Entry::Type.parse("search").should eq(UIng::Entry::Type::Search)
    UIng::DateTimePicker::Type.parse("date").should eq(UIng::DateTimePicker::Type::Date)
    UIng::DateTimePicker::Type.parse("time").should eq(UIng::DateTimePicker::Type::Time)
    UIng::DateTimePicker::Type.parse("date_time").should eq(UIng::DateTimePicker::Type::DateTime)
  end

  it "rejects unknown symbols before calling libui-ng" do
    expect_raises(ArgumentError) { UIng::Box.new(:diagonal) }
    expect_raises(ArgumentError) { UIng::Separator.new(:diagonal) }
    expect_raises(ArgumentError) { UIng::Entry.new(:unknown) }
    expect_raises(ArgumentError) { UIng::DateTimePicker.new(:unknown) }
  end
end
